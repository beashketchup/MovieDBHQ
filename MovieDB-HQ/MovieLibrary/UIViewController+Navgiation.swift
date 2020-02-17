import UIKit

public extension UINavigationController {

  func push(
    _ viewController: UIViewController?,
    animated: Bool
  ) {

    guard let _controller = viewController else { return }
    pushViewController(_controller, animated: animated)
  }
}
