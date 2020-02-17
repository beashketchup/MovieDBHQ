import MovieFramework
import MovieLibrary
import Prelude
import ReactiveSwift
import UIKit

internal final class MainViewController: UIViewController {

  @IBOutlet private var reachabilityTextTopConstraint: NSLayoutConstraint!
  @IBOutlet private var customViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet private var customView: UIView!
  @IBOutlet private var reachabilityText: UILabel!

  private var isCustomBarOpen: Bool = false
  private let viewModel: MainViewModelType = MainViewModel()

  internal override func viewDidLoad() {
    super.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.reachability
      .observeForUI()
      .observeValues { [weak self] in
        $0 == .none ? self?.noConnection() : self?.backOnline()
      }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.reachabilityText
      |> UILabel.lens.numberOfLines .~ Int(1)
      |> UILabel.lens.textColor .~ .bns_white
      |> UILabel.lens.textAlignment .~ .center
      |> UILabel.lens.font .~ UIFont.bns_regular.footnote
      |> UILabel.lens.layer.shadowColor .~ UIColor.bns_black.withAlphaComponent(0.3).cgColor
      |> UILabel.lens.layer.shadowOffset .~ CGSize(width: 0, height: 1)
      |> UILabel.lens.layer.shadowOpacity .~ Float(1.0)
      |> UILabel.lens.layer.shadowRadius .~ CGFloat(1.0)
  }

  private func noConnection() {
    self.animateColor(.bns_red)
    self.reachabilityText.text = "No Connection"
    NSObject.cancelPreviousPerformRequests(withTarget: self)
    if !self.isCustomBarOpen {
      self.animateView(true)
    }
  }

  private func backOnline() {
    self.animateColor(.bns_green)
    self.reachabilityText.text = "Back Online"
    NSObject.cancelPreviousPerformRequests(withTarget: self)
    if !self.isCustomBarOpen {
      self.animateView(true)
    }
    perform(#selector(self.animateView(_:)), with: false, afterDelay: 3.0)
  }

  @objc private func animateView(_ status: Bool) {

    let heightConstant: CGFloat = status ? (AppEnvironment.current.device.hasTopNotch ? 64.0 : 44.0) : 0
    let topConstant: CGFloat = status ? (AppEnvironment.current.device.hasTopNotch ? 44.0 : 24.0) : 0

    self.customViewHeightConstraint.constant = heightConstant
    self.reachabilityTextTopConstraint.constant = topConstant

    UIView.animate(
      withDuration: 0.5,
      delay: 0.1,
      options: .curveEaseOut,
      animations: {
        self.view.layoutIfNeeded()
      }, completion: nil
    )
  }

  private func animateColor(_ color: UIColor) {
    self.customView.backgroundColor = color
  }
}
