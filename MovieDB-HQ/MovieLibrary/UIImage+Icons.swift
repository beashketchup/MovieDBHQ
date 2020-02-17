import UIKit

public extension UIImage {
  convenience init!(name: AssetNames) {
    self.init(named: name.rawValue)
  }
}

public enum AssetNames: String {
  case background
  case ovalArc = "oval-arc"
}
