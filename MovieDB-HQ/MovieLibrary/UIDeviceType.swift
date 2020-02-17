import UIKit

/**
 *  A type that behaves like a UIDevice.
 */
public protocol UIDeviceType {
  var identifierForVendor: UUID? { get }
  var modelCode: String { get }
  var deviceOS: String { get }
  var systemName: String { get }
  var systemVersion: String { get }
  var userInterfaceIdiom: UIUserInterfaceIdiom { get }
  var hasTopNotch: Bool { get }
  var hasBottomSafeAreaInsets: Bool { get }
  var safeAreaInsets: UIEdgeInsets { get }
}

extension UIDevice: UIDeviceType {
  public var modelCode: String {
    var size: Int = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](repeating: 0, count: Int(size))
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String(cString: machine)
  }

  public var deviceOS: String {
    return self.systemName + " " + self.systemVersion
  }

  public var hasTopNotch: Bool {
    // with notch: 44.0 on iPhone X, XS, XS Max, XR.
    // without notch: 24.0 on iPad Pro 12.9" 3rd generation, 20.0 on iPhone 8 on iOS 12+.
    return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
  }

  public var hasBottomSafeAreaInsets: Bool {
    // with home indicator: 34.0 on iPhone X, XS, XS Max, XR.
    // with home indicator: 20.0 on iPad Pro 12.9" 3rd generation.
    return UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0 > 0
  }

  public var safeAreaInsets: UIEdgeInsets {
    return UIApplication.shared.delegate?.window??.safeAreaInsets ?? UIEdgeInsets()
  }

  public static var widthScaleFactor: CGFloat {
    return UIScreen.main.bounds.width / 375.0
  }

  public static var heightScaleFactor: CGFloat {
    return UIScreen.main.bounds.height / 812.0
  }
}

internal struct MockDevice: UIDeviceType {
  internal let identifierForVendor = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF")
  internal let modelCode = "MockmodelCode"
  internal let systemName = "MockSystemName"
  internal let systemVersion: String = "MockSystemVersion"
  internal let userInterfaceIdiom: UIUserInterfaceIdiom
  internal let deviceOS = "iOS 12"
  internal let hasTopNotch = true
  internal let hasBottomSafeAreaInsets = true
  internal let safeAreaInsets = UIEdgeInsets()

  internal init(userInterfaceIdiom: UIUserInterfaceIdiom = .phone) {
    self.userInterfaceIdiom = userInterfaceIdiom
  }
}
