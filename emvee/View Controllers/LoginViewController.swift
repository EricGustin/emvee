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
  
  private var background: UIImageView?
  private var emailTextField: UITextField?
  private var passwordTextField: UITextField?
  private var loginButton: UIButton?
  private var errorLabel: UILabel?
  private var cancelButton: UIButton?
  private var signInVerticalStack: UIStackView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpSubviews()
    setUpNavigationBar()
    setUpDelegates()
  }
  
  private func setUpSubviews() {
    
    background = UIImageView(image: UIImage(named: "background@4x"))
    background?.translatesAutoresizingMaskIntoConstraints = false
    background?.contentMode = .scaleAspectFill
    view.addSubview(background!)
    background?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    background?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    background?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    background?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
    emailTextField = UITextField()
    emailTextField?.textColor = .black
    emailTextField?.autocapitalizationType = UITextAutocapitalizationType(rawValue: 0)!  // no capitalization
    emailTextField?.placeholder = "Email"
    emailTextField?.font = UIFont(name: "American Typewriter", size: 16)
    StyleUtilities.styleTextField(emailTextField!, emailTextField!.placeholder ?? "")
    emailTextField?.translatesAutoresizingMaskIntoConstraints = false
    emailTextField?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    passwordTextField = UITextField()
    passwordTextField?.textColor = .black
    passwordTextField?.isSecureTextEntry = true
    passwordTextField?.placeholder = "Password"
    passwordTextField?.font = UIFont(name: "American Typewriter", size: 16)
    StyleUtilities.styleTextField(passwordTextField!, passwordTextField!.placeholder ?? "")
    passwordTextField?.translatesAutoresizingMaskIntoConstraints = false
    passwordTextField?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    loginButton = UIButton()
    loginButton?.setTitleColor(.white, for: .normal)
    loginButton?.setTitle("Continue", for: .normal)
    loginButton?.titleLabel?.font = UIFont(name: "American Typewriter", size: 16)
    loginButton?.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
    StyleUtilities.styleFilledButton(loginButton!)
    loginButton?.translatesAutoresizingMaskIntoConstraints = false
    loginButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
     
    errorLabel = UILabel()
    errorLabel?.textAlignment = .center
    errorLabel?.numberOfLines = 0
    errorLabel?.textColor = .systemRed
    errorLabel?.font = UIFont(name: "American Typewriter", size: 16)
    errorLabel?.alpha = 0
    errorLabel?.translatesAutoresizingMaskIntoConstraints = false
    errorLabel?.heightAnchor.constraint(equalToConstant: 80).isActive = true
    
    signInVerticalStack = UIStackView()
    signInVerticalStack?.axis = .vertical
    signInVerticalStack?.spacing = 20
    signInVerticalStack?.translatesAutoresizingMaskIntoConstraints = false
    signInVerticalStack?.addArrangedSubview(emailTextField!)
    signInVerticalStack?.addArrangedSubview(passwordTextField!)
    signInVerticalStack?.addArrangedSubview(loginButton!)
    signInVerticalStack?.addArrangedSubview(errorLabel!)
    view?.addSubview(signInVerticalStack!)
    signInVerticalStack?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    signInVerticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    signInVerticalStack?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
    signInVerticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
    cancelButton = UIButton()
    cancelButton?.setTitleColor(.black, for: .normal)
    cancelButton?.setTitle("Cancel", for: .normal)
    cancelButton?.titleLabel?.font = UIFont(name: "American Typewriter", size: 16)
    cancelButton?.titleLabel?.textAlignment = .right
    cancelButton?.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
    cancelButton?.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(cancelButton!)
    cancelButton?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    cancelButton?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
  }
  
  private func setUpNavigationBar() {
    title = "Login"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 28), size: 28)]
    navigationController?.navigationBar.backgroundColor = .systemGray6
  }
  
  private func setUpDelegates() {
    emailTextField?.delegate = self
    passwordTextField?.delegate = self
  }
  
  private func showError(_ message: String) {
    errorLabel?.text = message
    errorLabel?.alpha = 1
  }
  
  private func transitionToHome() {
    let vc = HomeViewController()
    navigationController?.pushViewControllerFromBottom(rootVC: vc)
  }
  
  func validateFields() -> String? {
    if emailTextField!.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      passwordTextField!.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
      return "Please fill in all fields"
    }
    let cleanedPassword = passwordTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    if !(FormUtilities.isPasswordValid(cleanedPassword)) {
      return "Invalid email and password combination."
    }
    return nil
  }
  
  @objc func cancelButtonClicked(_ sender: UIButton) {
    navigationController?.popViewControllerToRight()
  }
  
  @objc func loginButtonClicked(_ sender: Any) {
    
    // validate text fields
    let error = validateFields()
    if error != nil {
      showError(error!)
    }
    else {
      // create cleaned text
      let email = emailTextField?.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let password = passwordTextField?.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      Auth.auth().signIn(withEmail: email!, password: password! ) { (result, error) in
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
