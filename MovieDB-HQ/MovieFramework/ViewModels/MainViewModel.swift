import MovieLibrary
import ReactiveExtensions
import ReactiveSwift

public protocol MainViewModelInputs {

  func viewWillAppear()
}

public protocol MainViewModelOutputs {
  var reachability: Signal<Reachability, Never> { get }
}

public protocol MainViewModelType {
  var inputs: MainViewModelInputs { get }
  var outputs: MainViewModelOutputs { get }
}

public final class MainViewModel: MainViewModelType, MainViewModelOutputs,
  MainViewModelInputs {

  public init() {
    self.reachability = self.viewWillAppearProperty.signal
      .switchMap {
        AppEnvironment.current.reachability
          .materialize()
      }
      .values()
      .skipNil()
      .skipRepeats()
      .ksr_delay(DispatchTimeInterval.seconds(1), on: AppEnvironment.current.scheduler)
  }

  public var inputs: MainViewModelInputs { return self }
  public var outputs: MainViewModelOutputs { return self }

  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public private(set) var reachability: Signal<Reachability, Never>
}
