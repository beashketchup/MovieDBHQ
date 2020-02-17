import MovieApi
import MovieLibrary
import Prelude
import ReactiveSwift
import UIKit

public final class ResultViewController: UIViewController {
  
  @IBOutlet private var backgroundImageView: UIImageView!
  @IBOutlet private var movieTableView: UITableView!
  
  private let viewModel: ResultViewModelType = ResultViewModel()
  private let dataSource = MovieDataSource()
  
  private var hasPages: Bool = false
  
  public static func instantiate() -> ResultViewController {
    return Storyboard.Result.instantiate(ResultViewController.self)
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
    
    UIView.showFullScreenLoaderNoBackground()
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }
  
  override public func bindStyles() {
    
    _ = self |> navigationControllerStyle(for: "Movies".uppercased())
    
    _ = self.view |> UIView.lens.backgroundColor .~ .black
    
    _ = self.movieTableView |> tableViewStyle
    
    _ = self.backgroundImageView |> backgroundImageViewStyle
    
    self.movieTableView.rowHeight = UITableView.automaticDimension
    self.movieTableView.estimatedRowHeight = 100
  }
  
  override public func bindViewModel() {
    super.bindViewModel()
    
    self.movieTableView.register(nib: .MovieCell)
    
    self.movieTableView.dataSource = self.dataSource
    self.movieTableView.delegate = self
    
    self.viewModel.outputs.hasDataLoaded
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.load(movies: $0)
        self?.movieTableView.reloadData()
        UIView.removeLoader()
    }
    
    self.viewModel.outputs.dataLoadFailed
      .observeForUI()
      .observeValues { [weak self] in
        self?.present(UIAlertController.requestError($0), animated: true)
        UIView.removeLoader()
    }
    
    self.viewModel.outputs.havePages
      .observeValues { [weak self] in
        self?.hasPages = $0
    }
  }
}

extension ResultViewController: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let totalLeft = scrollView.contentSize.height - scrollView.bounds.size.height
    if scrollView.contentSize.height > scrollView.bounds.size.height,
      totalLeft * 0.8 < scrollView.contentOffset.y,
      self.hasPages {
      self.viewModel.inputs.nextPage()
      self.hasPages = false
    }
  }
}

extension ResultViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = ResultDetailViewController.instantiate(for: self.dataSource.movieAtIndexPath(indexPath))
    self.navigationController?.push(vc, animated: true)
  }
}

private let tableViewStyle = UITableView.lens.backgroundColor .~ .clear
  <> UITableView.lens.separatorStyle .~ .none
