import MovieApi
import UIKit
import ReactiveSwift

/**
 A collection of **all** global variables and singletons that the app wants access to.
 */
public struct Environment {
  /// A type that exposes endpoints for fetching Kickstarter data.
  public let apiService: ServiceType

  /// The amount of time to delay API requests by. Used primarily for testing. Default value is `0.0`.
  public let apiDelayInterval: DispatchTimeInterval

  /// A type that stores a cached dictionary.
  public let cache: BNSCache
  
  /// The user's calendar.
  public let calendar: Calendar

  /// The current device running the app.
  public let device: UIDeviceType

  /// Returns the current environment type
  public var environmentType: EnvironmentType {
    return self.apiService.serverConfig.environment
  }

  /// The user’s current locale, which determines how numbers are formatted. Default value is
  /// `Locale.current`.
  public let locale: Locale

  /// A type that exposes how to interface with an NSBundle. Default value is `Bundle.main`.
  public let mainBundle: NSBundleType

  /// A reachability signal producer.
  public let reachability: SignalProducer<Reachability?, Never>

  /// A scheduler to use for all time-based RAC operators. Default value is
  /// `QueueScheduler.mainQueueScheduler`.
  public let scheduler: DateScheduler

  public init(
    apiService: ServiceType = Service(),
    apiDelayInterval: DispatchTimeInterval = .seconds(0),
    cache: BNSCache = BNSCache.current,
    calendar: Calendar = .current,
    device: UIDeviceType = UIDevice.current,
    locale: Locale = .current,
    mainBundle: NSBundleType = Bundle.main,
    reachability: SignalProducer<Reachability?, Never> = Reachability.signalProducer,
    scheduler: DateScheduler = QueueScheduler.main
  ) {
    self.apiService = apiService
    self.apiDelayInterval = apiDelayInterval
    self.cache = cache
    self.calendar = calendar
    self.device = device
    self.locale = locale
    self.mainBundle = mainBundle
    self.reachability = reachability
    self.scheduler = scheduler
  }
}
