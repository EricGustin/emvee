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
  private var myGenderSegmentedControlContainer: UIView?
  private var myGenderSegmentedControl: UISegmentedControl?
  private var preferredGenderVerticalStack: UIStackView?
  private var preferredGenderLabel: UILabel?
  private var preferredGenderSegmentedControlContainer: UIView?
  private var preferredGenderSegmentedControl: UISegmentedControl?
  private var hometownVerticalStack: UIStackView?
  private var hometownLabel: UILabel?
  private var hometownTextField: UITextField?
  private var currentLocationVerticalStack: UIStackView?
  private var currentLocationLabel: UILabel?
  private var currentLocationTextField: UITextField?
  private var continueVerticalStack: UIStackView?
  private var continueButton: UIButton?
  private var errorLabel: UILabel?
  private var cancelButton: UIButton?
  
  private var currentSelectedTextField: UITextField?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setUpNavigationBar()
    setUpSubviews()
    setUpGestures()
    setDelegates()
    
    // Adjust scrollView's inset when needed e.g. when keyboard is shown / is hidden
    NotificationCenter.default.addObserver(self, selector: #selector(adjustInsetForKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(adjustInsetForKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  private func setUpNavigationBar() {
    title = "Basic Info"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "American Typewriter", size: 28)!]
    //navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.backgroundColor = .systemGray6
  }
  
  private func setUpSubviews() {
    
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
    dateOfBirthTextField?.addKeyboardToolBar(leftTitle: "", rightTitle: "Done", target: self, selector: #selector(doneEditingDatePicker))
    datePicker = UIDatePicker()
    datePicker?.datePickerMode = .date
    datePicker?.minimumDate = Date(timeIntervalSince1970: -1262217600)  // January 01 1930
    datePicker?.maximumDate = Date()
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
    
    myGenderSegmentedControlContainer = UIView()
    myGenderSegmentedControlContainer?.layer.cornerRadius = 25  // Half of the height of the container
    myGenderSegmentedControlContainer?.layer.borderColor = UIColor.lightGray.cgColor
    myGenderSegmentedControlContainer?.layer.borderWidth = 0.25
    myGenderSegmentedControlContainer?.layer.masksToBounds = true
    myGenderSegmentedControlContainer?.translatesAutoresizingMaskIntoConstraints = false
    myGenderSegmentedControlContainer?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    myGenderSegmentedControl = UISegmentedControl()
    myGenderSegmentedControl?.backgroundColor = UIColor.init(red: 210/255, green: 210/255, blue: 210/255, alpha: 0.3)
    myGenderSegmentedControl?.insertSegment(withTitle: "Male", at: 0, animated: true)
    myGenderSegmentedControl?.insertSegment(withTitle: "Female", at: 1, animated: true)
    myGenderSegmentedControl?.insertSegment(withTitle: "Other", at: 2, animated: true)
    myGenderSegmentedControl?.selectedSegmentIndex = 0
    myGenderSegmentedControlContainer?.addSubview(myGenderSegmentedControl!)
    myGenderSegmentedControl?.translatesAutoresizingMaskIntoConstraints = false
    myGenderSegmentedControl?.heightAnchor.constraint(equalToConstant: 55).isActive = true // Make a little bit larger than 50 to account for the fact that the width is a little bit larger
    myGenderSegmentedControl?.widthAnchor.constraint(equalTo: myGenderSegmentedControlContainer!.widthAnchor, multiplier: 1.015).isActive = true
    myGenderSegmentedControl?.centerXAnchor.constraint(equalTo: myGenderSegmentedControlContainer!.centerXAnchor).isActive = true
    myGenderSegmentedControl?.centerYAnchor.constraint(equalTo: myGenderSegmentedControlContainer!.centerYAnchor).isActive = true
    
    myGenderVerticalStack = UIStackView()
    myGenderVerticalStack?.axis = .vertical
    myGenderVerticalStack?.spacing = 0
    myGenderVerticalStack?.translatesAutoresizingMaskIntoConstraints = false
    myGenderVerticalStack?.addArrangedSubview(myGenderLabel!)
    myGenderVerticalStack?.addArrangedSubview(myGenderSegmentedControlContainer!)
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
    
    preferredGenderSegmentedControlContainer = UIView()
    preferredGenderSegmentedControlContainer?.layer.cornerRadius = 25  // Half of the height of the container
    preferredGenderSegmentedControlContainer?.layer.borderColor = UIColor.lightGray.cgColor
    preferredGenderSegmentedControlContainer?.layer.borderWidth = 0.25
    preferredGenderSegmentedControlContainer?.layer.masksToBounds = true
    preferredGenderSegmentedControlContainer?.translatesAutoresizingMaskIntoConstraints = false
    preferredGenderSegmentedControlContainer?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    preferredGenderSegmentedControl = UISegmentedControl()
    preferredGenderSegmentedControl?.backgroundColor = UIColor.init(red: 210/255, green: 210/255, blue: 210/255, alpha: 0.3)
    preferredGenderSegmentedControl?.insertSegment(withTitle: "Men", at: 0, animated: true)
    preferredGenderSegmentedControl?.insertSegment(withTitle: "Women", at: 1, animated: true)
    preferredGenderSegmentedControl?.insertSegment(withTitle: "All", at: 2, animated: true)
    preferredGenderSegmentedControl?.selectedSegmentIndex = 0
    preferredGenderSegmentedControl?.translatesAutoresizingMaskIntoConstraints = false
    preferredGenderSegmentedControlContainer?.addSubview(preferredGenderSegmentedControl!)
    preferredGenderSegmentedControl?.translatesAutoresizingMaskIntoConstraints = false
    preferredGenderSegmentedControl?.heightAnchor.constraint(equalToConstant: 55).isActive = true  // Make a little bit larger than 50 to account for the fact that the width is a little bit larger
    preferredGenderSegmentedControl?.widthAnchor.constraint(equalTo: preferredGenderSegmentedControlContainer!.widthAnchor, multiplier: 1.015).isActive = true
    preferredGenderSegmentedControl?.centerXAnchor.constraint(equalTo: preferredGenderSegmentedControlContainer!.centerXAnchor).isActive = true
    preferredGenderSegmentedControl?.centerYAnchor.constraint(equalTo: preferredGenderSegmentedControlContainer!.centerYAnchor).isActive = true
    
    preferredGenderVerticalStack = UIStackView()
    preferredGenderVerticalStack?.axis = .vertical
    preferredGenderVerticalStack?.spacing = 0
    preferredGenderVerticalStack?.translatesAutoresizingMaskIntoConstraints = false
    preferredGenderVerticalStack?.addArrangedSubview(preferredGenderLabel!)
    preferredGenderVerticalStack?.addArrangedSubview(preferredGenderSegmentedControlContainer!)
    scrollView?.addSubview(preferredGenderVerticalStack!)
    preferredGenderVerticalStack?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    preferredGenderVerticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    preferredGenderVerticalStack?.topAnchor.constraint(equalTo: myGenderVerticalStack!.bottomAnchor, constant: 40).isActive = true
    preferredGenderVerticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
    hometownLabel = UILabel()
    hometownLabel?.text = "     My hometown is..."
    hometownLabel?.textColor = .black
    hometownLabel?.font = UIFont(name: "American Typewriter", size: 24)
    hometownLabel?.translatesAutoresizingMaskIntoConstraints = false
    hometownLabel?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    hometownTextField = UITextField()
    hometownTextField?.textColor = .black
    hometownTextField?.placeholder = "Portland, OR"
    hometownTextField?.font = UIFont(name: "American Typewriter", size: 16)
    StyleUtilities.styleTextField(hometownTextField!, hometownTextField!.placeholder ?? "")
    hometownTextField?.translatesAutoresizingMaskIntoConstraints = false
    hometownTextField?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    hometownVerticalStack = UIStackView()
    hometownVerticalStack?.axis = .vertical
    hometownVerticalStack?.spacing = 0
    hometownVerticalStack?.translatesAutoresizingMaskIntoConstraints = false
    hometownVerticalStack?.addArrangedSubview(hometownLabel!)
    hometownVerticalStack?.addArrangedSubview(hometownTextField!)
    scrollView?.addSubview(hometownVerticalStack!)
    hometownVerticalStack?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    hometownVerticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    hometownVerticalStack?.topAnchor.constraint(equalTo: preferredGenderVerticalStack!.bottomAnchor, constant: 40).isActive = true
    hometownVerticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
    currentLocationLabel = UILabel()
    currentLocationLabel?.text = "     I live in..."
    currentLocationLabel?.textColor = .black
    currentLocationLabel?.font = UIFont(name: "American Typewriter", size: 24)
    currentLocationLabel?.translatesAutoresizingMaskIntoConstraints = false
    currentLocationLabel?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    currentLocationTextField = UITextField()
    currentLocationTextField?.textColor = .black
    currentLocationTextField?.placeholder = "Spokane, WA"
    currentLocationTextField?.font = UIFont(name: "American Typewriter", size: 16)
    StyleUtilities.styleTextField(currentLocationTextField!, currentLocationTextField!.placeholder ?? "")
    currentLocationTextField?.translatesAutoresizingMaskIntoConstraints = false
    currentLocationTextField?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    currentLocationVerticalStack = UIStackView()
    currentLocationVerticalStack?.axis = .vertical
    currentLocationVerticalStack?.spacing = 0
    currentLocationVerticalStack?.translatesAutoresizingMaskIntoConstraints = false
    currentLocationVerticalStack?.addArrangedSubview(currentLocationLabel!)
    currentLocationVerticalStack?.addArrangedSubview(currentLocationTextField!)
    scrollView?.addSubview(currentLocationVerticalStack!)
    currentLocationVerticalStack?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    currentLocationVerticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    currentLocationVerticalStack?.topAnchor.constraint(equalTo: hometownVerticalStack!.bottomAnchor, constant: 40).isActive = true
    currentLocationVerticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
    continueButton = UIButton()
    continueButton?.setTitleColor(.white, for: .normal)
    continueButton?.setTitle("Continue", for: .normal)
    continueButton?.titleLabel?.font = UIFont(name: "American Typewriter", size: 16)
    continueButton?.addTarget(self, action: #selector(continueButtonClicked), for: .touchUpInside)
    StyleUtilities.styleFilledButton(continueButton!)
    continueButton?.translatesAutoresizingMaskIntoConstraints = false
    continueButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
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
    continueVerticalStack?.addArrangedSubview(continueButton!)
    continueVerticalStack?.addArrangedSubview(errorLabel!)
    continueVerticalStack?.addArrangedSubview(cancelButton!)
    scrollView?.addSubview(continueVerticalStack!)
    continueVerticalStack?.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    continueVerticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    continueVerticalStack?.topAnchor.constraint(equalTo: currentLocationVerticalStack!.bottomAnchor, constant: 60).isActive = true
    continueVerticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    
    //  And finally, calculate the scrollView's contentSize
    scrollView?.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1250)
    
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
    hometownTextField?.delegate = self
    currentLocationTextField?.delegate = self
  }
  
  @objc func adjustInsetForKeyboard(_ notification: Notification) {
    
    guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    let keyboardScreenEndFrame = keyboardValue.cgRectValue
    let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    
    let willHideKeyboard = notification.name == UIResponder.keyboardWillHideNotification
    if currentSelectedTextField == dateOfBirthTextField { return }
    //  If currentSelectedTextField == dateOfBirthTextField, then sometimes it is nil, so use guard to be safe.
    guard let newBounds = currentSelectedTextField?.convert(currentSelectedTextField!.bounds, to: nil) else { return }
    print(newBounds.maxY - newBounds.height/2)
    print(keyboardViewEndFrame.minY)
    let spaceBetweenTextFieldAndKeyboard = keyboardViewEndFrame.minY - newBounds.maxY
    print("spacing: \(spaceBetweenTextFieldAndKeyboard)")
    if spaceBetweenTextFieldAndKeyboard < 10 {
      if !willHideKeyboard { // if keyboard will show
        scrollView!.setContentOffset(CGPoint(x: 0, y: scrollView!.contentOffset.y + abs(spaceBetweenTextFieldAndKeyboard) + 20), animated: true)
      }
    }
    scrollView!.scrollIndicatorInsets = scrollView!.contentInset
    
    // disable or enable user interaction for all views that can be interacted with
    scrollView!.isScrollEnabled = willHideKeyboard
  }
  
  private func validateFields() -> String? {
    // Check that all fields are filled in
    if firstNameTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      lastNameTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      emailTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      passwordTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      dateOfBirthTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      hometownTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
      currentLocationTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
      return "Please fill in all fields"
    }
    let cleanedPassword = passwordTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    let cleanedEmail = emailTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    if !(FormUtilities.isValidEmail(cleanedEmail)) {
      return "Please make sure your email was typed correctly."
    }
    if !(FormUtilities.isPasswordValid(cleanedPassword)) {
      return "Please make sure your password is at least 8 characters, contains a special character and a number."
    }
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM dd yyyy"
    let currentDate = dateFormatter.string(from: date)
    if Calculations.getAge(currentDate: currentDate, dateOfBirth: dateOfBirthTextField?.text ?? "January 20 2020") < 18 {
      return "You must be at least 18 years old to use this app."
    }
    return nil
  }
  
  private func showError(_ message: String) {
    errorLabel?.text = message
    errorLabel?.alpha = 1
  }
  
  private func transitionToSetUpProfile(_ firstName: String, _ lastName: String, _ email: String, _ password: String!, _ dateOfBirth: String, _ gender: String, _ preferredGender: String, _ hometown: String, _ currentLocation: String) {
    let vc = SetUpProfileViewController()
    vc.firstName = firstName
    vc.lastName = lastName
    vc.email = email
    vc.password = password
    vc.dateOfBirth = dateOfBirth
    vc.gender = gender
    vc.preferredGender = preferredGender
    vc.hometown = hometown
    vc.currentLocation = currentLocation
    show(vc, sender: nil)
  }
  
  @objc func cancelButtonClicked() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc func continueButtonClicked(_ sender: Any) {
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
      let gender = myGenderSegmentedControl?.titleForSegment(at: myGenderSegmentedControl!.selectedSegmentIndex)
      let preferredGender = preferredGenderSegmentedControl?.titleForSegment(at: preferredGenderSegmentedControl!.selectedSegmentIndex)
      let hometown = hometownTextField?.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      let currentLocation = currentLocationTextField?.text!.trimmingCharacters(in: .whitespacesAndNewlines)

      // TODO: if email does not already exist, then:
      self.transitionToSetUpProfile(firstName, lastName, email, password, dateOfBirth!, gender!, preferredGender!, hometown!, currentLocation!)
    }
  }
  
  @objc private func doneEditingDatePicker() {
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
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    currentSelectedTextField = textField
  }
  
  
}
