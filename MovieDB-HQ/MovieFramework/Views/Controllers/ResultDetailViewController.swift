import MovieApi
import MovieLibrary
import Foundation
import Prelude
import ReactiveSwift

internal final class ResultDetailViewController: UIViewController {
  
  @IBOutlet private var backgroundImageView: UIImageView!
  @IBOutlet private var movieImageView: UIImageView!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var yearLabel: UILabel!
  @IBOutlet private var overviewLabel: UILabel!
  @IBOutlet private var relatedLabel: UILabel!
  @IBOutlet private var relatedMoveTableView: UITableView!
  
  private let viewModel: ResultDetailViewModelType = ResultDetailViewModel()
  private let dataSource = MovieDataSource()
  
  internal static func instantiate(for movie: Movie?) -> ResultDetailViewController {
    let vc = Storyboard.ResultDetail.instantiate(ResultDetailViewController.self)
    vc.viewModel.inputs.configure(for: movie)
    return vc
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
    
    UIView.showFullScreenLoaderNoBackground()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }
  
  override func bindStyles() {
    super.bindStyles()
    
    _ = self |> navigationControllerStyle(for: "Movie Details".uppercased())
    
    _ = self.view |> UIView.lens.backgroundColor .~ .black
    
    _ = self.backgroundImageView |> backgroundImageViewStyle
    
    _ = self.titleLabel
      |> titleLabelStyle
    
    _ = self.yearLabel
      |> subLabelStyle
    
    _ = self.overviewLabel
      |> subLabelStyle
    
    _ = self.movieImageView
      |> movieImageStyle
    
    _ = self.relatedLabel
      |> titleLabelStyle
      |> UILabel.lens.text .~ "Related Movies"
    
    _ = self.relatedMoveTableView |> tableViewStyle
    
    self.relatedMoveTableView.rowHeight = UITableView.automaticDimension
    self.relatedMoveTableView.estimatedRowHeight = 100
  }
  
  override func bindViewModel() {
    super.bindViewModel()
    
    self.titleLabel.rac.text = self.viewModel.outputs.title
    self.yearLabel.rac.text = self.viewModel.outputs.year
    self.overviewLabel.rac.text = self.viewModel.outputs.movieDesc
    
    self.viewModel.outputs.imageURL
      .observeForUI()
      .on(event: { [weak movieImageView] _ in
        movieImageView?.bns_cancelImageRequest()
        movieImageView?.image = nil
      })
      .observeValues { [weak movieImageView] url in
        movieImageView?.bns_setImage(withURL: url)
    }
    
    self.relatedMoveTableView.register(nib: .MovieCell)
    
    self.relatedMoveTableView.dataSource = self.dataSource
    self.relatedMoveTableView.delegate = self
    
    self.viewModel.outputs.hasDataLoaded
      .observeForUI()
      .observeValues { [weak self] in
        self?.dataSource.load(movies: $0)
        self?.relatedMoveTableView.reloadData()
        UIView.removeLoader()
    }
    
    self.viewModel.outputs.dataLoadFailed
      .observeForUI()
      .observeValues { [weak self] in
        self?.present(UIAlertController.requestError($0), animated: true)
        UIView.removeLoader()
    }
  }
}

extension ResultDetailViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = ResultDetailViewController.instantiate(for: self.dataSource.movieAtIndexPath(indexPath))
    self.navigationController?.push(vc, animated: true)
  }
}

private let titleLabelStyle = UILabel.lens.font .~ UIFont.bns_semibold.headline
  <> UILabel.lens.textColor .~ .bns_white
  <> UILabel.lens.numberOfLines .~ 2
  <> UILabel.lens.lineBreakMode .~ .byTruncatingTail

private let subLabelStyle = UILabel.lens.font .~ UIFont.bns_medium.footnote
  <> UILabel.lens.textColor .~ .bns_dim_gray
  <> UILabel.lens.numberOfLines .~ 0

private let movieImageStyle = UIImageView.lens.contentMode .~ .scaleAspectFill

private let tableViewStyle = UITableView.lens.backgroundColor .~ .clear
  <> UITableView.lens.separatorStyle .~ .none
