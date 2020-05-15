//
//  HomeViewController.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import InputBarAccessoryView
import MessageKit

class HomeViewController: UIViewController, UIViewControllerTransitioningDelegate {
 @IBOutlet weak var profileButton: UIButton!
 @IBAction func profileButtonClicked(_ sender: UIButton) {
  transitionToProfile()
 }
  @IBAction func goToTextChatVC(_ sender: UIButton) {
    let basicExampleViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.basicExampleViewController) as? BasicExampleViewController
    // Make profile ViewController appear fullscrean
    view.window?.rootViewController = basicExampleViewController
    view.window?.makeKeyAndVisible()
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
