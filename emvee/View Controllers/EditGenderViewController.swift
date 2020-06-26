//
//  EditGenderViewController.swift
//  emvee
//
//  Created by Eric Gustin on 6/25/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class EditGenderViewController: UIViewController {
  
  private var iAmALabel: UILabel!
  private var maleButton: UIButton!
  private var femaleButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGray6
    title = "Gender"
    
    setUpSubViews()
  }
  
  private func setUpSubViews() {
    
    iAmALabel = UILabel()
    iAmALabel.text = "I am a..."
    iAmALabel.translatesAutoresizingMaskIntoConstraints = false
    iAmALabel.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Semibold", size: 16), size: 16)
    iAmALabel.textColor = .black
    iAmALabel.textAlignment = .center
    view.addSubview(iAmALabel)
    iAmALabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,  constant: UIScreen.main.bounds.width / 20 + 25).isActive = true  // Logic behind the constant: The aboutMeTextView is centered and has a width of 0.9 * view.width, thus the aboutMeTextView's leading is effectively view.width / 20. In addition, adding 25 in order to match the aboutMeTextView's corner radius which is essential for the desired position.
    iAmALabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
    
    maleButton = UIButton()
    maleButton.translatesAutoresizingMaskIntoConstraints = false
    maleButton.setTitle("Man", for: .normal)
    StyleUtilities.styleBasicInfoButton(maleButton)
    maleButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    view.addSubview(maleButton)
    maleButton.topAnchor.constraint(equalTo: iAmALabel.bottomAnchor, constant: 5).isActive = true
    maleButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    maleButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    maleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    femaleButton = UIButton()
    femaleButton.translatesAutoresizingMaskIntoConstraints = false
    femaleButton.setTitle("Female", for: .normal)
    StyleUtilities.styleBasicInfoButton(femaleButton)
    femaleButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    view.addSubview(femaleButton)
    femaleButton.topAnchor.constraint(equalTo: maleButton.bottomAnchor, constant: 5).isActive = true
    femaleButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    femaleButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    femaleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
  }
}
