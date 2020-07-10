//
//  UINavigationController+.swift
//  emvee
//
//  Created by Eric Gustin on 7/10/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

extension UINavigationController {
  
  func pushViewControllerFromLeftToRight(rootVC: UIViewController) {
    let transition = CATransition()
    transition.duration = 0.25
    transition.type = CATransitionType.push
    transition.subtype = CATransitionSubtype.fromLeft
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    view.window!.layer.add(transition, forKey: kCATransition)
    pushViewController(rootVC, animated: false)
  }
  
  func pushViewControllerFromRightToLeft(rootVC: UIViewController) {
    let transition = CATransition()
    transition.duration = 0.25
    transition.type = CATransitionType.push
    transition.subtype = CATransitionSubtype.fromRight
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    view.window?.layer.add(transition, forKey: kCATransition)
    pushViewController(rootVC, animated: false)
  }
  
  func pushViewControllerFromBottom(rootVC: UIViewController) {
    let transition = CATransition()
    transition.duration = 0.25
    transition.type = CATransitionType.push
    transition.subtype = CATransitionSubtype.fromTop
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    view.window?.layer.add(transition, forKey: kCATransition)
    pushViewController(rootVC, animated: false)
  }
  
  func popViewControllerToLeft() {
    let transition = CATransition()
    transition.duration = 0.25
    transition.type = CATransitionType.push
    transition.subtype = CATransitionSubtype.fromRight
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    view.window!.layer.add(transition, forKey: kCATransition)
    popViewController(animated: false)
  }
  
  func popViewControllerToRight() {
    let transition = CATransition()
    transition.duration = 0.25
    transition.type = CATransitionType.push
    transition.subtype = CATransitionSubtype.fromLeft
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    view.window!.layer.add(transition, forKey: kCATransition)
    popViewController(animated: false)
  }
  
  func popViewControllerToBottom() {
    let transition = CATransition()
    transition.duration = 0.25
    transition.type = CATransitionType.push
    transition.subtype = CATransitionSubtype.fromBottom
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
    view.window!.layer.add(transition, forKey: kCATransition)
    popViewController(animated: false)
  }
}
