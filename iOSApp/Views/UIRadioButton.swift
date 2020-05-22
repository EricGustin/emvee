//
//  UIRadioButton.swift
//  iOSApp
//
//  Created by Eric Gustin on 5/19/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//  All credit goes to Ashok from medium.com

import UIKit

protocol UIRadioButtonDelegate {
  func onClick(_ sender: UIView)
}

class UIRadioButton: UIButton {
  var checkedView: UIView?
  var uncheckedView: UIView?
  var delegate: UIRadioButtonDelegate?
  
  var isChecked: Bool = false {
    didSet {
      setNeedsLayout()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addTarget(self, action: #selector(onClick), for: UIControl.Event.touchUpInside)
    checkedView = UIImageView(image: UIImage(contentsOfFile: "radioOn"))
    uncheckedView = UIImageView(image: UIImage(contentsOfFile: "radioOff"))
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    checkedView?.removeFromSuperview()
    uncheckedView?.removeFromSuperview()
    removeConstraints(self.constraints)
    
//    let view = isChecked == true ? checkedView : uncheckedView
//    if let view = view {
//      addSubview(view)
//      translatesAutoresizingMaskIntoConstraints = false // prevent the view's auto-resizing mask to be translated into Auto Layout contstraints and affecting my programmatic constraints
//    }
  }
  
  @objc func onClick(sender: UIButton) {
    if sender == self {
      delegate?.onClick(self)
    }
  }
}
