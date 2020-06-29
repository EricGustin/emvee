//
//  SignUpViewController.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
  
  private var datePicker: UIDatePicker?
  
  
  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var dateOfBirthTextField: UITextField!
  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var errorLabel: UILabel!
  //@IBOutlet weak var datePicker: UIDatePicker!
  @IBAction func cancelButtonClicked(_ sender: UIButton) {
    let welcomeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController) as? WelcomeViewController
    
    view.window?.rootViewController = welcomeViewController
    view.window?.makeKeyAndVisible()
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In signUpViewController")
    setUpSubviews()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    view.addGestureRecognizer(tapGesture)
    
    firstNameTextField.delegate = self
    lastNameTextField.delegate = self
    emailTextField.delegate = self
    passwordTextField.delegate = self
  }
  
  func setUpSubviews() {
    
    datePicker = UIDatePicker()
    datePicker?.datePickerMode = .date
    datePicker?.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    
    dateOfBirthTextField.inputView = datePicker
    
    errorLabel.alpha = 0
    StyleUtilities.styleTextField(firstNameTextField, firstNameTextField.placeholder ?? "")
    StyleUtilities.styleTextField(lastNameTextField, lastNameTextField.placeholder ?? "")
    StyleUtilities.styleTextField(emailTextField, emailTextField.placeholder ?? "")
    StyleUtilities.styleTextField(passwordTextField, passwordTextField.placeholder ?? "")
    StyleUtilities.styleTextField(dateOfBirthTextField, dateOfBirthTextField.placeholder ?? "")
    StyleUtilities.styleFilledButton(signUpButton)
  }
  
  func validateFields() -> String? {
    // Check that all fields are filled in
    if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      dateOfBirthTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
      return "Please fill in all fields"
    }
    let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    if !(FormUtilities.isPasswordValid(cleanedPassword)) {
      return "Please make sure your password is at least 8 characters, contains a special character and a number."
    }
    return nil
  }
  
  func showError(_ message: String) {
    errorLabel.text = message
    errorLabel.alpha = 1
  }
  
  func transitionToHome() {
    let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
    
    view.window?.rootViewController = homeViewController
    view.window?.makeKeyAndVisible()
  }
  
  @IBAction func signUpClicked(_ sender: Any) {
    // Validate fields
    let error = validateFields()
    if error != nil {
      showError(error!)
    }
      // Create user
    else {
      // Create cleaned version of data
      let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let dateOfBirth = dateOfBirthTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
        // Check for errors
        if err != nil {
          // There is an error
          self.showError("Error creating user")
        }
        else {
          // User created successfully. Store relevent informastion
          let db = Firestore.firestore() // initialize an instance of Cloud Firestore
          let userID = Auth.auth().currentUser?.uid

          // Add a new document with a custom ID
          db.collection("users").document(userID!).setData([
            "firstName": firstName,
            "lastName": lastName,
            "birthday": dateOfBirth,
            "uid": userID!,
            "bio": "",
          ])
          
          // Add the user to the onlineUsers document
          db.collection("onlineUsers").document(userID!).setData(["userID": userID!])
          print("successfully added user to onlineUsers collection")
          
          // Transition to homescreen
          self.transitionToHome()
        }
      }
    }
  }
  
  @objc private func dateChanged() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM dd yyyy"
    dateOfBirthTextField.text = dateFormatter.string(from: datePicker!.date)
    view.endEditing(true)
  }
  
  @objc private func viewTapped() {
    view.endEditing(true)
  }
  
}

extension SignUpViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
