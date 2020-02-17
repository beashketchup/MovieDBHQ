import Foundation

/**
 A type that knows the location of a MyDoc API and web server.
 */
public protocol ServerConfigType {
  var apiBaseUrl: URL { get }
  var environment: EnvironmentType { get }
  var serverTrustPolicyManager: ServerTrustPolicyManager { get }
}

public func == (lhs: ServerConfigType, rhs: ServerConfigType) -> Bool {
  return
    type(of: lhs) == type(of: rhs) &&
    lhs.apiBaseUrl == rhs.apiBaseUrl &&    
    lhs.environment == rhs.environment
}

public enum EnvironmentType: String {
  public static let allCases: [EnvironmentType] = [.production, .staging, .local]

  case production = "Production"
  case staging = "Staging"
  case local = "Local"
}

public struct ServerConfig: ServerConfigType {
  public private(set) var apiBaseUrl: URL
  public private(set) var environment: EnvironmentType
  public private(set) var serverTrustPolicyManager: ServerTrustPolicyManager

  public static let production: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.production)")!,
    environment: EnvironmentType.production,
    serverTrustPolicyManager: ServerTrustPolicyManager(policies: Secrets.Api.policy)
  )

  public static let staging: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.staging)")!,
    environment: EnvironmentType.staging,
    serverTrustPolicyManager: ServerTrustPolicyManager(policies: Secrets.Api.policy)
  )

  public static let local: ServerConfigType = ServerConfig(
    apiBaseUrl: URL(string: "https://\(Secrets.Api.Endpoint.local)")!,
    environment: EnvironmentType.local,
    serverTrustPolicyManager: ServerTrustPolicyManager(policies: Secrets.Api.policy)
  )

  public init(
    apiBaseUrl: URL,
    environment: EnvironmentType = .production,
    serverTrustPolicyManager: ServerTrustPolicyManager
  ) {
    self.apiBaseUrl = apiBaseUrl
    self.environment = environment
    self.serverTrustPolicyManager = serverTrustPolicyManager
  }

  public static func config(for environment: EnvironmentType) -> ServerConfigType {
    switch environment {
    case .local:
      return ServerConfig.local
    case .staging:
      return ServerConfig.staging
    case .production:
      return ServerConfig.production
    }
  }

  public static func updateApiBaseUrl(with url: String, for config: ServerConfigType) -> ServerConfigType {
    return ServerConfig(
      apiBaseUrl: URL(string: "http://\(url)")!,
      environment: config.environment,
      serverTrustPolicyManager: config.serverTrustPolicyManager
    )
  }
}
