import UIKit

public extension UIViewController {

  func present(
    _ viewControllerToPresent: UIViewController?,
    animated flag: Bool,
    completion: (() -> Void)? = nil
  ) {

    guard let _controller = viewControllerToPresent else { return }
    present(_controller, animated: flag, completion: completion)
  }
}

extension UIViewController: UIPopoverPresentationControllerDelegate {

  public func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
