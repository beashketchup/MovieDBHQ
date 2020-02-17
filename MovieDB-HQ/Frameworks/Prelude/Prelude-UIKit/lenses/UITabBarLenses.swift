import Prelude
import UIKit

public protocol UITabBarProtocol: UIViewProtocol {
  var barTintColor: UIColor? { get set }
  var backgroundImage: UIImage? { get set }
}

extension UITabBar: UITabBarProtocol {}

public extension LensHolder where Object: UITabBarProtocol {
  var barTintColor: Lens<Object, UIColor?> {
    return Lens(
      view: { $0.barTintColor },
      set: { $1.barTintColor = $0; return $1 }
    )
  }
  
  var backgroundImage: Lens<Object, UIImage?> {
    return Lens(
      view: { $0.backgroundImage },
      set: { $1.backgroundImage = $0; return $1 }
    )
  }
}
