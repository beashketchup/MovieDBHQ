import Foundation

open class ServerTrustPolicyManager {
  /// The dictionary of policies mapped to a particular host.
  public let policies: [String: ServerTrustPolicy]

  public init(policies: [String: ServerTrustPolicy]) {
    self.policies = policies
  }

  open func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
    return self.policies[host]
  }
}

// MARK: -

extension URLSession {
  private struct AssociatedKeys {
    static var managerKey = "URLSession.ServerTrustPolicyManager"
  }

  var serverTrustPolicyManager: ServerTrustPolicyManager? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.managerKey) as? ServerTrustPolicyManager
    }
    set(manager) {
      objc_setAssociatedObject(self, &AssociatedKeys.managerKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

public enum ServerTrustPolicy {
  case performDefaultEvaluation(validateHost: Bool)
  case disableEvaluation

  public func evaluate(_ serverTrust: SecTrust, forHost host: String) -> Bool {
    var serverTrustIsValid = false

    switch self {
    case let .performDefaultEvaluation(validateHost):
      let policy = SecPolicyCreateSSL(true, validateHost ? host as CFString : nil)
      SecTrustSetPolicies(serverTrust, policy)

      serverTrustIsValid = self.trustIsValid(serverTrust)
    case .disableEvaluation:
      serverTrustIsValid = true
    }

    return serverTrustIsValid
  }

  // MARK: - Private - Trust Validation

  private func trustIsValid(_ trust: SecTrust) -> Bool {
    var isValid = false

    var result = SecTrustResultType.invalid
    let status = SecTrustEvaluate(trust, &result)

    if status == errSecSuccess {
      let unspecified = SecTrustResultType.unspecified
      let proceed = SecTrustResultType.proceed

      isValid = result == unspecified || result == proceed
    }

    return isValid
  }
}
