import MovieApi
import MovieLibrary
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

internal final class MovieCell: UITableViewCell, ValueCell {
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var yearLabel: UILabel!
  @IBOutlet private var rootView: UIView!
  @IBOutlet private var movieImageView: UIImageView!

  internal let viewModel: MovieCellViewModelType = MovieCellViewModel()

  internal func configureWith(value: Movie) {
    self.viewModel.inputs.configureWith(movie: value)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.titleLabel.rac.text = self.viewModel.outputs.title
    self.yearLabel.rac.text = self.viewModel.outputs.date.map { "Release Date: \($0)" }

    self.viewModel.outputs.imageURL
      .observeForUI()
      .on(event: { [weak movieImageView] _ in
        movieImageView?.bns_cancelImageRequest()
        movieImageView?.image = nil
      })
      .observeValues { [weak movieImageView] url in
        movieImageView?.bns_setImage(withURL: url)
      }
    }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> tableViewCellStyle

    _ = self.contentView
      |> UIView.lens.backgroundColor .~ .clear

    _ = self.rootView
      |> rootViewStyle

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.yearLabel
      |> subLabelStyle
    
    _ = self.movieImageView
      |> movieImageStyle
  }
}

private let titleLabelStyle = UILabel.lens.font .~ UIFont.bns_medium.footnote
  <> UILabel.lens.textColor .~ .bns_white
  <> UILabel.lens.numberOfLines .~ 2
  <> UILabel.lens.lineBreakMode .~ .byTruncatingTail

private let subLabelStyle = UILabel.lens.font .~ UIFont.bns_medium.caption2
  <> UILabel.lens.textColor .~ .bns_dim_gray

private let movieImageStyle = UIImageView.lens.contentMode .~ .scaleAspectFill
