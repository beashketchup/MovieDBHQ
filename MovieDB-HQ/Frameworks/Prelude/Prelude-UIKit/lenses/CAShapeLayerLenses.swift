//
//  CAShapeLayerLenses.swift
//  Prelude-iOS
//
//  Created by CT-Parmar.Ashish on 14/3/19.
//  Copyright © 2019 Kickstarter. All rights reserved.
//

import Prelude
import UIKit

public protocol CAShapeLayerProtocol: KSObjectProtocol {
  var lineWidth: CGFloat { get set }
  var strokeColor: CGColor? { get set }
  var fillColor: CGColor? { get set }
  var path: CGPath? { get set }
  var opacity: Float { get set }
  var strokeStart: CGFloat { get set }
  var strokeEnd: CGFloat { get set }
  var lineDashPattern: [NSNumber]? { get set }
}

extension CAShapeLayer: CAShapeLayerProtocol {}

extension LensHolder where Object: CAShapeLayerProtocol {
  public var lineWidth: Lens<Object, CGFloat> {
    return Lens(
      view: { $0.lineWidth },
      set: { $1.lineWidth = $0; return $1 }
    )
  }
  
  public var strokeColor: Lens<Object, CGColor?> {
    return Lens(
      view: { $0.strokeColor },
      set: { $1.strokeColor = $0; return $1 }
    )
  }
  public var fillColor: Lens<Object, CGColor?> {
    return Lens(
      view: { $0.fillColor },
      set: { $1.fillColor = $0; return $1 }
    )
  }
  
  public var path: Lens<Object, CGPath?> {
    return Lens(
      view: { $0.path },
      set: { $1.path = $0; return $1 }
    )
  }
  
  public var opacity: Lens<Object, Float> {
    return Lens(
      view: { $0.opacity },
      set: { $1.opacity = $0; return $1 }
    )
  }
  
  public var strokeStart: Lens<Object, CGFloat> {
    return Lens(
      view: { $0.strokeStart },
      set: { $1.strokeStart = $0; return $1 }
    )
  }
  
  public var strokeEnd: Lens<Object, CGFloat> {
    return Lens(
      view: { $0.strokeEnd },
      set: { $1.strokeEnd = $0; return $1 }
    )
  }
  
  public var lineDashPattern: Lens<Object, [NSNumber]?> {
    return Lens(
      view: { $0.lineDashPattern },
      set: { $1.lineDashPattern = $0; return $1 }
    )
  }
}

