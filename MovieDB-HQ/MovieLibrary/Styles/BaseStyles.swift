import Prelude
import Prelude_UIKit
import UIKit

public enum Styles {
  public static let cornerRadius: CGFloat = 4.0

  public static func grid(_ count: Int) -> CGFloat {
    return 6.0 * CGFloat(count)
  }

  public static func gridHalf(_ count: Int) -> CGFloat {
    return self.grid(count) / 2.0
  }
}

public typealias ButtonStyle = (UIButton) -> UIButton
public typealias ImageViewStyle = (UIImageView) -> UIImageView
public typealias LabelStyle = (UILabel) -> UILabel
public typealias LayerStyle = (CALayer) -> CALayer
public typealias ScrollStyle = (UIScrollView) -> UIScrollView
public typealias SwitchControlStyle = (UISwitch) -> UISwitch
public typealias TableViewStyle = (UITableView) -> UITableView
public typealias TextFieldStyle = (UITextField) -> UITextField
public typealias TextViewStyle = (UITextView) -> UITextView
public typealias ToolbarStyle = (UIToolbar) -> UIToolbar
public typealias TabBarStyle = (UITabBar) -> UITabBar
public typealias TabBarItemStyle = (UITabBarItem) -> UITabBarItem
public typealias ViewStyle = (UIView) -> UIView
public typealias ActivityStyle = (UIActivityIndicatorView) -> UIActivityIndicatorView

public func transparentNavControllerStyle<VC: UIViewControllerProtocol>() -> ((VC) -> VC) {
  return VC.lens.view.backgroundColor .~ .white
    <> (VC.lens.navigationController .. navBarLens) %~ { $0.map(transparentNavigationBarStyle) }
}

public func roundedStyle<V: UIViewProtocol>(cornerRadius r: CGFloat = Styles.cornerRadius) -> ((V) -> V) {
  return V.lens.clipsToBounds .~ true
    <> V.lens.layer.masksToBounds .~ true
    <> V.lens.layer.cornerRadius .~ r
}

public let rootViewStyle = roundedStyle(cornerRadius: 8)
  <> UIView.lens.backgroundColor .~ UIColor.bns_dark_gray.withAlphaComponent(0.2)

public let notesTextViewStyle = UITextView.lens.layer.cornerRadius .~ CGFloat(5.0)
  <> UITextView.lens.backgroundColor .~ .clear
  <> UITextView.lens.font .~ UIFont.bns_regular.footnote
  <> UITextView.lens.layer.borderColor .~ UIColor.bns_dark_gray.cgColor
  <> UITextView.lens.layer.borderWidth .~ CGFloat(1.0)
  <> UITextView.lens.textColor .~ .bns_dim_gray
  <> UITextView.lens.textContainerInset .~ UIEdgeInsets(top: 8.0, left: 5.0, bottom: 0.0, right: 0.0)

public func navigationControllerStyle(for title: String? = nil) -> ((UIViewController) -> UIViewController) {
  return transparentNavControllerStyle()
    <> UIViewController.lens.title %~ { _ in
      title
    }
}

public func textFieldAttributedString(_ string: String, _ color: UIColor) -> NSAttributedString {
  return NSAttributedString(
    string: string,
    attributes: [NSAttributedString.Key.foregroundColor: color]
  )
}

public let tableViewCellStyle = UITableViewCell.lens.selectionStyle .~ .none
  <> UITableViewCell.lens.backgroundColor .~ .clear

public func baseTableViewStyle(estimatedRowHeight: CGFloat = 44.0)
  -> ((UITableView) -> UITableView) {
  return UITableView.lens.backgroundColor .~ UIColor.bns_black.withAlphaComponent(0.3)
    <> UITableView.lens.rowHeight .~ UITableView.automaticDimension
    <> UITableView.lens.estimatedRowHeight .~ estimatedRowHeight
}

public let whiteActivityIndicatorStyle: ActivityStyle = { (activity: UIActivityIndicatorView) in
  activity
    |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
    |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
}

public let hideBackButtonStyle = UINavigationItem.lens.hidesBackButton .~ true

public let backgroundImageViewStyle = UIImageView.lens.image .~ UIImage(name: .background)
  <> UIImageView.lens.contentMode .~ .scaleAspectFill

// MARK: - Private Helpers

private let navBarLens: Lens<UINavigationController?, UINavigationBar?> = Lens(
  view: { $0?.navigationBar },
  set: { _, whole in whole }
)

public let transparentNavigationBarStyle =
  UINavigationBar.lens.shadowImage .~ UIImage()
  <> UINavigationBar.lens.barTintColor .~ .clear
  <> UINavigationBar.lens.isTranslucent .~ true
  <> UINavigationBar.lens.tintColor .~ .bns_orange
  <> UINavigationBar.lens.backgroundImage(for: .default) .~ UIImage()
  <> UINavigationBar.lens.titleTextAttributes .~ [
    NSAttributedString.Key.foregroundColor: UIColor.bns_dim_gray,
    NSAttributedString.Key.font: UIFont.bns_medium.headline
  ]
