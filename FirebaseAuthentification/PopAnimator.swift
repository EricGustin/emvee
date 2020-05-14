//
//  PopAnimator.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/9/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import Foundation
import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
 let duration: Double = 1
 var originFrame = CGRect.zero

 func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
  return duration
 }
 
 func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
  // Set up Transition
  let containerView = transitionContext.containerView
  guard let toView = transitionContext.view(forKey: .to) else { return }
  
  let initialFrame = originFrame
  let finalFrame = toView.frame
  
  toView.transform = CGAffineTransform(scaleX: initialFrame.width / finalFrame.width, y: initialFrame.height / finalFrame.height)
  toView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
  containerView.addSubview(toView)
  
  // Animate
  UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, animations: {
   toView.transform = .identity
   toView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
  }) { _ in
   // Complete transition
   transitionContext.completeTransition(true)
  }
 }
 
 
}
