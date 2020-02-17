import UIKit

public extension UIImage {
  func resizeImage(
    _ dimension: CGFloat, opaque: Bool = false,
    contentMode: UIView.ContentMode = .scaleAspectFit
  ) -> UIImage {
    var width: CGFloat
    var height: CGFloat
    var newImage: UIImage

    let aspectRatio = size.width / size.height

    switch contentMode {
    case .scaleAspectFit:
      if aspectRatio > 1 { // Landscape image
        width = dimension
        height = dimension / aspectRatio
      } else { // Portrait image
        height = dimension
        width = dimension * aspectRatio
      }

    default:
      fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
    }

    if #available(iOS 10.0, *) {
      let renderFormat = UIGraphicsImageRendererFormat.default()
      renderFormat.opaque = opaque
      let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
      newImage = renderer.image {
        _ in
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
      }
    } else {
      UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
      self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
      newImage = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext()
    }

    return newImage
  }

  func rotateBy(degrees: CGFloat, flip: Bool) -> UIImage? {

    let degreesToRadians: (CGFloat) -> CGFloat = {
      $0 / 180.0 * .pi
    }

    let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint.zero, size: size))
    rotatedViewBox.transform = CGAffineTransform(rotationAngle: degreesToRadians(degrees))
    let rotatedSize = rotatedViewBox.frame.size

    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, false, UIScreen.main.scale)

    let bitmap = UIGraphicsGetCurrentContext()

    // Move the origin to the middle of the image so we will rotate and scale around the center.
    bitmap?.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)

    // Rotate the image context
    bitmap?.rotate(by: degreesToRadians(degrees))

    // Now, draw the rotated/scaled image into the context
    var yFlip: CGFloat

    if flip {
      yFlip = CGFloat(-1.0)
    } else {
      yFlip = CGFloat(1.0)
    }

    bitmap?.scaleBy(x: yFlip, y: -1.0)
    bitmap?.draw(cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage
  }

  var hasAlpha: Bool {
    let result: Bool

    guard let alpha = cgImage?.alphaInfo else {
      return false
    }

    switch alpha {
    case .none, .noneSkipFirst, .noneSkipLast:
      result = false
    default:
      result = true
    }

    return result
  }

  func cache_toData() -> Data? {
    return self.hasAlpha
      ? pngData()
      : jpegData(compressionQuality: 1.0)
  }
}
