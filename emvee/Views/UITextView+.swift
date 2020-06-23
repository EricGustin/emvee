//
//  UITextView+.swift
//  emvee
//
//  Created by Eric Gustin on 6/18/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

extension UITextView {
  
  func addKeyboardToolBar(leftTitle: String, rightTitle: String, target: Any, selector: Selector) {
    
    let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                          y: 0.0,
                                          width: UIScreen.main.bounds.size.width,
                                          height: 44.0))
    let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let leftButton = UIBarButtonItem(title: leftTitle, style: .plain, target: target, action: selector)
    let rightButton = UIBarButtonItem(title: rightTitle, style: .done, target: target, action: selector)
    toolBar.setItems([leftButton, flexible, rightButton], animated: false)
    self.inputAccessoryView = toolBar
  }

}
