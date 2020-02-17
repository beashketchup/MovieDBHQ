import MovieApi
import Foundation
import class UIKit.UIAlertAction
import class UIKit.UIAlertController

public typealias AlertAction = (UIAlertAction) -> Void

public extension UIAlertController {

  static func alert(
    _ title: String? = nil,
    message: String? = nil,
    handler: AlertAction? = nil
  ) -> UIAlertController {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: "Ok",
        style: .cancel,
        handler: handler
      )
    )

    return alertController
  }

  static func requestError(_ error: ErrorEnvelope?) -> UIAlertController? {
    guard let _error = error else { return nil }

    let alertController = UIAlertController(
      title: "",
      message: _error.errorDescription,
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: "Ok",
        style: .cancel,
        handler: nil
      )
    )

    return alertController
  }

  static func actionConfirmation(for message: String, positiveActionTitle: String? = nil, _ handler: AlertAction? = nil) -> UIAlertController {
    let alertController = UIAlertController(
      title: "",
      message: message,
      preferredStyle: .alert
    )
    alertController.addAction(
      UIAlertAction(
        title: "Cancel",
        style: .cancel,
        handler: nil
      )
    )
    alertController.addAction(
      UIAlertAction(
        title: positiveActionTitle ?? "Continue",
        style: .default,
        handler: handler
      )
    )
    return alertController
  }
}
