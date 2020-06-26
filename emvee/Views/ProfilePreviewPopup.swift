//
//  ProfilePreviewPopup.swift
//  emvee
//
//  Created by Eric Gustin on 6/26/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class ProfilePreviewPopup: UIView {
  
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
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setUpSubviews() {
    
    self.addSubview(container)
    container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8).isActive = true
    container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
    container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
}
