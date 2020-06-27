//
//  ProfilePreviewPopup.swift
//  emvee
//
//  Created by Eric Gustin on 6/26/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import InputBarAccessoryView

class ProfilePreviewPopup: UIView, Popup {

  private let container: UIView = {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.backgroundColor = .white
    container.layer.cornerRadius = 24
    return container
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor.gray.withAlphaComponent(0.7)
    self.frame = UIScreen.main.bounds
    
    setUpSubviews()
    animateIn()
    setUpGestures()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  internal func setUpSubviews() {
    
    self.addSubview(container)
    container.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    container.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true  // 20 + the height of the messageInputBar
    container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
    container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
  
  internal func animateIn() {
    container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
    self.alpha = 0
    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
      self.alpha = 1
      self.container.transform = .identity  // reset transform
    })
  }
  
  func setUpGestures() {
    let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(animateOut))
    swipeUpGesture.direction = .up
    self.addGestureRecognizer(swipeUpGesture)
  }
  
  @objc func animateOut() {
    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
      self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
      self.alpha = 0
    }) { (complete) in
      if complete {
        self.removeFromSuperview()
      }
    }
  }
  
}
