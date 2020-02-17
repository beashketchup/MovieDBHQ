import MovieLibrary
import ReactiveExtensions
import ReactiveSwift

public protocol LandingViewModelInputs {
  
  func viewWillAppear()
  
  func presentResult()
}

public protocol LandingViewModelOutputs {
  var showResult: Signal<(), Never> { get }
}

public protocol LandingViewModelType {
  var inputs: LandingViewModelInputs { get }
  var outputs: LandingViewModelOutputs { get }
}

public final class LandingViewModel: LandingViewModelType, LandingViewModelOutputs,
LandingViewModelInputs {
  
  public init() {
    self.showResult = self.presentResultProperty.signal
  }
  
  public var inputs: LandingViewModelInputs { return self }
  public var outputs: LandingViewModelOutputs { return self }
  
  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  
  private let presentResultProperty = MutableProperty(())
  public func presentResult() {
    self.presentResultProperty.value = ()
  }
  
  public private(set) var showResult: Signal<(), Never>
}
