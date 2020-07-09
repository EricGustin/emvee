//
//  EditBasicInfoViewController.swift
//  emvee
//
//  Created by Eric Gustin on 7/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class EditBasicInfoViewController: UIViewController {
  
  private var navBarTitle: String?
  private var label = UILabel()
  var buttons = [UIButton]()
  var textField = UITextField()
  private var verticalStack: UIStackView?
  
  init(title: String, labelText: String, numOfButtons: Int, textFieldText: String? = nil) {
    self.navBarTitle = title
    self.label.text = "    " + labelText
    for _ in 0..<numOfButtons {
      self.buttons.append(UIButton())
    }
    if textFieldText != nil {
      self.textField.text = textFieldText
    }
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .systemGray6
    setUpSubviews()
    setUpNavigationBar()
  }
  
  private func setUpSubviews() {
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Semibold", size: 16), size: 16)
    label.textColor = .black
    view.addSubview(label)
    label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,  constant: UIScreen.main.bounds.width / 20 + 25).isActive = true  // Logic behind the constant: The aboutMeTextView is centered and has a width of 0.9 * view.width, thus the aboutMeTextView's leading is effectively view.width / 20. In addition, adding 25 in order to match the aboutMeTextView's corner radius which is essential for the desired position.
    label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
    
    for button in buttons {
      button.translatesAutoresizingMaskIntoConstraints = false
      StyleUtilities.styleBasicInfoButton(button)
      button.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
      button.heightAnchor.constraint(equalToConstant: 35).isActive = true
    }
    
    textField.textColor = .black
    textField.placeholder = "Spokane, WA"
    textField.font = UIFont(name: "American Typewriter", size: 16)
    StyleUtilities.styleTextField(textField, textField.placeholder ?? "")
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    verticalStack = UIStackView()
    verticalStack?.axis = .vertical
    verticalStack?.spacing = 5
    verticalStack?.translatesAutoresizingMaskIntoConstraints = false
    verticalStack?.addArrangedSubview(label)
    for button in buttons {
      verticalStack?.addArrangedSubview(button)
    }
    if buttons.count == 0 { // the only time buttons.count will be zero is if there needs to be a textfield
      verticalStack?.addArrangedSubview(textField)
    }
    view.addSubview(verticalStack!)
    verticalStack?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
    verticalStack?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9).isActive = true
    verticalStack?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
  }
  
  private func setUpNavigationBar() {
    self.title = navBarTitle
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonClicked))
  }
  
  @objc private func saveButtonClicked() {
    let vc = EditProfileViewController()
    show(vc, sender: nil)
  }
}
