import MovieApi
import MovieLibrary
import Prelude
import ReactiveExtensions
import ReactiveSwift

internal protocol ResultViewModelInputs {
  
  func viewDidLoad()
  
  func viewWillAppear()
  
  func reload()
  
  func nextPage()
}

internal protocol ResultViewModelOutputs {
  var hasDataLoaded: Signal<[Movie], Never> { get }
  
  var dataLoadFailed: Signal<ErrorEnvelope, Never> { get }
  
  var havePages: Signal<Bool, Never> { get }
  
  var count: Signal<Int, Never> { get }
}

internal protocol ResultViewModelType {
  var inputs: ResultViewModelInputs { get }
  var outputs: ResultViewModelOutputs { get }
}

internal final class ResultViewModel: ResultViewModelType, ResultViewModelInputs, ResultViewModelOutputs {
  
  private let moviesData: Signal<[Movie], Never>
  
  internal init() {
    
    let movieListing = Signal.combineLatest(
      self.viewDidLoadProperty.signal,
      self.nextPageProperty.signal
      )
      .map(second)
      .switchMap {
        AppEnvironment.current.apiService.fetchPlayingNow(
          for: ["page" : "\($0)"]
          ).materialize()
    }
    
    self.moviesData = movieListing.values()
      .map(\.data)
    
    self.hasDataLoaded = self.moviesDataProperty.signal
    
    self.dataLoadFailed = movieListing.errors()
    
    self.count = movieListing.values().map(\.totalResults)
    
    self.havePages = self.hasDataLoaded
      .combineLatest(with: self.count)
      .map {
        $0.0.count < $0.1
    }
  }
  
  internal var inputs: ResultViewModelInputs { return self }
  internal var outputs: ResultViewModelOutputs { return self }
  
  private let viewWillAppearProperty = MutableProperty(())
  internal func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  
  private let viewDidLoadProperty = MutableProperty(())
  internal func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
    self.nextPage()
    
    self.moviesData.observeValues { [weak self] in
      guard let previousValue = self?.moviesDataProperty.value else { return }
      self?.moviesDataProperty.value = previousValue + $0
    }
  }
  
  internal func reload() {
    self.nextPageProperty.value = 1
    self.moviesDataProperty.value = []
  }
  
  private let nextPageProperty = MutableProperty<Int>(0)
  internal func nextPage() {
    self.nextPageProperty.value = self.nextPageProperty.value + 1
  }
  
  private let moviesDataProperty = MutableProperty<[Movie]>([])
  
  internal private(set) var count: Signal<Int, Never>
  internal private(set) var havePages: Signal<Bool, Never>
  internal private(set) var hasDataLoaded: Signal<[Movie], Never>
  internal private(set) var dataLoadFailed: Signal<ErrorEnvelope, Never>
}
