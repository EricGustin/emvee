//
//  SetUpProfileViewController.swift
//  emvee
//
//  Created by Eric Gustin on 6/30/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SetUpProfileViewController: EditableProfileSuperViewController {
  
  var firstName: String!
  var lastName: String!
  var email: String!
  var password: String!
  var dateOfBirth: String!
  var gender: String!
  var preferredGender: String!
  var hometown: String!
  var currentLocation: String!
  
  private var signUpButton: UIButton?
  private var errorLabel: UILabel?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpNavigationBar()
    setUpSubviews()
  }
  
  private func setUpNavigationBar() {
    title = "Set Up Profile"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "American Typewriter", size: 28)!]
    navigationController?.navigationBar.backgroundColor = .systemGray6
  }
  
  private func setUpSubviews() {
    
    signUpButton = UIButton()
    signUpButton?.setTitleColor(.white, for: .normal)
    signUpButton?.setTitle("Continue", for: .normal)
    signUpButton?.titleLabel?.font = UIFont(name: "American Typewriter", size: 16)
    signUpButton?.addTarget(self, action: #selector(signUpButtonClicked), for: .touchUpInside)
    StyleUtilities.styleFilledButton(signUpButton!)
    scrollView.addSubview(signUpButton!)
    signUpButton?.translatesAutoresizingMaskIntoConstraints = false
    signUpButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    signUpButton?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5).isActive = true
    signUpButton?.topAnchor.constraint(equalTo: aboutMeTextView.bottomAnchor, constant: 60).isActive = true
    signUpButton?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    errorLabel = UILabel()
    errorLabel?.textAlignment = .center
    errorLabel?.numberOfLines = 0
    errorLabel?.textColor = .systemRed
    errorLabel?.font = UIFont(name: "American Typewriter", size: 16)
    errorLabel?.alpha = 0
    scrollView.addSubview(errorLabel!)
    errorLabel?.translatesAutoresizingMaskIntoConstraints = false
    errorLabel?.heightAnchor.constraint(equalToConstant: 80).isActive = true
    errorLabel?.topAnchor.constraint(equalTo: signUpButton!.bottomAnchor, constant: 40).isActive = true
    errorLabel?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    errorLabel?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
  }
  
    @objc func signUpButtonClicked(_ sender: Any) {
      // Validate fields
      let error = validateProperSetUp()
      if error != nil {
        showError(error!)
      }
        // Create user
      else {
        let bio = aboutMeTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
          // Check for errors
          if err != nil {
            // There is an error
            self.showError("Error creating user.")
          }
          else {
            // User created successfully. Store relevent informastion
            let db = Firestore.firestore() // initialize an instance of Cloud Firestore
            let userID = Auth.auth().currentUser?.uid
  
            // Add a new document with a custom ID
            db.collection("users").document(userID!).setData([
              "firstName": self.firstName!,
              "lastName": self.lastName!,
              "birthday": self.dateOfBirth!,
              "gender": self.gender!,
              "preferredGender": self.preferredGender!,
              "hometown": self.hometown!,
              "currentLcoation": self.currentLocation!,
              "uid": userID!,
              "bio": bio
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
  
  private func validateProperSetUp() -> String? {
    if aboutMeTextView.text == "" {
      return "You must have a bio before you can create an account."
    } else if profilePictures[0].image == UIImage(systemName: "plus") {
      return "You must have at least one profile picture before you can create an account"
    }
    return nil
  }
  
  private func showError(_ message: String) {
    errorLabel?.text = message
    errorLabel?.alpha = 1
  }
  
    private func transitionToHome() {
      let vc = HomeViewController()
      let nc = NavigationController(vc)
      nc.modalPresentationStyle = .fullScreen
      self.present(nc, animated: true, completion: nil)
    }
  
}
