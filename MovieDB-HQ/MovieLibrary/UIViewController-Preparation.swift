import ObjectiveC
import UIKit

private func swizzle(_ vc: UIViewController.Type) {

  [
    (#selector(vc.viewDidLoad), #selector(vc.bns_viewDidLoad)),
    (#selector(vc.viewWillAppear(_:)), #selector(vc.bns_viewWillAppear(_:))),
    (#selector(vc.traitCollectionDidChange(_:)), #selector(vc.bns_traitCollectionDidChange(_:)))
  ].forEach { original, swizzled in

    guard let originalMethod = class_getInstanceMethod(vc, original),
      let swizzledMethod = class_getInstanceMethod(vc, swizzled) else { return }

    let didAddViewDidLoadMethod = class_addMethod(
      vc,
      original,
      method_getImplementation(swizzledMethod),
      method_getTypeEncoding(swizzledMethod)
    )

    if didAddViewDidLoadMethod {
      class_replaceMethod(
        vc,
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

extension UIViewController {
  public final class func doBadSwizzleStuff() {
    guard !hasSwizzled else { return }

    hasSwizzled = true
    swizzle(self)
  }

  @objc internal func bns_viewDidLoad() {
    self.bns_viewDidLoad()
    self.bindViewModel()
  }

  @objc internal func bns_viewWillAppear(_ animated: Bool) {
    self.bns_viewWillAppear(animated)

    if !self.hasViewAppeared {
      self.bindStyles()
      self.hasViewAppeared = true
    }
  }

  /**
   The entry point to bind all view model outputs. Called just before `viewDidLoad`.
   */
  @objc open func bindViewModel() {}

  /**
   The entry point to bind all styles to UI elements. Called just after `viewDidLoad`.
   */
  @objc open func bindStyles() {}

  @objc public func bns_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    self.bns_traitCollectionDidChange(previousTraitCollection)
    self.bindStyles()
  }

  private struct AssociatedKeys {
    static var hasViewAppeared = "hasViewAppeared"
  }

  // Helper to figure out if the `viewWillAppear` has been called yet
  private var hasViewAppeared: Bool {
    get {
      return (objc_getAssociatedObject(self, &AssociatedKeys.hasViewAppeared) as? Bool) ?? false
    }
    set {
      objc_setAssociatedObject(
        self,
        &AssociatedKeys.hasViewAppeared,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }
}

extension UIViewController {
  public static var defaultNib: String {
    return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
  }

  public static var storyboardIdentifier: String {
    return self.description().components(separatedBy: ".").dropFirst().joined(separator: ".")
  }
}
