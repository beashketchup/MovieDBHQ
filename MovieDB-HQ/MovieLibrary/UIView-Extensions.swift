import UIKit

private func swizzle(_ v: UIView.Type) {

  [
    (#selector(v.traitCollectionDidChange(_:)), #selector(v.bns_traitCollectionDidChange(_:))),
    (#selector(v.layoutSubviews), #selector(v.bns_layoutSubviews))
  ].forEach { original, swizzled in

    guard let originalMethod = class_getInstanceMethod(v, original),
      let swizzledMethod = class_getInstanceMethod(v, swizzled) else { return }

    let didAddViewDidLoadMethod = class_addMethod(
      v,
      original,
      method_getImplementation(swizzledMethod),
      method_getTypeEncoding(swizzledMethod)
    )

    if didAddViewDidLoadMethod {
      class_replaceMethod(
        v,
        swizzled,
        method_getImplementation(originalMethod),
        method_getTypeEncoding(originalMethod)
      )
    } else {
      method_exchangeImplementations(originalMethod, swizzledMethod)
    }
  }
}

private var hasSwizzled = false

extension UIView {
  public final class func doBadSwizzleStuff() {
    guard !hasSwizzled else { return }

    hasSwizzled = true
    swizzle(self)
  }

  open override func awakeFromNib() {
    super.awakeFromNib()
    self.bindViewModel()
  }

  @objc open func bindStyles() {}

  @objc open func bindViewModel() {}

  private struct AssociatedKeys {
    static var hasLayoutSubviewsCalled = "hasLayoutSubviewsCalled"
  }

  // Helper to figure out if the `layoutSubviews` has been called yet
  private var hasLayoutSubviewsCalled: Bool {
    get {
      return (objc_getAssociatedObject(self, &AssociatedKeys.hasLayoutSubviewsCalled) as? Bool) ?? false
    }
    set {
      objc_setAssociatedObject(
        self,
        &AssociatedKeys.hasLayoutSubviewsCalled,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }

  public static var defaultReusableId: String {
    return self.description()
      .components(separatedBy: ".")
      .dropFirst()
      .joined(separator: ".")
  }

  @objc internal func bns_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection) {
    self.bns_traitCollectionDidChange(previousTraitCollection)
    self.bindStyles()
  }

  @objc internal func bns_layoutSubviews() {
    self.bns_layoutSubviews()

    if !self.hasLayoutSubviewsCalled {
      self.bindStyles()
      self.hasLayoutSubviewsCalled = true
    }
  }
}
