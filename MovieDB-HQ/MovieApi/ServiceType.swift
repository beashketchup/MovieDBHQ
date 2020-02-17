import Prelude
import Foundation
import ReactiveSwift

/**
 A type that knows how to perform requests for API data.
 */
public protocol ServiceType {
  var appId: String { get }
  var serverConfig: ServerConfigType { get }
  var language: String { get }
  var buildVersion: String { get }
  var session: URLSession { get }
  
  init(
    appId: String,
    serverConfig: ServerConfigType,
    language: String,
    buildVersion: String
  )
  
  func fetchPlayingNow(for query: [String: String])
    -> SignalProducer<MovieEnvelope, ErrorEnvelope>
  
  func fetchSimilarMovies(for movieId: Int, query: [String: String])
    -> SignalProducer<MovieEnvelope, ErrorEnvelope>
}

public func == (lhs: ServiceType, rhs: ServiceType) -> Bool {
  return
    type(of: lhs) == type(of: rhs) &&
      lhs.serverConfig == rhs.serverConfig &&
      lhs.language == rhs.language &&
      lhs.buildVersion == rhs.buildVersion
}

public func != (lhs: ServiceType, rhs: ServiceType) -> Bool {
  return !(lhs == rhs)
}

extension ServiceType {
  public func preparedRequest(forRequest originalRequest: URLRequest, query: [String: String])
    -> URLRequest {
      var request = originalRequest
      guard let URL = request.url else {
        return originalRequest
      }
      
      var components = URLComponents(url: URL, resolvingAgainstBaseURL: false)!
      var queryItems = components.queryItems ?? []
      queryItems.append(contentsOf: self.defaultQueryParams.map(URLQueryItem.init(name:value:)))
      queryItems.append(contentsOf: query.map(URLQueryItem.init(name:value:)))
      
      components.queryItems = queryItems.sorted { $0.name < $1.name }
      request.url = components.url
      request.allHTTPHeaderFields = self.defaultHeaders
      
      return request
  }
  
  public func preparedRequest(forURL url: URL, query: [String: String])
    -> URLRequest {
      var request = URLRequest(url: url)
      request.httpMethod = Method.GET.rawValue
      return self.preparedRequest(forRequest: request, query: query)
  }
  
  fileprivate var defaultHeaders: [String: String] {
    var headers: [String: String] = [:]
    headers["Accept-Language"] = self.language
    headers["User-Agent"] = Self.userAgent
    
    return headers
  }
  
  public static var userAgent: String {
    let executable = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
    let bundleIdentifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    let app: String = executable ?? bundleIdentifier ?? "BnS"
    let bundleVersion: String = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
    let model = UIDevice.current.model
    let systemVersion = UIDevice.current.systemVersion
    let scale = UIScreen.main.scale
    
    return "\(app)/\(bundleVersion) (\(model); iOS \(systemVersion) Scale/\(scale))"
  }
  
  private var defaultQueryParams: [String: String] {
    var query: [String: String] = [:]
    query["api_key"] = Secrets.Api.TMDB.key
    query["language"] = "en-US"
    return query
  }
}

extension NSNumber {
  fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

