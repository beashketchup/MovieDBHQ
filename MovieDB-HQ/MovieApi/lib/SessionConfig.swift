import Foundation

internal extension URLSessionConfiguration {
  static func apiConfig() -> URLSessionConfiguration {
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.urlCache = nil
    config.timeoutIntervalForRequest = 60
    return config
  }
}
