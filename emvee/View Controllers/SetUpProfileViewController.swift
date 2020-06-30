//
//  SetUpProfileViewController.swift
//  emvee
//
//  Created by Eric Gustin on 6/30/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class SetUpProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
  
//  @objc func signUpClicked(_ sender: Any) {
//    // Validate fields
//    let error = validateFields()
//    if error != nil {
//      showError(error!)
//    }
//      // Create user
//    else {
//      // Create cleaned version of data
//      let firstName = firstNameTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//      let lastName = lastNameTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//      let email = emailTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//      let password = passwordTextField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//      let dateOfBirth = dateOfBirthTextField?.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//      Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
//        // Check for errors
//        if err != nil {
//          // There is an error
//          self.showError("Error creating user")
//        }
//        else {
//          // User created successfully. Store relevent informastion
//          let db = Firestore.firestore() // initialize an instance of Cloud Firestore
//          let userID = Auth.auth().currentUser?.uid
//
//          // Add a new document with a custom ID
//          db.collection("users").document(userID!).setData([
//            "firstName": firstName,
//            "lastName": lastName,
//            "birthday": dateOfBirth!,
//            "uid": userID!,
//            "bio": "",
//          ])
//
//          // Add the user to the onlineUsers document
//          db.collection("onlineUsers").document(userID!).setData(["userID": userID!])
//          print("successfully added user to onlineUsers collection")
//
//          // Transition to homescreen
//          self.transitionToHome()
//        }
//      }
//    }
//  }

//  private func transitionToHome() {
//    let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
//
//    view.window?.rootViewController = homeViewController
//    view.window?.makeKeyAndVisible()
//  }

}
