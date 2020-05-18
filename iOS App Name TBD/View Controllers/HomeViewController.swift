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
import FirebaseAuth

class HomeViewController: UIViewController, UIViewControllerTransitioningDelegate {
  let currentUser = Auth.auth().currentUser
 @IBOutlet weak var profileButton: UIButton!
 @IBAction func profileButtonClicked(_ sender: UIButton) {
  transitionToProfile()
 }

  @IBAction func goToTextChatVC(_ sender: Any) {
    var channel = Channel(name: "\(currentUser!.uid)Channel")
    channel.id = currentUser!.uid
    
    let vc = TextChatViewController(user: currentUser!, channel: channel)
//    view.window?.rootViewController = vc
//    view.window?.makeKeyAndVisible()
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil)
    
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
