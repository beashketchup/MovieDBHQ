import MovieApi
import UIKit

internal typealias AnimationOptions = UIView.AnimationOptions
internal let imageSerializer = ImageResponseSerializer()

extension UIImageView {

  // MARK: - ImageTransition

  /// Used to wrap all `UIView` animation transition options alongside a duration.
  public enum ImageTransition {
    case noTransition
    case crossDissolve(TimeInterval)

    /// The duration of the image transition in seconds.
    public var duration: TimeInterval {
      switch self {
      case .noTransition:
        return 0.0
      case let .crossDissolve(duration):
        return duration
      }
    }

    /// The animation options of the image transition.
    public var animationOptions: AnimationOptions {
      switch self {
      case .noTransition:
        return []
      case .crossDissolve:
        return .transitionCrossDissolve
      }
    }

    /// The animation options of the image transition.
    public var animations: (UIImageView, UIImage) -> Void {
      return { $0.image = $1 }
    }
  }

  // MARK: - Private - AssociatedKeys

  private struct AssociatedKey {
    static var sharedImageDownloader = "bns_UIImageView.SharedImageDownloader"
    static var activeRequestReceipt = "bns_UIImageView.ActiveRequestReceipt"
  }

  // MARK: - Associated Properties

  public class var bns_sharedImageDownloader: ImageDownloader {
    get {
      if let downloader = objc_getAssociatedObject(self, &AssociatedKey.sharedImageDownloader) as? ImageDownloader {
        return downloader
      } else {
        return ImageDownloader.default
      }
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKey.sharedImageDownloader, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  var bns_activeRequestReceipt: RequestReceipt? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKey.activeRequestReceipt) as? RequestReceipt
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKey.activeRequestReceipt, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  // MARK: - Image Download

  public func bns_setImage(
    withURL url: URL,
    placeholderImage: UIImage? = nil,
    imageTransition: ImageTransition = .noTransition,
    runImageTransitionIfCached: Bool = false,
    completion: ((UIImage?) -> Void)? = nil
  ) {
    self.bns_setImage(
      withURLRequest: self.urlRequest(with: url),
      placeholderImage: placeholderImage,
      imageTransition: imageTransition,
      runImageTransitionIfCached: runImageTransitionIfCached,
      completion: completion
    )
  }

  public func bns_setImage(
    withURLRequest urlRequest: URLRequest,
    placeholderImage: UIImage? = nil,
    imageTransition: ImageTransition = .noTransition,
    runImageTransitionIfCached: Bool = false,
    completion: ((UIImage?) -> Void)? = nil
  ) {
    guard !self.isURLRequestURLEqualToActiveRequestURL(urlRequest) else {
      completion?(nil)
      return
    }

    self.bns_cancelImageRequest()

    // Use the image from the image cache if it exists
    if
      let image = AppEnvironment.current.cache.imageCache.image(for: urlRequest) {
      if runImageTransitionIfCached {
        let tinyDelay = DispatchTime.now() + Double(Int64(0.001 * Float(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)

        // Need to let the runloop cycle for the placeholder image to take affect
        DispatchQueue.main.asyncAfter(deadline: tinyDelay) {
          self.run(imageTransition, with: image)
          completion?(image)
        }
      } else {
        self.image = image
        completion?(image)
      }

      return
    }

    // Set the placeholder since we're going to have to download
    if let placeholderImage = placeholderImage { self.image = placeholderImage }

    // Generate a unique download id to check whether the active request has changed while downloading
    let downloadID = UUID().uuidString

    // Download the image, then run the image transition or completion handler
    let requestReceipt = UIImageView.bns_sharedImageDownloader.download(
      urlRequest,
      receiptID: downloadID,
      completion: { [weak self] response in
        guard
          let strongSelf = self,
          strongSelf.isURLRequestURLEqualToActiveRequestURL(response.response),
          strongSelf.bns_activeRequestReceipt?.receiptID == downloadID
        else {
          completion?(nil)
          return
        }

        if let image = imageSerializer.serialize(response: response.response, data: response.data) {
          strongSelf.run(imageTransition, with: image)
          completion?(image)
        }

        strongSelf.bns_activeRequestReceipt = nil
        completion?(nil)
      }
    )

    self.bns_activeRequestReceipt = requestReceipt
  }

  // MARK: - Image Download Cancellation

  /// Cancels the active download request, if one exists.
  public func bns_cancelImageRequest() {
    guard let activeRequestReceipt = bns_activeRequestReceipt else { return }

    UIImageView.bns_sharedImageDownloader.cancelRequest(with: activeRequestReceipt)

    self.bns_activeRequestReceipt = nil
  }

  // MARK: - Image Transition

  public func run(_ imageTransition: ImageTransition, with image: UIImage) {
    UIView.transition(
      with: self,
      duration: imageTransition.duration,
      options: imageTransition.animationOptions,
      animations: { imageTransition.animations(self, image) },
      completion: nil
    )
  }

  // MARK: - Private - URL Request Helper Methods

  private func urlRequest(with url: URL) -> URLRequest {
    var urlRequest = URLRequest(url: url)

    for mimeType in ImageResponseSerializer.acceptableImageContentTypes {
      urlRequest.addValue(mimeType, forHTTPHeaderField: "Accept")
    }

    return urlRequest
  }

  private func isURLRequestURLEqualToActiveRequestURL(_ urlRequest: URLRequest?) -> Bool {
    if
      let currentRequestURL = bns_activeRequestReceipt?.request.url,
      let requestURL = urlRequest?.url,
      currentRequestURL == requestURL {
      return true
    }

    return false
  }

  private func isURLRequestURLEqualToActiveRequestURL(_ urlResponse: URLResponse?) -> Bool {
    if
      let currentRequestURL = bns_activeRequestReceipt?.request.url,
      let responseURL = urlResponse?.url,
      currentRequestURL == responseURL {
      return true
    }

    return false
  }
}

public final class ImageResponseSerializer {

  // MARK: Properties

  public static var deviceScreenScale: CGFloat { return UIScreen.main.scale }

  public let imageScale: CGFloat
  public let inflateResponseImage: Bool

  static var acceptableImageContentTypes: Set<String> = [
    "image/tiff",
    "image/jpeg",
    "image/gif",
    "image/png",
    "image/ico",
    "image/x-icon",
    "image/bmp",
    "image/x-bmp",
    "image/x-xbitmap",
    "image/x-ms-bmp",
    "image/x-win-bitmap"
  ]

  // MARK: Initialization

  public init(
    imageScale: CGFloat = ImageResponseSerializer.deviceScreenScale,
    inflateResponseImage: Bool = true
  ) {
    self.imageScale = imageScale
    self.inflateResponseImage = inflateResponseImage
  }

  // MARK: Serialization

  public func serialize(response: URLResponse?, data: Data?) -> UIImage? {

    guard let data = data, !data.isEmpty else {
      print("Returning empty image!")
      return UIImage()
    }

    if self.validateContentType(for: response) {
      return self.serializeImage(from: data)
    }

    return nil
  }

  public func serializeImage(from data: Data) -> UIImage? {
    guard !data.isEmpty else {
      return nil
    }

    guard let image = UIImage.bns_threadSafeImage(with: data, scale: imageScale) else {
      return nil
    }
    return image
  }

  // MARK: Content Type Validation

  public class func addAcceptableImageContentTypes(_ contentTypes: Set<String>) {
    ImageResponseSerializer.acceptableImageContentTypes.formUnion(contentTypes)
  }

  public func validateContentType(for response: URLResponse?) -> Bool {
    guard let mimeType = response?.mimeType else {
      return false
    }

    guard ImageResponseSerializer.acceptableImageContentTypes.contains(mimeType) else {
      return false
    }

    return true
  }
}
