import MovieApi
import Foundation
import ReactiveSwift

public final class BNSCache {
  public static let current = BNSCache()

  // MARK: Producer

  public let signalProducer = cacheProperty.signal

  // MARK: Image Cache

  public let imageCache: ImageRequestCache = AutoPurgingImageCache()

  // MARK: Static Cache Keys

  public static let movies = "movies"

  private var cache = [String: Any]()

  public init() {
    
  }

  public subscript(key: String) -> Any? {
    get {
      return self.cache[key]
    }
    set {
      if let newValue = newValue {
        self.cache[key] = newValue
        cacheProperty.value = (key, newValue)
      } else {
        self.cache.removeValue(forKey: key)
      }
    }
  }

  public func removeAllObjects() {
    self.cache.removeAll()
  }
}

private let cacheProperty: MutableProperty<(String, Any?)> = MutableProperty(("None", nil))
