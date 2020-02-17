import MovieFramework
import MovieLibrary
import Prelude
import ReactiveSwift
import UIKit

internal final class LandingViewController: UIViewController {
  
  @IBOutlet private var showResult: UIButton!
  
  private var isCustomBarOpen: Bool = false
  private let viewModel: LandingViewModelType = LandingViewModel()
  
  internal override func viewDidLoad() {
    super.viewDidLoad()
    
    self.showResult.addTarget(
      self,
      action: #selector(self.showResultButtonTapped),
      for: .touchUpInside
    )
  }
  
  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.viewModel.inputs.viewWillAppear()
  }
  
  internal override func bindViewModel() {
    super.bindViewModel()
    
    self.viewModel.outputs.showResult
      .observeForUI()
      .observeValues { [weak self] in
        let vc = ResultViewController.instantiate()
        self?.navigationController?.push(vc, animated: true)
    }
  }
  
  internal override func bindStyles() {
    super.bindStyles()
    
    _ = self.showResult
      |> UIButton.lens.backgroundColor .~ .bns_orange
      |> UIButton.lens.titleColor(for: .normal) .~ .bns_white
      |> UIButton.lens.title(for: .normal) .~ "Show Result"
  }
  
  @objc fileprivate func showResultButtonTapped() {
    self.viewModel.inputs.presentResult()
  }
}
