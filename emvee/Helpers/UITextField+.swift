//
//  UITextField+.swift
//  emvee
//
//  Created by Eric Gustin on 7/1/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

extension UITextField {
  
  func addKeyboardToolBar(leftTitle: String, rightTitle: String, target: Any, selector: Selector) {
    
    let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                          y: 0.0,
                                          width: UIScreen.main.bounds.size.width,
                                          height: 44.0))
    let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    if leftTitle != "" && rightTitle == "" {
      let leftButton = UIBarButtonItem(title: leftTitle, style: .plain, target: target, action: selector)
      toolBar.setItems([leftButton, flexible], animated: false)
    } else if rightTitle != "" && leftTitle == "" {
      let rightButton = UIBarButtonItem(title: rightTitle, style: .done, target: target, action: selector)
      toolBar.setItems([flexible,rightButton], animated: false)
    } else if rightTitle != "" && leftTitle != "" {
      let rightButton = UIBarButtonItem(title: rightTitle, style: .done, target: target, action: selector)
      let leftButton = UIBarButtonItem(title: leftTitle, style: .plain, target: target, action: selector)
      toolBar.setItems([leftButton, flexible, rightButton], animated: false)
    }
    self.inputAccessoryView = toolBar
  }

}
