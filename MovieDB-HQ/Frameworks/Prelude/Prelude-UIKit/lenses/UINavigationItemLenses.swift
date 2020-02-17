import Prelude
import UIKit

public protocol UINavigationItemProtocol: KSObjectProtocol {
  var title: String? { get set }
  var titleView: UIView? { get set }
  var hidesBackButton: Bool { get set }
}

extension UINavigationItem: UINavigationItemProtocol {}

public extension LensHolder where Object: UINavigationItemProtocol {
  var title: Lens<Object, String?> {
    return Lens(
      view: { $0.title },
      set: { $1.title = $0; return $1 }
    )
  }
  
  var titleView: Lens<Object, UIView?> {
    return Lens(
      view: { $0.titleView },
      set: { $1.titleView = $0; return $1 }
    )
  }
  
  var hidesBackButton: Lens<Object, Bool> {
    return Lens(
      view: { $0.hidesBackButton },
      set: { $1.hidesBackButton = $0; return $1 }
    )
  }
}
