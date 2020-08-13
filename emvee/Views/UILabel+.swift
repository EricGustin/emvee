//
//  UILabel+.swift
//  emvee
//
//  Created by Eric Gustin on 6/22/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

extension UILabel {
  
  func animateTransform(withIncreaseDuration increaseDuration: TimeInterval, withDecreaseDuration decreaseDuration: TimeInterval, withIncreaseScale increaseScale: CGFloat, withDecreaseScale decreaseScale: CGFloat) {

    UIView.animate(withDuration: increaseDuration, animations: {
      self.transform = CGAffineTransform(scaleX: increaseScale, y: increaseScale)
    }) { _ in
      UIView.animate(withDuration: decreaseDuration) {
        self.transform = CGAffineTransform(scaleX: decreaseScale, y: decreaseScale)
      }
    }
  }
  
}
