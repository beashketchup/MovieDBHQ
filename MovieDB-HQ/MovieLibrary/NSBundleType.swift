import MovieApi
import Foundation

public enum BnsBundleIdentifier: String {
  case debug = "com.bk.HQ.debug"
  case release = "com.bk.HQ"
}

public protocol NSBundleType {
  var bundleIdentifier: String? { get }
  static func create(path: String) -> NSBundleType?
  func path(forResource name: String?, ofType ext: String?) -> String?
  func localizedString(forKey key: String, value: String?, table tableName: String?) -> String
  var infoDictionary: [String: Any]? { get }
}

extension NSBundleType {
  public var identifier: String {
    return self.infoDictionary?["CFBundleIdentifier"] as? String ?? "Unknown"
  }

  public var shortVersionString: String {
    return self.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  }

  public var version: String {
    return self.infoDictionary?["CFBundleVersion"] as? String ?? "0"
  }

  public var appVersionString: String {
    let versionString = self.shortVersionString
    let build = self.isRelease ? "" : " #\(self.version)"
    return "\(versionString)\(build)"
  }

  public var isDebug: Bool {
    return self.identifier == BnsBundleIdentifier.debug.rawValue
  }
  
  public var isRelease: Bool {
    return self.identifier == BnsBundleIdentifier.release.rawValue
  }

  public var BnsBundleId: BnsBundleIdentifier? {
    return BnsBundleIdentifier(rawValue: self.identifier)
  }
}

extension Bundle: NSBundleType {
  public static func create(path: String) -> NSBundleType? {
    return Bundle(path: path)
  }
}
