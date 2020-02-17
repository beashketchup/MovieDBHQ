import UIKit

public func image(
  named name: String,
  inBundle bundle: NSBundleType = AppEnvironment.current.mainBundle,
  compatibleWithTraitCollection traitCollection: UITraitCollection? = nil
) -> UIImage? {
  return UIImage(named: name, in: Bundle(identifier: bundle.identifier), compatibleWith: traitCollection)
}

public func image(
  named name: String,
  inBundle bundle: NSBundleType = AppEnvironment.current.mainBundle,
  compatibleWithTraitCollection traitCollection: UITraitCollection? = nil,
  alpha: CGFloat = 1.0
) -> UIImage? {
  return image(
    named: name,
    inBundle: bundle,
    compatibleWithTraitCollection: traitCollection
  )?.alpha(alpha)
}

extension UIImage {
  fileprivate func alpha(_ value: CGFloat) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    draw(at: CGPoint.zero, blendMode: .normal, alpha: value)

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
}
