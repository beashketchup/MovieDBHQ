import MovieApi
import Prelude
import ReactiveSwift

public protocol MovieCellViewModelInputs {
  func configureWith(movie: Movie)
}

public protocol MovieCellViewModelOutputs {
  var title: Signal<String, Never> { get }

  var date: Signal<String, Never> { get }

  var imageURL: Signal<URL, Never> { get }
}

public protocol MovieCellViewModelType {
  var inputs: MovieCellViewModelInputs { get }
  var outputs: MovieCellViewModelOutputs { get }
}

public final class MovieCellViewModel: MovieCellViewModelType, MovieCellViewModelInputs, MovieCellViewModelOutputs {
  public init() {
    let movie = self.movieProperty.signal.skipNil()

    self.title = movie.map(\.title).skipNil()
    
    self.date = movie.map(\.releaseDate).skipNil()

    self.imageURL = movie.map(\.posterPath)
      .skipNil()
      .map {
        Secrets.Api.Images.production + $0
      }
      .map(URL.init)
      .skipNil()
  }

  private let movieProperty = MutableProperty<Movie?>(nil)
  public func configureWith(movie: Movie) {
    self.movieProperty.value = movie
  }

  public let title: Signal<String, Never>
  public let date: Signal<String, Never>
  public let imageURL: Signal<URL, Never>

  public var inputs: MovieCellViewModelInputs { return self }
  public var outputs: MovieCellViewModelOutputs { return self }
}
