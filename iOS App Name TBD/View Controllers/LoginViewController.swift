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
 override func viewDidLoad() {
  super.viewDidLoad()
  print("In loginViewController")
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
  StyleUtilities.styleTextField(emailTextField)
  StyleUtilities.styleTextField(passwordTextField)
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

   Auth.auth().signIn(withEmail: email, password: password ) { (result, error) in
    if error != nil {
     // Coudln't sign in
     let errorMessage = "Invalid email and password combination."
     self.showError(errorMessage)
    }
    else {
     UserDefaults.standard.set(true, forKey: "isUserSignedIn")
     self.transitionToHome()
    }
   }
  }
 }
 
}
