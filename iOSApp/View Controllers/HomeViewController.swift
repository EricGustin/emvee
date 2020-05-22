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
import Firebase

class HomeViewController: UIViewController, UIViewControllerTransitioningDelegate {
  let currentUser = Auth.auth().currentUser
  @IBOutlet weak var profileButton: UIButton!
  @IBOutlet weak var findingPerfectMatchLabel: UILabel!
  
  @IBAction func profileButtonClicked(_ sender: UIButton) {
    transitionToProfile()
  }

  @IBAction func joinChatRoom(_ sender: Any) {
    findingPerfectMatchLabel.text = "Finding you the perfect match"
    
    // 1. iterate through the activeChatrooms collection
    
    
    
    var chatRoom = ChatRoom(name: "\(currentUser!.uid)Channel")
    chatRoom.id = currentUser!.uid
    
    let vc = TextChatViewController(user: currentUser!, chatRoom: chatRoom)
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
