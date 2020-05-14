//
//  HomeViewController.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIViewControllerTransitioningDelegate {
 @IBOutlet weak var profileButton: UIButton!
 @IBAction func profileButtonClicked(_ sender: UIButton) {
  transitionToProfile()
 }
 
 //let transition = PopAnimator()



 override func viewDidLoad() {
  super.viewDidLoad()
  print("In homeViewController")
  UserDefaults.standard.set(true, forKey: "isUserSignedIn")
 }
 
 func transitionToProfile() {
  let profileViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.profileViewController) as? ProfileViewController
  // Make profile ViewController appear fullscrean
  view.window?.rootViewController = profileViewController
  view.window?.makeKeyAndVisible()
 }
}
