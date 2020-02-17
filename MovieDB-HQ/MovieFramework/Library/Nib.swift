import UIKit

internal enum Nib: String {
  case LoadingView
  case MovieCell  
}

extension UITableView {
  internal func register(nib: Nib, inBundle bundle: Bundle = .framework) {
    self.register(UINib(nibName: nib.rawValue, bundle: bundle), forCellReuseIdentifier: nib.rawValue)
  }

  internal func registerHeaderFooter(nib: Nib, inBundle bundle: Bundle = .framework) {
    self.register(
      UINib(nibName: nib.rawValue, bundle: bundle),
      forHeaderFooterViewReuseIdentifier: nib.rawValue
    )
  }
}

extension UICollectionView {
  internal func register(nib: Nib, inBundle bundle: Bundle = .framework) {
    self.register(UINib(nibName: nib.rawValue, bundle: bundle), forCellWithReuseIdentifier: nib.rawValue)
  }
}

protocol NibLoading {
  associatedtype CustomNibType

  static func fromNib(nib: Nib) -> CustomNibType?
}

extension NibLoading {
  static func fromNib(nib: Nib) -> Self? {
    guard let view = UINib(nibName: nib.rawValue, bundle: .framework)
      .instantiate(withOwner: self, options: nil)
      .first as? Self else {
      assertionFailure("Nib not found")
      return nil
    }

    return view
  }
}
