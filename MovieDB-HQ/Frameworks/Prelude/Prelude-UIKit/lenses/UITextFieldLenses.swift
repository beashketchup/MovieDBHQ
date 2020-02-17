import Prelude
import UIKit

public protocol UITextFieldProtocol: UIControlProtocol, UITextInputTraitsProtocol {
  var borderStyle: UITextBorderStyle { get set }
  var font: UIFont? { get set }
  var placeholder: String? { get set }
  var attributedPlaceholder: NSAttributedString? { get set }
  var textAlignment: NSTextAlignment { get set }
  var textColor: UIColor? { get set }
  var text: String? { get set }
  var leftViewMode: UITextField.ViewMode { get set }
  var rightView: UIView? { get set }
  var rightViewMode: UITextField.ViewMode { get set }
  var clearButtonMode: UITextField.ViewMode { get set }
}

extension UITextField: UITextFieldProtocol {}

public extension LensHolder where Object: UITextFieldProtocol {

  var borderStyle: Lens<Object, UITextBorderStyle> {
    return Lens(
      view: { $0.borderStyle },
      set: { $1.borderStyle = $0; return $1 }
    )
  }

  var font: Lens<Object, UIFont?> {
    return Lens(
      view: { $0.font },
      set: { $1.font = $0; return $1 }
    )
  }

  var placeholder: Lens<Object, String?> {
    return Lens(
      view: { $0.placeholder },
      set: { $1.placeholder = $0; return $1 }
    )
  }
  
  var attributedPlaceholder: Lens<Object, NSAttributedString?> {
    return Lens(
      view: { $0.attributedPlaceholder },
      set: { $1.attributedPlaceholder = $0; return $1 }
    )
  }

  var textAlignment: Lens<Object, NSTextAlignment> {
    return Lens(
      view: { $0.textAlignment },
      set: { $1.textAlignment = $0; return $1 }
    )
  }

  var textColor: Lens<Object, UIColor?> {
    return Lens(
      view: { $0.textColor },
      set: { $1.textColor = $0; return $1 }
    )
  }

  var text: Lens<Object, String?> {
    return Lens(
      view: { $0.text },
      set: { $1.text = $0; return $1 }
    )
  }
  
  var leftViewMode: Lens<Object, UITextField.ViewMode> {
    return Lens(
      view: { $0.leftViewMode },
      set: { $1.leftViewMode = $0; return $1 }
    )
  }
  
  var rightView: Lens<Object, UIView?> {
    return Lens(
      view: { $0.rightView },
      set: { $1.rightView = $0; return $1 }
    )
  }
  
  var rightViewMode: Lens<Object, UITextField.ViewMode> {
    return Lens(
      view: { $0.rightViewMode },
      set: { $1.rightViewMode = $0; return $1 }
    )
  }
  
  var clearButtonMode: Lens<Object, UITextField.ViewMode> {
    return Lens(
      view: { $0.clearButtonMode },
      set: { $1.clearButtonMode = $0; return $1 }
    )
  }
}
