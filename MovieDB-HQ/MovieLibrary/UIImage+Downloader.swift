import CoreGraphics
import Foundation
import UIKit

// MARK: Initialization

private let lock = NSLock()

extension UIImage {

  public static func bns_threadSafeImage(with data: Data) -> UIImage? {
    lock.lock()
    let image = UIImage(data: data)
    lock.unlock()

    return image
  }

  public static func bns_threadSafeImage(with data: Data, scale: CGFloat) -> UIImage? {
    lock.lock()
    let image = UIImage(data: data, scale: scale)
    lock.unlock()

    return image
  }
}
