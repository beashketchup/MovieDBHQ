import Foundation
import UIKit

// MARK: ImageCache

/// The `ImageCache` protocol defines a set of APIs for adding, removing and fetching images from a cache.
public protocol ImageCache {
  /// Adds the image to the cache with the given identifier.
  func add(_ image: UIImage, withIdentifier identifier: String)

  /// Removes the image from the cache matching the given identifier.
  func removeImage(withIdentifier identifier: String) -> Bool

  /// Removes all images stored in the cache.
  @discardableResult
  func removeAllImages() -> Bool

  /// Returns the image in the cache associated with the given identifier.
  func image(withIdentifier identifier: String) -> UIImage?
}

/// The `ImageRequestCache` protocol extends the `ImageCache` protocol by adding methods for adding, removing and
/// fetching images from a cache given an `URLRequest` and additional identifier.
public protocol ImageRequestCache: ImageCache {
  /// Adds the image to the cache using an identifier created from the request and identifier.
  func add(_ image: UIImage, for request: URLRequest)

  /// Removes the image from the cache using an identifier created from the request and identifier.
  func removeImage(for request: URLRequest) -> Bool

  /// Returns the image from the cache associated with an identifier created from the request and identifier.
  func image(for request: URLRequest) -> UIImage?
}

// MARK: -

/// The `AutoPurgingImageCache` in an in-memory image cache used to store images up to a given memory capacity. When
/// the memory capacity is reached, the image cache is sorted by last access date, then the oldest image is continuously
/// purged until the preferred memory usage after purge is met. Each time an image is accessed through the cache, the
/// internal access date of the image is updated.
open class AutoPurgingImageCache: ImageRequestCache {
  class CachedImage {
    let image: UIImage
    let identifier: String
    let totalBytes: UInt64
    var lastAccessDate: Date

    init(_ image: UIImage, identifier: String) {
      self.image = image
      self.identifier = identifier
      self.lastAccessDate = Date()

      self.totalBytes = {
        let size = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)

        let bytesPerPixel: CGFloat = 4.0
        let bytesPerRow = size.width * bytesPerPixel
        let totalBytes = UInt64(bytesPerRow) * UInt64(size.height)

        return totalBytes
      }()
    }

    func accessImage() -> UIImage {
      self.lastAccessDate = Date()
      return self.image
    }
  }

  // MARK: Properties

  /// The current total memory usage in bytes of all images stored within the cache.
  open var memoryUsage: UInt64 {
    var memoryUsage: UInt64 = 0
    self.synchronizationQueue.sync(flags: [.barrier]) { memoryUsage = self.currentMemoryUsage }

    return memoryUsage
  }

  /// The total memory capacity of the cache in bytes.
  public let memoryCapacity: UInt64

  /// The preferred memory usage after purge in bytes. During a purge, images will be purged until the memory
  /// capacity drops below this limit.
  public let preferredMemoryUsageAfterPurge: UInt64

  private let synchronizationQueue: DispatchQueue
  private var cachedImages: [String: CachedImage]
  private var currentMemoryUsage: UInt64

  // MARK: Initialization

  /// Initializes the `AutoPurgingImageCache` instance with the given memory capacity and preferred memory usage
  /// after purge limit.
  ///
  /// Please note, the memory capacity must always be greater than or equal to the preferred memory usage after purge.
  ///
  /// - parameter memoryCapacity:                 The total memory capacity of the cache in bytes. `100 MB` by default.
  /// - parameter preferredMemoryUsageAfterPurge: The preferred memory usage after purge in bytes. `60 MB` by default.
  ///
  /// - returns: The new `AutoPurgingImageCache` instance.
  public init(memoryCapacity: UInt64 = 100_000_000, preferredMemoryUsageAfterPurge: UInt64 = 60_000_000) {
    self.memoryCapacity = memoryCapacity
    self.preferredMemoryUsageAfterPurge = preferredMemoryUsageAfterPurge

    precondition(
      memoryCapacity >= preferredMemoryUsageAfterPurge,
      "The `memoryCapacity` must be greater than or equal to `preferredMemoryUsageAfterPurge`"
    )

    self.cachedImages = [:]
    self.currentMemoryUsage = 0

    self.synchronizationQueue = {
      let name = String(format: "org.bns.autopurgingimagecache-%08x%08x", arc4random(), arc4random())
      return DispatchQueue(label: name, attributes: .concurrent)
    }()

    let notification = UIApplication.didReceiveMemoryWarningNotification

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(AutoPurgingImageCache.removeAllImages),
      name: notification,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: Add Image to Cache

  /// Adds the image to the cache using an identifier created from the request and optional identifier.
  ///
  /// - parameter image:      The image to add to the cache.
  /// - parameter request:    The request used to generate the image's unique identifier.
  /// - parameter identifier: The additional identifier to append to the image's unique identifier.
  open func add(_ image: UIImage, for request: URLRequest) {
    let requestIdentifier = self.imageCacheKey(for: request)
    self.add(image, withIdentifier: requestIdentifier)
  }

  /// Adds the image to the cache with the given identifier.
  ///
  /// - parameter image:      The image to add to the cache.
  /// - parameter identifier: The identifier to use to uniquely identify the image.
  open func add(_ image: UIImage, withIdentifier identifier: String) {
    self.synchronizationQueue.async(flags: [.barrier]) {
      let cachedImage = CachedImage(image, identifier: identifier)

      if let previousCachedImage = self.cachedImages[identifier] {
        self.currentMemoryUsage -= previousCachedImage.totalBytes
      }

      self.cachedImages[identifier] = cachedImage
      self.currentMemoryUsage += cachedImage.totalBytes
    }

    self.synchronizationQueue.async(flags: [.barrier]) {
      if self.currentMemoryUsage > self.memoryCapacity {
        let bytesToPurge = self.currentMemoryUsage - self.preferredMemoryUsageAfterPurge

        var sortedImages = self.cachedImages.map { $1 }

        sortedImages.sort {
          let date1 = $0.lastAccessDate
          let date2 = $1.lastAccessDate

          return date1.timeIntervalSince(date2) < 0.0
        }

        var bytesPurged = UInt64(0)

        for cachedImage in sortedImages {
          self.cachedImages.removeValue(forKey: cachedImage.identifier)
          bytesPurged += cachedImage.totalBytes

          if bytesPurged >= bytesToPurge {
            break
          }
        }

        self.currentMemoryUsage -= bytesPurged
      }
    }
  }

  // MARK: Remove Image from Cache

  /// Removes the image from the cache using an identifier created from the request and optional identifier.
  ///
  /// - parameter request:    The request used to generate the image's unique identifier.
  /// - parameter identifier: The additional identifier to append to the image's unique identifier.
  ///
  /// - returns: `true` if the image was removed, `false` otherwise.
  @discardableResult
  open func removeImage(for request: URLRequest) -> Bool {
    let requestIdentifier = self.imageCacheKey(for: request)
    return self.removeImage(withIdentifier: requestIdentifier)
  }

  /// Removes all images from the cache created from the request.
  ///
  /// - parameter request: The request used to generate the image's unique identifier.
  ///
  /// - returns: `true` if any images were removed, `false` otherwise.
  @discardableResult
  open func removeImages(matching request: URLRequest) -> Bool {
    let requestIdentifier = self.imageCacheKey(for: request)
    var removed = false

    self.synchronizationQueue.sync(flags: [.barrier]) {
      for key in self.cachedImages.keys where key.hasPrefix(requestIdentifier) {
        if let cachedImage = self.cachedImages.removeValue(forKey: key) {
          self.currentMemoryUsage -= cachedImage.totalBytes
          removed = true
        }
      }
    }

    return removed
  }

  /// Removes the image from the cache matching the given identifier.
  ///
  /// - parameter identifier: The unique identifier for the image.
  ///
  /// - returns: `true` if the image was removed, `false` otherwise.
  @discardableResult
  open func removeImage(withIdentifier identifier: String) -> Bool {
    var removed = false

    self.synchronizationQueue.sync(flags: [.barrier]) {
      if let cachedImage = self.cachedImages.removeValue(forKey: identifier) {
        self.currentMemoryUsage -= cachedImage.totalBytes
        removed = true
      }
    }

    return removed
  }

  /// Removes all images stored in the cache.
  ///
  /// - returns: `true` if images were removed from the cache, `false` otherwise.
  @discardableResult @objc
  open func removeAllImages() -> Bool {
    var removed = false

    self.synchronizationQueue.sync(flags: [.barrier]) {
      if !self.cachedImages.isEmpty {
        self.cachedImages.removeAll()
        self.currentMemoryUsage = 0

        removed = true
      }
    }

    return removed
  }

  // MARK: Fetch Image from Cache

  /// Returns the image from the cache associated with an identifier created from the request and optional identifier.
  ///
  /// - parameter request:    The request used to generate the image's unique identifier.
  /// - parameter identifier: The additional identifier to append to the image's unique identifier.
  ///
  /// - returns: The image if it is stored in the cache, `nil` otherwise.
  open func image(for request: URLRequest) -> UIImage? {
    let requestIdentifier = self.imageCacheKey(for: request)
    return self.image(withIdentifier: requestIdentifier)
  }

  /// Returns the image in the cache associated with the given identifier.
  ///
  /// - parameter identifier: The unique identifier for the image.
  ///
  /// - returns: The image if it is stored in the cache, `nil` otherwise.
  open func image(withIdentifier identifier: String) -> UIImage? {
    var image: UIImage?

    self.synchronizationQueue.sync(flags: [.barrier]) {
      if let cachedImage = self.cachedImages[identifier] {
        image = cachedImage.accessImage()
      }
    }

    return image
  }

  // MARK: Image Cache Keys

  /// Returns the unique image cache key for the specified request and additional identifier.
  ///
  /// - parameter request:    The request.
  /// - parameter identifier: The additional identifier.
  ///
  /// - returns: The unique image cache key.
  open func imageCacheKey(for request: URLRequest) -> String {
    var key = request.url?.absoluteString ?? ""
    key += "-BNS"

    return key
  }
}
