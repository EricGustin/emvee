//
//  EditBasicInfoViewController.swift
//  emvee
//
//  Created by Eric Gustin on 7/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class EditBasicInfoViewController: UIViewController {
  
  // Parameter stuff
  private var navBarTitle: String?
  private var label = UILabel()
  var buttons = [UIButton]()
  private var buttonTag: Int?
  var textField = UITextField()
  private var verticalStack: UIStackView?
  private var errorLabel: UILabel?
  
  private var checkmarks = [UIImageView]()
  
  init(title: String, labelText: String, numOfButtons: Int, buttonTag: Int? = nil, textFieldText: String? = nil) {
    self.navBarTitle = title
    self.label.text = "    " + labelText
    for _ in 0..<numOfButtons {
      self.buttons.append(UIButton())
      self.checkmarks.append(UIImageView(image: UIImage(systemName: "checkmark")))
    }
    if buttonTag != nil {
      self.buttonTag = buttonTag
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
    setUpDelegates()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    uploadChangesToFirebase()
  }
  
  private func setUpSubviews() {
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter", size: 16), size: 16)
    label.textColor = .black
    view.addSubview(label)
    label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,  constant: UIScreen.main.bounds.width / 20 + 25).isActive = true  // Logic behind the constant: The aboutMeTextView is centered and has a width of 0.9 * view.width, thus the aboutMeTextView's leading is effectively view.width / 20. In addition, adding 25 in order to match the aboutMeTextView's corner radius which is essential for the desired position.
    label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
    
    for i in 0..<buttons.count {
      buttons[i].translatesAutoresizingMaskIntoConstraints = false
      StyleUtilities.styleBasicInfoButton(buttons[i])
      buttons[i].tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
      buttons[i].tag = i
      if i == buttonTag {
        buttons[i].setTitleColor(.systemGreen, for: .normal)
      } else {
        buttons[i].setTitleColor(.black, for: .normal)
      }
      buttons[i].heightAnchor.constraint(equalToConstant: 35).isActive = true
      buttons[i].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonClicked)))
    }
    
    textField.textColor = .black
    textField.placeholder = "Spokane, WA"
    textField.font = UIFont(name: "American Typewriter", size: 16)
    StyleUtilities.styleTextField(textField, textField.placeholder ?? "")
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    errorLabel = UILabel()
    errorLabel?.text = "Field cannot be empty"
    errorLabel?.alpha = 0
    errorLabel?.font = UIFont(name: "American Typewriter", size: 16)
    errorLabel?.textColor = .systemRed
    errorLabel?.textAlignment = .center
    
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
    verticalStack?.addArrangedSubview(errorLabel!)
    view.addSubview(verticalStack!)
    verticalStack?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
    verticalStack?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9).isActive = true
    verticalStack?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    for i in 0..<checkmarks.count {
      checkmarks[i].isHidden = !(i == buttonTag ?? -1)
      checkmarks[i].translatesAutoresizingMaskIntoConstraints = false
      checkmarks[i].tintColor = .systemGreen
      checkmarks[i].preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
      buttons[i].addSubview(checkmarks[i])
      checkmarks[i].centerYAnchor.constraint(equalTo: buttons[i].centerYAnchor).isActive = true
      checkmarks[i].trailingAnchor.constraint(equalTo: buttons[i].trailingAnchor, constant: -buttons[i].layer.cornerRadius / 2).isActive = true
    }
  }
  
  private func setUpNavigationBar() {
    self.title = navBarTitle
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 16), size: 16), NSAttributedString.Key.foregroundColor: UIColor.systemGray6]
    //navigationController?.navigationBar.barTintColor = .systemGray6
    navigationController?.hidesBarsWhenKeyboardAppears = true
  }
  
  private func setUpDelegates() {
    textField.delegate = self
  }
  
  @objc private func buttonClicked(_ gestureRecognizer: UITapGestureRecognizer) {
    guard gestureRecognizer.view != nil else { return }
    buttonTag = gestureRecognizer.view!.tag
    for i in 0..<buttons.count {
      if i == buttonTag {
        checkmarks[i].isHidden = false
        buttons[i].setTitleColor(.systemGreen, for: .normal)
      } else {
        checkmarks[i].isHidden = true
        buttons[i].setTitleColor(.black, for: .normal)
      }
    }
  }
  
  private func uploadChangesToFirebase() {
    guard let userID = Auth.auth().currentUser?.uid else {
      print("Error getting userID")
      return
    }
    var fieldName = ""
    if buttons.count > 0 {
      if buttons[0].titleLabel?.text == "Male" {
        fieldName = "gender"
      } else if buttons[0].titleLabel?.text == "Men" {
        fieldName = "preferredGender"
      }
    } else if title == "Edit Current Location" {
      fieldName = "currentLcoation"
    } else if title == "Edit Hometown" {
      fieldName = "hometown"
    }
    var newValue = ""
    if buttonTag != nil {
      newValue = buttons[buttonTag!].titleLabel!.text ?? ""
    } else {
      newValue = textField.text!
    }
    let db = Firestore.firestore()
    db.collection("users").document(userID).updateData([fieldName: newValue])
  }
}

extension EditBasicInfoViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if (textField.text == "" || textField.text == nil) {
      errorLabel?.alpha = 1
    } else {
      textField.resignFirstResponder()
      view.isUserInteractionEnabled = true
      UIView.animate(withDuration: 0.3) {
        self.errorLabel?.alpha = 0
        self.navigationController?.isNavigationBarHidden = false
      }
      return true
    }
    return false
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    print("Started")
    view.isUserInteractionEnabled = false
    //navigationController?.barHideOnTapGestureRecognizer
    
    return true
  }
  
}
