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
  
  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var datePicker: UIDatePicker!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In signUpViewController")
    setUpElements()
    // Do any additional setup after loading the view.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
  func setUpElements() {
    errorLabel.alpha = 0
    StyleUtilities.styleTextField(firstNameTextField)
    StyleUtilities.styleTextField(lastNameTextField)
    StyleUtilities.styleTextField(emailTextField)
    StyleUtilities.styleTextField(passwordTextField)
    StyleUtilities.styleFilledButton(signUpButton)
  }
  
  func validateFields() -> String? {
    // Check that all fields are filled in
    if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
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
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMMM dd yyyy"
      let dateOfBirth = dateFormatter.string(from: datePicker.date
      )
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
            "bio": ""
          ])
          
          // Transition to homescreen
          self.transitionToHome()
        }
      }
    }
  }
  
}
