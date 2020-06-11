//
//  LoginViewController.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
  
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var errorLabel: UILabel!
  
  @IBAction func cancelButtonClicked(_ sender: UIButton) {
    let welcomeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController) as? WelcomeViewController
    
    view.window?.rootViewController = welcomeViewController
    view.window?.makeKeyAndVisible()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In loginViewController")
    setUpElements()
    
    emailTextField.delegate = self
    passwordTextField.delegate = self
  }
  
  func setUpElements() {
    errorLabel.alpha = 0
    StyleUtilities.styleTextField(emailTextField, emailTextField.placeholder ?? "")
    StyleUtilities.styleTextField(passwordTextField, passwordTextField.placeholder ?? "")
    StyleUtilities.styleFilledButton(loginButton)
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
  
  func validateFields() -> String? {
    if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
      return "Please fill in all fields"
    }
    let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    if !(FormUtilities.isPasswordValid(cleanedPassword)) {
      return "Invalid email and password combination."
    }
    return nil
  }
  
  @IBAction func loginButtonClicked(_ sender: Any) {
    
    // validate text fields
    let error = validateFields()
    if error != nil {
      showError(error!)
    }
    else {
      // create cleaned text
      let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      print(email)
      Auth.auth().signIn(withEmail: email, password: password ) { (result, error) in
        if error != nil {
          // Coudln't sign in
          let errorMessage = "Invalid email and password combination."
          self.showError(errorMessage)
        }
        else {
          UserDefaults.standard.set(true, forKey: "isUserSignedIn")
          guard let userID = Auth.auth().currentUser?.uid else {
            print("Error accessing userID")
            return
          }
          let db = Firestore.firestore() // initialize an instance of Cloud Firestore
          // Add the user to the onlineUsers document
          db.collection("onlineUsers").document(userID).setData(["userID": userID])
          print("User successfully added to onlineUsers collections")
          self.transitionToHome()
        }
      }
    }
  }
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
