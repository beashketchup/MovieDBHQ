import UIKit

public extension UIView {

  static func infiniteRotateAnimation(_ view: UIView, duration: CFTimeInterval) {

    view.layer.removeAnimation(forKey: "infiniteRotateAnimation")

    let basicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
    basicAnimation.toValue = Double.pi
    basicAnimation.duration = duration
    basicAnimation.isCumulative = true
    basicAnimation.repeatCount = HUGE
    view.layer.add(basicAnimation, forKey: "infiniteRotateAnimation")
  }
}
