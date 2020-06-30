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
  
  //  UIViews
  private var scrollView: UIScrollView?
  private var navigationBarBackground: UIImageView?
  private var background: UIImageView?
  private var accountInfoVerticalStack: UIStackView?
  private var firstNameTextField: UITextField?
  private var lastNameTextField: UITextField?
  private var emailTextField: UITextField?
  private var passwordTextField: UITextField?
  private var dateOfBirthTextField: UITextField?
  private var datePicker: UIDatePicker?
  private var myGenderVerticalStack: UIStackView?
  private var myGenderLabel: UILabel?
  private var myGenderSegmentedControl: UISegmentedControl?
  private var preferredGenderVerticalStack: UIStackView?
  private var preferredGenderLabel: UILabel?
  private var preferredGenderSegmentedControl: UISegmentedControl?
  private var continueVerticalStack: UIStackView?
  private var signUpButton: UIButton?
  private var errorLabel: UILabel?
  private var cancelButton: UIButton?
  
  @objc func cancelButtonClicked() {
//    let welcomeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController) as? WelcomeViewController
//    view.window?.rootViewController = welcomeViewController
//    view.window?.makeKeyAndVisible()
    self.dismiss(animated: true, completion: nil)
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Sign Up"
    navigationController?.navigationBar.prefersLargeTitles = true
    
    
    setUpSubviews()
    setUpGestures()
    setDelegates()
  }
  
  private func setUpSubviews() {
    
//    navigationBarBackground = UIImageView(image: UIImage(named: "background@4x"))
//    navigationBarBackground?.translatesAutoresizingMaskIntoConstraints = false
//    navigationBarBackground?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
//    navigationBarBackground?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
//    navigationBarBackground?.heightAnchor.constraint(equalTo: (navigationController?.navigationBar.heightAnchor)!).isActive = true
    
    scrollView = UIScrollView()
    scrollView?.backgroundColor = .clear
    view.addSubview(scrollView!)
    scrollView?.translatesAutoresizingMaskIntoConstraints = false
    scrollView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    scrollView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    scrollView?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    scrollView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    background = UIImageView(image: UIImage(named: "background@4x"))
    background?.translatesAutoresizingMaskIntoConstraints = false
    background?.contentMode = .scaleAspectFill
    scrollView?.addSubview(background!)
    background?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    background?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    background?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    background?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
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
    
    accountInfoVerticalStack = UIStackView()
    accountInfoVerticalStack?.axis = .vertical
    accountInfoVerticalStack?.spacing = 20
    accountInfoVerticalStack?.translatesAutoresizingMaskIntoConstraints = false
    accountInfoVerticalStack?.addArrangedSubview(firstNameTextField!)
    accountInfoVerticalStack?.addArrangedSubview(lastNameTextField!)
    accountInfoVerticalStack?.addArrangedSubview(emailTextField!)
    accountInfoVerticalStack?.addArrangedSubview(passwordTextField!)
    scrollView?.addSubview(accountInfoVerticalStack!)
    accountInfoVerticalStack?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    accountInfoVerticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    accountInfoVerticalStack?.topAnchor.constraint(equalTo: scrollView!.topAnchor, constant: 40).isActive = true
    accountInfoVerticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
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
    scrollView?.addSubview(dateOfBirthTextField!)
    dateOfBirthTextField?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    dateOfBirthTextField?.topAnchor.constraint(equalTo: accountInfoVerticalStack!.bottomAnchor, constant: 60).isActive = true
    dateOfBirthTextField?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    dateOfBirthTextField?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
    myGenderLabel = UILabel()
    myGenderLabel?.text = "     I am a..."
    myGenderLabel?.textColor = .black
    myGenderLabel?.font = UIFont(name: "American Typewriter", size: 24)
    myGenderLabel?.translatesAutoresizingMaskIntoConstraints = false
    myGenderLabel?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    myGenderSegmentedControl = UISegmentedControl()
    myGenderSegmentedControl?.insertSegment(withTitle: "Male", at: 0, animated: true)
    myGenderSegmentedControl?.insertSegment(withTitle: "Female", at: 1, animated: true)
    myGenderSegmentedControl?.insertSegment(withTitle: "Other", at: 2, animated: true)
    myGenderSegmentedControl?.selectedSegmentIndex = 0
    myGenderSegmentedControl?.translatesAutoresizingMaskIntoConstraints = false
    myGenderSegmentedControl?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    myGenderVerticalStack = UIStackView()
    myGenderVerticalStack?.axis = .vertical
    myGenderVerticalStack?.spacing = 0
    myGenderVerticalStack?.translatesAutoresizingMaskIntoConstraints = false
    myGenderVerticalStack?.addArrangedSubview(myGenderLabel!)
    myGenderVerticalStack?.addArrangedSubview(myGenderSegmentedControl!)
    scrollView?.addSubview(myGenderVerticalStack!)
    myGenderVerticalStack?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    myGenderVerticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    myGenderVerticalStack?.topAnchor.constraint(equalTo: dateOfBirthTextField!.bottomAnchor, constant: 40).isActive = true
    myGenderVerticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
    preferredGenderLabel = UILabel()
    preferredGenderLabel?.text = "     I am interested in..."
    preferredGenderLabel?.textColor = .black
    preferredGenderLabel?.font = UIFont(name: "American Typewriter", size: 24)
    preferredGenderLabel?.translatesAutoresizingMaskIntoConstraints = false
    preferredGenderLabel?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    preferredGenderSegmentedControl = UISegmentedControl()
    preferredGenderSegmentedControl?.insertSegment(withTitle: "Men", at: 0, animated: true)
    preferredGenderSegmentedControl?.insertSegment(withTitle: "Women", at: 1, animated: true)
    preferredGenderSegmentedControl?.insertSegment(withTitle: "All", at: 2, animated: true)
    preferredGenderSegmentedControl?.selectedSegmentIndex = 0
    preferredGenderSegmentedControl?.translatesAutoresizingMaskIntoConstraints = false
    preferredGenderSegmentedControl?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    preferredGenderVerticalStack = UIStackView()
    preferredGenderVerticalStack?.axis = .vertical
    preferredGenderVerticalStack?.spacing = 0
    preferredGenderVerticalStack?.translatesAutoresizingMaskIntoConstraints = false
    preferredGenderVerticalStack?.addArrangedSubview(preferredGenderLabel!)
    preferredGenderVerticalStack?.addArrangedSubview(preferredGenderSegmentedControl!)
    scrollView?.addSubview(preferredGenderVerticalStack!)
    preferredGenderVerticalStack?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    preferredGenderVerticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    preferredGenderVerticalStack?.topAnchor.constraint(equalTo: myGenderVerticalStack!.bottomAnchor, constant: 40).isActive = true
    preferredGenderVerticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
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
    errorLabel?.heightAnchor.constraint(equalToConstant: 80).isActive = true
    
    cancelButton = UIButton()
    cancelButton?.setTitleColor(.black, for: .normal)
    cancelButton?.setTitle("Cancel", for: .normal)
    cancelButton?.titleLabel?.font = UIFont(name: "American Typewriter", size: 16)
    cancelButton?.titleLabel?.textAlignment = .right
    cancelButton?.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
    
    continueVerticalStack = UIStackView()
    continueVerticalStack?.axis = .vertical
    continueVerticalStack?.spacing = 20
    continueVerticalStack?.translatesAutoresizingMaskIntoConstraints = false
    continueVerticalStack?.addArrangedSubview(signUpButton!)
    continueVerticalStack?.addArrangedSubview(errorLabel!)
    continueVerticalStack?.addArrangedSubview(cancelButton!)
    scrollView?.addSubview(continueVerticalStack!)
    continueVerticalStack?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    continueVerticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    continueVerticalStack?.topAnchor.constraint(equalTo: preferredGenderVerticalStack!.bottomAnchor, constant: 60).isActive = true
    continueVerticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
    //  And finally, calculate the scrollView's contentSize
    scrollView?.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 950)
    
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
