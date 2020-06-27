//
//  Popup.swift
//  emvee
//
//  Created by Eric Gustin on 6/16/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class InfoPopup : UIView, Popup {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 34), size: 34)
    label.text = "How emvee works"
    label.textColor = .black
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private let subtitleLabel1: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter", size: 16), size: 16)
    label.text = "Match with a random stranger and get to know them through messaging in just 1 minute.\n"
    label.textColor = .black
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private let subtitleLabel2: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter", size: 16), size: 16)
    label.text = "After your minute is up, take things to a more personal level and talk face-to-face in a 1 on 1 video chat.\n"
    label.textColor = .black
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  public let button: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Got it", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.textAlignment = .center
    button.titleLabel?.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter", size: 16), size: 16)
    StyleUtilities.styleFilledButton(button)
    return button
  }()

  
  private let container: UIView = {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.backgroundColor = .white
    container.layer.cornerRadius = 24
    return container
  }()
  
  private var containerInitialHeight: NSLayoutConstraint = NSLayoutConstraint()
  
  // lazy so that the stack isn't created until the above constants have been created
  private lazy var stack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel1, subtitleLabel2, button])
    stack.axis = .vertical
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
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
    container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7).isActive = true
    containerInitialHeight = container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25)
    containerInitialHeight.isActive = true
    
    container.addSubview(stack)
    stack.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
    stack.topAnchor.constraint(equalTo: self.container.topAnchor).isActive = true
    stack.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.9).isActive = true
    stack.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.9).isActive = true
    
    button.heightAnchor.constraint(equalToConstant: 50 * 0.9).isActive = true
    button.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7 * 0.9).isActive = true
    button.addTarget(self, action: #selector(animateOut), for: .touchUpInside)
  }
  
  internal func setUpGestures() {
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
  
  @objc func animateIn() {
    container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
    self.alpha = 0
    subtitleLabel1.alpha = 0
    subtitleLabel2.alpha = 0
    button.alpha = 0
    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
      self.container.transform = .identity
      self.alpha = 1
    }) { (complete) in
      if complete {
        self.containerInitialHeight.isActive = false
        self.growContainer()
      }
    }
  }
  
  func growContainer() {
    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
      self.container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.55).isActive = true
      self.subtitleLabel1.alpha = 1
      self.subtitleLabel2.alpha = 1
      self.button.alpha = 1
      self.layoutIfNeeded()
    })
  }
}
