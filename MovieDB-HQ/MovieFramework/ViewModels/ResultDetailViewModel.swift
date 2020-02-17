import MovieApi
import MovieLibrary
import Prelude
import ReactiveExtensions
import ReactiveSwift

internal protocol ResultDetailViewModelInputs {
  
  func configure(for movie: Movie?)
  
  func viewDidLoad()
  
  func viewWillAppear()
}

internal protocol ResultDetailViewModelOutputs {
  
  var hasDataLoaded: Signal<[Movie], Never> { get }
  
  var dataLoadFailed: Signal<ErrorEnvelope, Never> { get }
  
  var movieDesc: Signal<String, Never> { get }
  
  var title: Signal<String, Never> { get }
  
  var year: Signal<String, Never> { get }
  
  var imageURL: Signal<URL, Never> { get }
}

internal protocol ResultDetailViewModelType {
  var inputs: ResultDetailViewModelInputs { get }
  var outputs: ResultDetailViewModelOutputs { get }
}

internal final class ResultDetailViewModel: ResultDetailViewModelType, ResultDetailViewModelInputs, ResultDetailViewModelOutputs {
  
  public init() {
    
    let data = Signal.combineLatest(
      self.configureProperty.signal,
      self.viewDidLoadProperty.signal
      )
      .map(first)
      .skipNil()
    
    self.title = data.map(\.title).skipNil()
    
    self.movieDesc = data.map(\.overview).skipNil()
    
    self.year = data.map(\.releaseDate).skipNil()
    
    self.imageURL = data.map(\.posterPath)
      .skipNil()
      .map {
        Secrets.Api.Images.production + $0
      }
      .map(URL.init)
      .skipNil()
    
    let movieId = data.map(\.id).skipNil()
    
    let movieListing = self.viewDidLoadProperty.signal
      .combineLatest(with: movieId)
      .map(second)
      .switchMap {
        AppEnvironment.current.apiService.fetchSimilarMovies(
          for: $0, query: ["page" : "1"])
          .materialize()
    }
    
    self.hasDataLoaded = movieListing.values().map(\.data)
    
    self.dataLoadFailed = movieListing.errors()
  }
  
  internal var inputs: ResultDetailViewModelInputs { return self }
  internal var outputs: ResultDetailViewModelOutputs { return self }
  
  private let configureProperty = MutableProperty<Movie?>(nil)
  internal func configure(for Movie: Movie?) {
    self.configureProperty.value = Movie
  }
  
  private let viewDidLoadProperty = MutableProperty(())
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  
  private let viewWillAppearProperty = MutableProperty(())
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  
  internal private(set) var title: Signal<String, Never>
  internal private(set) var year: Signal<String, Never>
  internal private(set) var movieDesc: Signal<String, Never>
  internal private(set) var imageURL: Signal<URL, Never>
  internal private(set) var hasDataLoaded: Signal<[Movie], Never>
  internal private(set) var dataLoadFailed: Signal<ErrorEnvelope, Never>
}

