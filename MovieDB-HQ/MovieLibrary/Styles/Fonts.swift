import UIKit.UIFont

public extension UIFont {
  /// regular, 17pt font, 22pt leading, -24pt tracking
  var body: UIFont {
    return UIFont.preferredFont(name: self.fontDescriptor.postscriptName, size: 17)
  }

  /// regular, 16pt font, 21pt leading, -20pt tracking
  var callout: UIFont {
    return UIFont.preferredFont(name: self.fontDescriptor.postscriptName, size: 16)
  }

  /// regular, 12pt font, 16pt leading, 0pt tracking
  var caption1: UIFont {
    return UIFont.preferredFont(name: self.fontDescriptor.postscriptName, size: 12)
  }

  /// regular, 11pt font, 13pt leading, 6pt tracking
  var caption2: UIFont {
    return UIFont.preferredFont(name: self.fontDescriptor.postscriptName, size: 11)
  }

  /// regular, 13pt font, 18pt leading, -6pt tracking
  var footnote: UIFont {
    return UIFont.preferredFont(name: self.fontDescriptor.postscriptName, size: 13)
  }

  /// semi-bold, 17pt font, 22pt leading, -24pt tracking
  var headline: UIFont {
    return UIFont.preferredFont(name: self.fontDescriptor.postscriptName, size: 17)
  }

  /// regular, 15pt font, 20pt leading, -16pt tracking
  var subheadline: UIFont {
    return UIFont.preferredFont(name: self.fontDescriptor.postscriptName, size: 15)
  }

  /// regular, 28pt font, 34pt leading, 13pt tracking
  var title1: UIFont {
    return UIFont.preferredFont(name: self.fontDescriptor.postscriptName, size: 28)
  }

  /// regular, 22pt font, 28pt leading, 16pt tracking
  var title2: UIFont {
    return UIFont.preferredFont(name: self.fontDescriptor.postscriptName, size: 22)
  }

  /// regular, 20pt font, 25pt leading, 19pt tracking
  var title3: UIFont {
    return UIFont.preferredFont(name: self.fontDescriptor.postscriptName, size: 20)
  }

  static var bns_regular: UIFont {
    return UIFont(name: "SFProText-Regular", size: UIFont.labelFontSize) ?? UIFont.preferredFont(forTextStyle: .body)
  }

  static var bns_light: UIFont {
    return UIFont(name: "SFProText-Light", size: UIFont.labelFontSize) ?? UIFont.preferredFont(forTextStyle: .body)
  }

  static var bns_bold: UIFont {
    return UIFont(name: "SFProText-Bold", size: UIFont.labelFontSize) ?? UIFont.preferredFont(forTextStyle: .body)
  }

  static var bns_medium: UIFont {
    return UIFont(name: "SFProText-Medium", size: UIFont.labelFontSize) ?? UIFont.preferredFont(forTextStyle: .body)
  }

  static var bns_semibold: UIFont {
    return UIFont(name: "SFProText-Semibold", size: UIFont.labelFontSize) ?? UIFont.preferredFont(forTextStyle: .body)
  }

  fileprivate static func preferredFont(name fontName: String, size: CGFloat) -> UIFont {
    let scaleSize = size * UIDevice.widthScaleFactor
    return UIFont(name: fontName, size: scaleSize) ?? systemFont(ofSize: scaleSize, weight: .regular)
  }
}
