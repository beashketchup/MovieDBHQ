import Prelude
import UIKit

public protocol UINavigationBarProtocol: UIViewProtocol {
  func backgroundImage(for barMetrics: UIBarMetrics) -> UIImage?
  var barStyle: UIBarStyle { get set }
  var barTintColor: UIColor? { get set }
  func setBackgroundImage(_ backgroundImage: UIImage?, for barMetrics: UIBarMetrics)
  var shadowImage: UIImage? { get set }
  var titleTextAttributes: [NSAttributedStringKey: Any]? { get set }
  var isTranslucent: Bool { get set }
}

public extension LensHolder where Object: UINavigationBarProtocol {
  func backgroundImage(for barMetrics: UIBarMetrics) -> Lens<Object, UIImage?> {
    return Lens(
      view: { $0.backgroundImage(for: barMetrics) },
      set: { $1.setBackgroundImage($0, for: barMetrics); return $1 }
    )
  }

  var barTintColor: Lens<Object, UIColor?> {
    return Lens(
      view: { $0.barTintColor },
      set: { $1.barTintColor = $0; return $1; }
    )
  }
  
  var barStyle: Lens<Object, UIBarStyle> {
    return Lens(
      view: { $0.barStyle },
      set: { $1.barStyle = $0; return $1; }
    )
  }

  var isTranslucent: Lens<Object, Bool> {
    return Lens(
      view: { $0.isTranslucent },
      set: { $1.isTranslucent = $0; return $1; }
    )
  }

  var shadowImage: Lens<Object, UIImage?> {
    return Lens(
      view: { $0.shadowImage },
      set: { $1.shadowImage = $0; return $1; }
    )
  }

  var titleTextAttributes: Lens<Object, [NSAttributedStringKey: Any]> {
    return Lens(
      view: { $0.titleTextAttributes ?? [:] },
      set: { $1.titleTextAttributes = $0; return $1; }
    )
  }
}
