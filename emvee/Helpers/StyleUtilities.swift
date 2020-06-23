//
//  StyleUtilities.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import Foundation
import UIKit

class StyleUtilities {
  
  static func styleTextField(_ textfield: UITextField, _ placeholderText: String) {
    
    // Create the bottom line
    
    //textfield.backgroundColor = UIColor.init(red: 59/255, green: 89/255, blue: 152/255, alpha: 1)
    textfield.layer.cornerRadius = 25.0
    textfield.borderStyle = .none
    textfield.clipsToBounds = true
    textfield.backgroundColor = UIColor.init(red: 210/255, green: 210/255, blue: 210/255, alpha: 0.3)
    textfield.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: textfield.frame.height))
    textfield.leftView = leftPaddingView
    textfield.leftViewMode = .always
  }
  
  static func styleCircularButton(_ button: UIButton) {
    button.layer.cornerRadius = button.frame.width / 2
  }
  
  static func styleFilledButton(_ button: UIButton) {
    
    // Filled rounded corner style
    button.backgroundColor = UIColor.init(red: 59/255, green: 100/255, blue: 180/255, alpha: 1)
    button.layer.cornerRadius = 25.0
    button.tintColor = UIColor.white
  }
  
  static func styleHollowButton(_ button: UIButton) {
    
    // Hollow rounded corner style
    button.layer.borderWidth = 2
    button.layer.borderColor = UIColor.black.cgColor
    button.layer.cornerRadius = 25.0
    button.tintColor = UIColor.black
  }
  
  static func styleBasicInfoButton(_ button: UIButton) {
    button.layer.cornerRadius = 17.5
    button.backgroundColor = .white
    button.setTitleColor(.black, for: .normal)
    button.titleLabel?.font = UIFont(name: "American Typewriter", size: 14)
    button.contentHorizontalAlignment = .leading
    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    button.layer.borderColor = UIColor.lightGray.cgColor
    button.layer.borderWidth = 0.25
  }
  
}
