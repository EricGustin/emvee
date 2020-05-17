//
//  ViewController.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {

 @IBOutlet weak var signUpButton: UIButton!
 @IBOutlet weak var loginButton: UIButton!
 override func viewDidLoad() {
  super.viewDidLoad()
  setUpElements()
  // Do any additional setup after loading the view.
 }
 
 override func viewDidAppear(_ animated: Bool) {
 print("In WelcomeViewController")
  print("User is signed in?: \(UserDefaults.standard.bool(forKey: "isUserSignedIn"))")
  //UserDefaults.standard.set(false, forKey: "isUserSignedIn")
  if Auth.auth().currentUser?.uid == nil { // check if as user is signed in 
    UserDefaults.standard.set(false, forKey: "isUserSignedIn")
  }
  if UserDefaults.standard.bool(forKey: "isUserSignedIn") {
   transitionToHome()
  }
}

 func transitionToHome() {
  let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
  
  view.window?.rootViewController = homeViewController
  view.window?.makeKeyAndVisible()
 }

 func setUpElements() {
  StyleUtilities.styleFilledButton(signUpButton)
  StyleUtilities.styleHollowButton(loginButton)
 }

}

