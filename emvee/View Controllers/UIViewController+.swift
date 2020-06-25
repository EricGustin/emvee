//
//  UIViewController+.swift
//  emvee
//
//  Created by Eric Gustin on 6/25/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
// All credit goes to Siddhesh Mahadeshwar and shim from StackOverflow for their comment at https://stackoverflow.com/questions/24224916/presenting-a-uialertcontroller-properly-on-an-ipad-using-ios-8

import UIKit

extension UIViewController {
  public func addActionSheetForiPad(actionSheet: UIAlertController) {
    if let popoverPresentationController = actionSheet.popoverPresentationController {
      popoverPresentationController.sourceView = self.view
      popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
      popoverPresentationController.permittedArrowDirections = []
    }
  }
}
