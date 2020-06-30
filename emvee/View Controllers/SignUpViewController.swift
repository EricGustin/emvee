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
  
  private var section1VerticalStack: UIStackView?
  private var firstNameTextField: UITextField?
  private var lastNameTextField: UITextField?
  private var emailTextField: UITextField?
  private var passwordTextField: UITextField?
  private var dateOfBirthTextField: UITextField?
  private var section2VerticalStack: UIStackView?
  private var signUpButton: UIButton?
  private var errorLabel: UILabel?
//  @IBOutlet weak var firstNameTextField: UITextField!
//  @IBOutlet weak var lastNameTextField: UITextField!
//  @IBOutlet weak var emailTextField: UITextField!
//  @IBOutlet weak var passwordTextField: UITextField!
//  @IBOutlet weak var dateOfBirthTextField: UITextField!
//  @IBOutlet weak var signUpButton: UIButton!
//  @IBOutlet weak var errorLabel: UILabel!
  //@IBOutlet weak var datePicker: UIDatePicker!
  @IBAction func cancelButtonClicked(_ sender: UIButton) {
    let welcomeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController) as? WelcomeViewController
    
    view.window?.rootViewController = welcomeViewController
    view.window?.makeKeyAndVisible()
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setUpSubviews()
    setUpGestures()
    setDelegates()
  }
  
  private func setUpSubviews() {
    
    firstNameTextField = UITextField()
    firstNameTextField?.textColor = .black
    firstNameTextField?.placeholder = "First Name"
    firstNameTextField?.font = UIFont(name: "American Typewriter", size: 16)
    StyleUtilities.styleTextField(firstNameTextField!, firstNameTextField!.placeholder ?? "")
    firstNameTextField?.translatesAutoresizingMaskIntoConstraints = false
    firstNameTextField?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    lastNameTextField = UITextField()
    lastNameTextField?.textColor = .black
    lastNameTextField?.placeholder = "Last Name"
    lastNameTextField?.font = UIFont(name: "American Typewriter", size: 16)
    StyleUtilities.styleTextField(lastNameTextField!, lastNameTextField!.placeholder ?? "")
    lastNameTextField?.translatesAutoresizingMaskIntoConstraints = false
    lastNameTextField?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    emailTextField = UITextField()
    emailTextField?.textColor = .black
    emailTextField?.placeholder = "Email"
    emailTextField?.font = UIFont(name: "American Typewriter", size: 16)
    StyleUtilities.styleTextField(emailTextField!, emailTextField!.placeholder ?? "")
    emailTextField?.translatesAutoresizingMaskIntoConstraints = false
    emailTextField?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    passwordTextField = UITextField()
    passwordTextField?.textColor = .black
    passwordTextField?.placeholder = "Password"
    passwordTextField?.font = UIFont(name: "American Typewriter", size: 16)
    StyleUtilities.styleTextField(passwordTextField!, passwordTextField!.placeholder ?? "")
    passwordTextField?.translatesAutoresizingMaskIntoConstraints = false
    passwordTextField?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    section1VerticalStack = UIStackView()
    section1VerticalStack?.axis = .vertical
    section1VerticalStack?.spacing = 20
    section1VerticalStack?.translatesAutoresizingMaskIntoConstraints = false
    section1VerticalStack?.addArrangedSubview(firstNameTextField!)
    section1VerticalStack?.addArrangedSubview(lastNameTextField!)
    section1VerticalStack?.addArrangedSubview(emailTextField!)
    section1VerticalStack?.addArrangedSubview(passwordTextField!)
    view.addSubview(section1VerticalStack!)
    section1VerticalStack?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    section1VerticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    section1VerticalStack?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
    section1VerticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
    dateOfBirthTextField = UITextField()
    dateOfBirthTextField?.textColor = .black
    dateOfBirthTextField?.placeholder = "Date Of Birth"
    dateOfBirthTextField?.font = UIFont(name: "American Typewriter", size: 16)
    datePicker = UIDatePicker()
    datePicker?.datePickerMode = .date
    datePicker?.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    dateOfBirthTextField?.inputView = datePicker
    StyleUtilities.styleTextField(dateOfBirthTextField!, dateOfBirthTextField!.placeholder ?? "")
    dateOfBirthTextField?.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(dateOfBirthTextField!)
    dateOfBirthTextField?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    dateOfBirthTextField?.topAnchor.constraint(equalTo: section1VerticalStack!.bottomAnchor, constant: 40).isActive = true
    dateOfBirthTextField?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    dateOfBirthTextField?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
    signUpButton = UIButton()
    signUpButton?.setTitleColor(.white, for: .normal)
    signUpButton?.setTitle("Sign Up", for: .normal)
    signUpButton?.titleLabel?.font = UIFont(name: "American Typewriter", size: 16)
    signUpButton?.addTarget(self, action: #selector(signUpClicked), for: .touchUpInside)
    StyleUtilities.styleFilledButton(signUpButton!)
    signUpButton?.translatesAutoresizingMaskIntoConstraints = false
    signUpButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    errorLabel = UILabel()
    errorLabel?.textAlignment = .center
    errorLabel?.numberOfLines = 0
    errorLabel?.textColor = .systemRed
    errorLabel?.font = UIFont(name: "American Typewriter", size: 16)
    errorLabel?.alpha = 0
    errorLabel?.translatesAutoresizingMaskIntoConstraints = false
    errorLabel?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    section2VerticalStack = UIStackView()
    section2VerticalStack?.axis = .vertical
    section2VerticalStack?.spacing = 20
    section2VerticalStack?.translatesAutoresizingMaskIntoConstraints = false
    section2VerticalStack?.addArrangedSubview(signUpButton!)
    section2VerticalStack?.addArrangedSubview(errorLabel!)
    view.addSubview(section2VerticalStack!)
    section2VerticalStack?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    section2VerticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    section2VerticalStack?.topAnchor.constraint(equalTo: dateOfBirthTextField!.bottomAnchor, constant: 40).isActive = true
    section2VerticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
  }
  
  private func setUpGestures() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    view.addGestureRecognizer(tapGesture)
  }
  
  private func setDelegates() {
    firstNameTextField?.delegate = self
    lastNameTextField?.delegate = self
    emailTextField?.delegate = self
    passwordTextField?.delegate = self
  }
  
  func validateFields() -> String? {
    // Check that all fields are filled in
    if firstNameTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      lastNameTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      emailTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      passwordTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      dateOfBirthTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
      return "Please fill in all fields"
    }
    let cleanedPassword = passwordTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    if !(FormUtilities.isPasswordValid(cleanedPassword)) {
      return "Please make sure your password is at least 8 characters, contains a special character and a number."
    }
    return nil
  }
  
  func showError(_ message: String) {
    errorLabel?.text = message
    errorLabel?.alpha = 1
  }
  
  private func transitionToHome() {
    let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
    
    view.window?.rootViewController = homeViewController
    view.window?.makeKeyAndVisible()
  }
  
  @objc func signUpClicked(_ sender: Any) {
    // Validate fields
    let error = validateFields()
    if error != nil {
      showError(error!)
    }
      // Create user
    else {
      // Create cleaned version of data
      let firstName = firstNameTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let lastName = lastNameTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let email = emailTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let password = passwordTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let dateOfBirth = dateOfBirthTextField?.text!.trimmingCharacters(in: .whitespacesAndNewlines)
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
            "birthday": dateOfBirth!,
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
    dateOfBirthTextField?.text = dateFormatter.string(from: datePicker!.date)
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
