import UIKit

internal extension UIView {
  private static let loader = LoadingView.instantiate()

  static func showFullScreenLoaderNoBackground() {
    DispatchQueue.main.async {
      loader.removeFromSuperview()
      let window = UIApplication.shared.windows[0]
      window.addSubview(loader)
    }
  }

  static func removeLoader() {
    DispatchQueue.main.async {
      loader.removeFromSuperview()
    }
  }
}
