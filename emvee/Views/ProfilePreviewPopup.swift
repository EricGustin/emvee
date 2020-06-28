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
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = .clear
    return scrollView
  }()
  
  private let profilePictureContainer: UIView = {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.layer.borderWidth = 0.25
    container.layer.borderColor = UIColor.lightGray.cgColor
    return container
  }()
  
  private var profilePicture: UIImageView = {
    let picture = UIImageView(image: UIImage())
    picture.backgroundColor = .white
    picture.translatesAutoresizingMaskIntoConstraints = false
    picture.isUserInteractionEnabled = true
    picture.layer.borderColor = UIColor.white.cgColor
    picture.layer.borderWidth = 4.75
    return picture
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    scrollView.delegate = self
    
    backgroundColor = UIColor.gray.withAlphaComponent(0.7)
    self.frame = UIScreen.main.bounds
    
    setUpSubviews()
    animateIn()
    setUpGestures()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //  Source: Agent Smith from Github post https://stackoverflow.com/questions/43494848/detect-any-tap-outside-the-current-view
    let touch = touches.first
    guard let location = touch?.location(in: self) else { return }
    if !container.frame.contains(location) {
      animateOut()
    }
  }
  
  internal func setUpSubviews() {
    
    self.addSubview(scrollView)
    scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true  // 20 + the height of the messageInputBar
    scrollView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
    scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    scrollView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    
    scrollView.addSubview(container)
    container.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    container.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true  // 20 + the height of the messageInputBar
    container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
    container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    
    scrollView.addSubview(profilePictureContainer)
    profilePictureContainer.centerXAnchor.constraint(equalTo: container.safeAreaLayoutGuide.centerXAnchor).isActive = true
    NSLayoutConstraint(item: profilePictureContainer, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 0.5, constant: 0).isActive = true
    profilePictureContainer.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.5).isActive = true
    profilePictureContainer.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.5).isActive = true
    profilePictureContainer.contentMode = .scaleAspectFill
    profilePictureContainer.layer.cornerRadius = UIScreen.main.bounds.width / 5
    profilePictureContainer.layer.masksToBounds = true
    
    profilePictureContainer.addSubview(profilePicture)
    profilePicture.centerXAnchor.constraint(equalTo: container.safeAreaLayoutGuide.centerXAnchor).isActive = true
    NSLayoutConstraint(item: profilePicture, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 0.5, constant: 0).isActive = true
    profilePicture.leadingAnchor.constraint(equalTo: profilePictureContainer.leadingAnchor, constant: profilePictureContainer.layer.borderWidth).isActive = true
    profilePicture.topAnchor.constraint(equalTo: profilePictureContainer.topAnchor, constant: profilePictureContainer.layer.borderWidth).isActive = true
    profilePicture.trailingAnchor.constraint(equalTo: profilePictureContainer.trailingAnchor, constant: -profilePictureContainer.layer.borderWidth).isActive = true
    profilePicture.bottomAnchor.constraint(equalTo: profilePictureContainer.bottomAnchor, constant: -profilePictureContainer.layer.borderWidth).isActive = true
    profilePicture.contentMode = .scaleAspectFill
    profilePicture.layer.cornerRadius = UIScreen.main.bounds.width / 5
    profilePicture.layer.masksToBounds = true
    
    // Lastly, calculate the content size of the scrollView
    scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
  }
  
  internal func animateIn() {
    container.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
    self.alpha = 0
    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
      self.alpha = 1
      self.container.transform = .identity  // reset transform
    })
  }
  
  func setUpGestures() {}
  
  func animateOut() {
    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
      self.container.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
      self.alpha = 0
    }) { (complete) in
      if complete {
        self.removeFromSuperview()
      }
    }
  }
  
}

extension ProfilePreviewPopup : UIScrollViewDelegate {
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if scrollView.contentOffset.y <= 0 {
      animateOut()
    }
  }
}
