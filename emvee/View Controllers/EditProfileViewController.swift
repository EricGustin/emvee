//
//  EditProfileViewController.swift
//  emvee
//
//  Created by Eric Gustin on 6/23/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
  
  private var profilePictureVertStack: UIStackView!
  private var profilePicturesHorizStacks: [UIStackView]!
  private var profilePictures: [UIImageView]!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemGray6
    
    setUpNavigationBar()
    setupSubviews()
  }
  
  private func setUpNavigationBar() {
    title = "Edit Profile"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(transitionToProfile))
  }
  
  private func setupSubviews() {
    
    profilePictures = [UIImageView]()
    for index in 0..<6 {
      profilePictures.append(UIImageView(image: UIImage(named: "defaultProfileImage@4x")))
      profilePictures[index].isUserInteractionEnabled = true
    }
    
    profilePicturesHorizStacks = [UIStackView]()
    for i in 0...1 {
      profilePicturesHorizStacks.append(UIStackView(arrangedSubviews: Array(profilePictures[(i*3)..<(3+i*3)])))
      profilePicturesHorizStacks[i].axis = .horizontal
      profilePicturesHorizStacks[i].distribution = .fillEqually
      profilePicturesHorizStacks[i].spacing = 10
    }
    
    profilePictureVertStack = UIStackView(arrangedSubviews: [profilePicturesHorizStacks[0], profilePicturesHorizStacks[1]])
    profilePictureVertStack.axis = .vertical
    profilePictureVertStack.distribution = .fillEqually
    profilePictureVertStack.spacing = 10
    profilePictureVertStack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(profilePictureVertStack)
    profilePictureVertStack.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 1.0).isActive = true
    profilePictureVertStack.centerYAnchor.constraint(equalToSystemSpacingBelow: view.centerYAnchor, multiplier: 0.25).isActive = true
    profilePictureVertStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
    profilePictureVertStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
    profilePictureVertStack.heightAnchor.constraint(equalTo: profilePictureVertStack.widthAnchor, multiplier: 2/3).isActive = true
    
    
  }
  
  @objc private func transitionToProfile() {
    self.dismiss(animated: true, completion: nil)
  }
}
