import Foundation

public class RequestReceipt {
  public let request: URLRequest
  public let receiptID: String

  init(request: URLRequest, receiptID: String) {
    self.request = request
    self.receiptID = receiptID
  }
}

public class RequestResponse {
  public let response: URLResponse?
  public let data: Data?

  init(response: URLResponse?, data: Data?) {
    self.response = response
    self.data = data
  }
}

public final class ImageDownloader {
  public typealias CompletionHandler = (RequestResponse) -> Void

  class ResponseHandler {
    let urlID: String
    let handlerID: String
    let request: URLRequest
    var operations: [(receiptID: String, completion: CompletionHandler?)]

    init(
      request: URLRequest,
      handlerID: String,
      receiptID: String,
      completion: CompletionHandler?
    ) {
      self.request = request
      self.urlID = ImageDownloader.urlIdentifier(for: request)
      self.handlerID = handlerID
      self.operations = [(receiptID: receiptID, completion: completion)]
    }
  }

  public private(set) var credential: URLCredential?

  public let session: URLSession

  let maximumActiveDownloads: Int

  var activeRequestCount = 0
  var queuedRequests: [URLSessionTask] = []
  var responseHandlers: [String: ResponseHandler] = [:]

  private let synchronizationQueue: DispatchQueue = {
    let name = String(format: "org.bns.imagedownloader.synchronizationqueue-%08x%08x", arc4random(), arc4random())
    return DispatchQueue(label: name)
  }()

  private let responseQueue: DispatchQueue = {
    let name = String(format: "org.bns.imagedownloader.responsequeue-%08x%08x", arc4random(), arc4random())
    return DispatchQueue(label: name, attributes: .concurrent)
  }()

  public static let `default` = ImageDownloader()

  public class func defaultURLSessionConfiguration() -> URLSessionConfiguration {
    let configuration = URLSessionConfiguration.default

    configuration.httpShouldSetCookies = true
    configuration.httpShouldUsePipelining = false

    configuration.requestCachePolicy = .useProtocolCachePolicy
    configuration.allowsCellularAccess = true
    configuration.timeoutIntervalForRequest = 60

    configuration.urlCache = ImageDownloader.defaultURLCache()

    return configuration
  }

  public class func defaultURLCache() -> URLCache {
    let memoryCapacity = 20 * 1_024 * 1_024
    let diskCapacity = 150 * 1_024 * 1_024
    let imageDownloaderPath = "org.bns.imagedownloader"

    return URLCache(
      memoryCapacity: memoryCapacity,
      diskCapacity: diskCapacity,
      diskPath: imageDownloaderPath
    )
  }

  public init(
    configuration: URLSessionConfiguration = ImageDownloader.defaultURLSessionConfiguration(),
    maximumActiveDownloads: Int = 4
  ) {
    self.session = URLSession(configuration: configuration, delegate: ImageSessionDelegate.shared, delegateQueue: nil)
    self.maximumActiveDownloads = maximumActiveDownloads
  }

  public func addAuthentication(
    user: String,
    password: String,
    persistence: URLCredential.Persistence = .forSession
  ) {
    let credential = URLCredential(user: user, password: password, persistence: persistence)
    addAuthentication(usingCredential: credential)
    ImageSessionDelegate.shared.stateProvider = self
  }

  public func addAuthentication(usingCredential credential: URLCredential) {
    self.synchronizationQueue.sync {
      self.credential = credential
    }
  }

  @discardableResult
  public func download(
    _ urlRequest: URLRequest,
    receiptID: String = UUID().uuidString,
    completion: CompletionHandler?
  )
    -> RequestReceipt? {
    var request: URLRequest!

    self.synchronizationQueue.sync {
      // 1) Append the completion handler to a pre-existing request if it already exists
      let urlID = ImageDownloader.urlIdentifier(for: urlRequest)

      if let responseHandler = self.responseHandlers[urlID] {
        responseHandler.operations.append((receiptID: receiptID, completion: completion))
        request = responseHandler.request
        return
      }

      request = urlRequest

      // Generate a unique handler id to check whether the active request has changed while downloading
      let handlerID = UUID().uuidString

      // 2) Create data task and response serialization
      let task = session.dataTask(
        with: request,
        completionHandler: { data, response, error in
          defer {
            self.safelyDecrementActiveRequestCount()
            self.safelyStartNextRequestIfNecessary()
          }

          guard
            let handler = self.safelyFetchResponseHandler(withURLIdentifier: urlID),
            handler.handlerID == handlerID,
            let responseHandler = self.safelyRemoveResponseHandler(withURLIdentifier: urlID)
          else {
            return
          }

          for (_, completion) in responseHandler.operations {
            DispatchQueue.main.async {
              completion?(RequestResponse(response: response, data: data))
            }
          }

          if let error = error {
            print("🔴 [BnsApi] Failure - Image error: \(error)")
          }
        }
      )

      // 3) Store the response handler for use when the request completes
      let responseHandler = ResponseHandler(
        request: request,
        handlerID: handlerID,
        receiptID: receiptID,
        completion: completion
      )

      self.responseHandlers[urlID] = responseHandler

      // 4) Either start the request or enqueue it depending on the current active request count
      if self.isActiveRequestCountBelowMaximumLimit() {
        self.start(task)
      } else {
        self.enqueue(task)
      }
    }

    if let request = request {
      return RequestReceipt(request: request, receiptID: receiptID)
    }

    return nil
  }

  public func cancelRequest(with requestReceipt: RequestReceipt) {
    self.synchronizationQueue.sync {
      let urlID = ImageDownloader.urlIdentifier(for: requestReceipt.request)
      guard let responseHandler = self.responseHandlers[urlID] else { return }

      let index = responseHandler.operations.firstIndex { $0.receiptID == requestReceipt.receiptID }

      if let index = index {
        let operation = responseHandler.operations.remove(at: index)

        DispatchQueue.main.async {
          operation.completion?(RequestResponse(response: nil, data: nil))
        }
      }

      if responseHandler.operations.isEmpty {
        self.dequeueTask(withURLRequest: requestReceipt.request)?.cancel()
        self.responseHandlers.removeValue(forKey: urlID)
      }
    }
  }

  // MARK: Internal - Thread-Safe Request Methods

  func safelyFetchResponseHandler(withURLIdentifier urlIdentifier: String) -> ResponseHandler? {
    var responseHandler: ResponseHandler?

    self.synchronizationQueue.sync {
      responseHandler = self.responseHandlers[urlIdentifier]
    }

    return responseHandler
  }

  func safelyRemoveResponseHandler(withURLIdentifier identifier: String) -> ResponseHandler? {
    var responseHandler: ResponseHandler?

    self.synchronizationQueue.sync {
      responseHandler = self.responseHandlers.removeValue(forKey: identifier)
    }

    return responseHandler
  }

  func safelyStartNextRequestIfNecessary() {
    self.synchronizationQueue.sync {
      guard self.isActiveRequestCountBelowMaximumLimit() else { return }

      guard let request = self.dequeue() else { return }

      self.start(request)
    }
  }

  func safelyDecrementActiveRequestCount() {
    self.synchronizationQueue.sync {
      self.activeRequestCount -= 1
    }
  }

  // MARK: Internal - Non Thread-Safe Request Methods

  func start(_ task: URLSessionTask) {
    task.resume()
    self.activeRequestCount += 1
  }

  func enqueue(_ task: URLSessionTask) {
    self.queuedRequests.append(task)
  }

  @discardableResult
  func dequeue() -> URLSessionTask? {
    var task: URLSessionTask?

    if !self.queuedRequests.isEmpty {
      task = self.queuedRequests.removeFirst()
    }

    return task
  }

  @discardableResult
  func dequeueTask(withURLRequest request: URLRequest) -> URLSessionTask? {
    var task: URLSessionTask?

    if let index = self.queuedRequests
      .firstIndex(where: { $0.currentRequest?.url == request.url }) {
      task = self.queuedRequests[index]
    }

    return task
  }

  func isActiveRequestCountBelowMaximumLimit() -> Bool {
    return self.activeRequestCount < self.maximumActiveDownloads
  }

  static func urlIdentifier(for urlRequest: URLRequest) -> String {
    return urlRequest.url?.absoluteString ?? ""
  }
}

private class ImageSessionDelegate: NSObject {
  weak var stateProvider: SessionStateProvider?

  static let shared = ImageSessionDelegate()
}

protocol SessionStateProvider: AnyObject {
  func credential(in protectionSpace: URLProtectionSpace) -> URLCredential?
}

extension ImageSessionDelegate: URLSessionDelegate {

  typealias ChallengeEvaluation = (disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?)

  open func urlSession(
    _ session: URLSession,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {

    let evaluation: ChallengeEvaluation
    switch challenge.protectionSpace.authenticationMethod {
    case NSURLAuthenticationMethodServerTrust:
      evaluation = self.attemptServerTrustAuthentication(session, with: challenge)
    case NSURLAuthenticationMethodHTTPBasic, NSURLAuthenticationMethodHTTPDigest, NSURLAuthenticationMethodNTLM,
         NSURLAuthenticationMethodNegotiate, NSURLAuthenticationMethodClientCertificate:
      evaluation = self.attemptServerTrustAuthentication(session, with: challenge)
    default:
      evaluation = (.performDefaultHandling, nil)
    }

    completionHandler(evaluation.disposition, evaluation.credential)
  }

  func attemptServerTrustAuthentication(_ session: URLSession, with challenge: URLAuthenticationChallenge) -> ChallengeEvaluation {
    let host = challenge.protectionSpace.host

    guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
      let trust = challenge.protectionSpace.serverTrust
    else {
      return (.performDefaultHandling, nil)
    }

    guard let evaluator = session.serverTrustPolicyManager?.serverTrustPolicy(forHost: host) else {
      return (.performDefaultHandling, nil)
    }

    if evaluator.evaluate(trust, forHost: host) {
      return (.useCredential, URLCredential(trust: trust))
    } else {
      return (.cancelAuthenticationChallenge, nil)
    }
  }

  func attemptCredentialAuthentication(for challenge: URLAuthenticationChallenge) -> ChallengeEvaluation {
    guard challenge.previousFailureCount == 0 else {
      return (.rejectProtectionSpace, nil)
    }

    guard let credential = stateProvider?.credential(in: challenge.protectionSpace) else {
      return (.performDefaultHandling, nil)
    }

    return (.useCredential, credential)
  }
}

extension ImageDownloader: SessionStateProvider {
  func credential(in protectionSpace: URLProtectionSpace) -> URLCredential? {
    return self.credential
  }
}
