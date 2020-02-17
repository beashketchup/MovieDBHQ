import Prelude
import ReactiveExtensions
import ReactiveSwift

public extension Bundle {
  var _buildVersion: String {
    return (self.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
  }
}

/**
 A `ServerType` that requests data from an API webservice.
 */
public struct Service: ServiceType {
  public let appId: String
  public let serverConfig: ServerConfigType
  public let language: String
  public let buildVersion: String
  public let session: URLSession

  public init(
    appId: String = Bundle.main.bundleIdentifier ?? "com.HQ.test",
    serverConfig: ServerConfigType = ServerConfig.production,
    language: String = "en",
    buildVersion: String = Bundle.main._buildVersion
  ) {
    self.appId = appId
    self.serverConfig = serverConfig
    self.language = language
    self.buildVersion = buildVersion

    self.session = URLSession(configuration: .apiConfig(), delegate: SessionDelegate.shared, delegateQueue: nil)
    self.session.serverTrustPolicyManager = serverConfig.serverTrustPolicyManager
  }
  
  public func fetchPlayingNow(for query: [String: String])
    -> SignalProducer<MovieEnvelope, ErrorEnvelope> {
      return fetch(.playingNow(query))
  }
  
  public func fetchSimilarMovies(for movieId: Int, query: [String: String])
    -> SignalProducer<MovieEnvelope, ErrorEnvelope> {
      return fetch(.similarMovies(movieId, query))
  }
}

public class SessionDelegate: NSObject {
  public static let shared = SessionDelegate()
}

extension SessionDelegate: URLSessionDelegate {
  open func urlSession(
    _ session: URLSession,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
    var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
    var credential: URLCredential?

    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
      let host = challenge.protectionSpace.host

      if
        let serverTrustPolicy = session.serverTrustPolicyManager?.serverTrustPolicy(forHost: host),
        let serverTrust = challenge.protectionSpace.serverTrust {
        if serverTrustPolicy.evaluate(serverTrust, forHost: host) {
          disposition = .useCredential
          credential = URLCredential(trust: serverTrust)
        } else {
          disposition = .cancelAuthenticationChallenge
        }
      }
    }

    completionHandler(disposition, credential)
  }
}
