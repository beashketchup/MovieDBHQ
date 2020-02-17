import MovieLibrary
import UIKit

internal enum Storyboard: String {
  case Result
  case ResultDetail

  internal func instantiate<VC: UIViewController>(
    _: VC.Type,
    inBundle bundle: Bundle = .framework
  ) -> VC {
    guard
      let vc = UIStoryboard(name: self.rawValue, bundle: Bundle(identifier: bundle.identifier))
      .instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC
    else { fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)") }

    return vc
  }
}
