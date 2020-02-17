import MovieApi
import MovieLibrary
import UIKit

internal final class MovieDataSource: ValueCellDataSource {
  internal enum Section: Int {
    case Movie
  }

  internal func load(movies: [Movie]) {
    self.set(values: movies, cellClass: MovieCell.self, inSection: Section.Movie.rawValue)
  }

  internal override func configureCell(tableCell cell: UITableViewCell, withValue value: Any) {
    switch (cell, value) {
    case let (cell as MovieCell, value as Movie):
      cell.configureWith(value: value)
    default:
      assertionFailure("Unrecognized (\(type(of: cell)), \(type(of: value))) combo.")
    }
  }

  internal func movieAtIndexPath(_ indexPath: IndexPath) -> Movie? {
    guard !self.isEmpty, let data = self[indexPath] as? Movie else { return nil }
    return data
  }
}
