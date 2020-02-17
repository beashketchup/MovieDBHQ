//
//  UIPageControlLenses.swift
//  Prelude-iOS
//
//  Created by CT-Dhananjay.Dubey on 9/1/20.
//  Copyright © 2020 Kickstarter. All rights reserved.
//
import Prelude
import UIKit

public protocol UIPageControlProtocol: UIViewProtocol {
  
  var hidesForSinglePage: Bool { get set }
  
  var pageIndicatorTintColor: UIColor? { get set }
  
  var currentPageIndicatorTintColor: UIColor? { get set }
}

extension UIPageControl: UIPageControlProtocol {}

public extension LensHolder where Object: UIPageControlProtocol {
  
  var pageIndicatorTintColor: Lens<Object, UIColor?> {
    return Lens(
      view: { $0.pageIndicatorTintColor },
      set: { $1.pageIndicatorTintColor = $0; return $1 }
    )
  }
  
  var currentPageIndicatorTintColor: Lens<Object, UIColor?> {
    return Lens(
      view: { $0.currentPageIndicatorTintColor },
      set: { $1.currentPageIndicatorTintColor = $0; return $1 }
    )
  }
  
  var hidesForSinglePage: Lens<Object, Bool> {
    return Lens(
      view: { $0.hidesForSinglePage },
      set: { $1.hidesForSinglePage = $0; return $1 }
    )
  }
}
