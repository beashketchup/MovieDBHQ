import Prelude
import SnapKit
import UIKit

internal final class LoadingView: UIView, NibLoading {

  @IBOutlet private var ovalImage: UIImageView!

  internal static func instantiate() -> LoadingView {
    guard let newView = LoadingView.fromNib(nib: .LoadingView) else {
      fatalError("failed to load LoadingView from Nib")
    }
    return newView
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func bindViewModel() {
    super.bindViewModel()

    NotificationCenter.default.addObserver(
      self, selector: #selector(self.restartAnimation(_:)),
      name: UIApplication.willEnterForegroundNotification, object: nil
    )
  }

  override func bindStyles() {
    super.bindStyles()

    self.snp.makeConstraints { (make: ConstraintMaker) in
      make.top.bottom.equalToSuperview().offset(0.0)
      make.leading.trailing.equalToSuperview().offset(0.0)
    }

    _ = self
      |> UIView.lens.backgroundColor .~ UIColor.bns_black.withAlphaComponent(0.75)
      |> UIView.lens.isUserInteractionEnabled .~ true

    _ = self.ovalImage
      |> UIImageView.lens.image .~ UIImage(name: .ovalArc)?.withRenderingMode(.alwaysTemplate)
      |> UIImageView.lens.tintColor .~ .bns_white

    UIView.infiniteRotateAnimation(self.ovalImage, duration: 1.0)
  }

  @objc private func restartAnimation(_ notification: Notification) {
    UIView.infiniteRotateAnimation(self.ovalImage, duration: 1.0)
  }
}
