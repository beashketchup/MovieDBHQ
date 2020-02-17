import Prelude
import UIKit

public protocol UIProgressViewProtocol: UIViewProtocol {
  var progressViewStyle: UIProgressViewStyle { get set }
  var progress: Float { get set }
  var progressTintColor: UIColor? { get set }
  var trackTintColor: UIColor? { get set }
}

extension UIProgressView: UIProgressViewProtocol {}

public extension LensHolder where Object: UIProgressViewProtocol {

  var progressViewStyle: Lens<Object, UIProgressViewStyle> {
    return Lens(
      view: { $0.progressViewStyle },
      set: { $1.progressViewStyle = $0; return $1 }
    )
  }

  var progress: Lens<Object, Float> {
    return Lens(
      view: { $0.progress },
      set: { $1.progress = $0; return $1 }
    )
  }
  
  var progressTintColor: Lens<Object, UIColor?> {
    return Lens(
      view: { $0.progressTintColor },
      set: { $1.progressTintColor = $0; return $1 }
    )
  }
  
  var trackTintColor: Lens<Object, UIColor?> {
    return Lens(
      view: { $0.trackTintColor },
      set: { $1.trackTintColor = $0; return $1 }
    )
  }
}
