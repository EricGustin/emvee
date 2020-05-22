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
    var reference: CollectionReference? = nil
    let db = Firestore.firestore()
    
    // Check if there is an activeChatRoom that has isFull == false
    // if this is true, then do stuff
    // otherwise, create a new chatRoom and enter it
    db.collection("activeChatRooms").whereField("isFull", isEqualTo: false).getDocuments { (querySnapshot, err) in
      if err != nil {
        print("Error getting documents: \(String(describing: err))")
      } else {
        let aChatRoom = querySnapshot!.documents[0]
        let aChatRoomID = aChatRoom.documentID
        print(aChatRoom.data())
        let aConversationID = aChatRoom.get("conversationID") as? String ?? "noConversationID"
        print(aConversationID)
//        for document in querySnapshot!.documents {
//          print("\(document.documentID) => \(document.data())")
          //db.collection("users").document(userID).updateData([fieldName: newValue])
//        }

        let vc = TextChatViewController(user: self.currentUser!, chatRoomID: aChatRoomID, conversationID: aConversationID)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
          }
        }

//    let aChatRoomID = UUID().uuidString
//    let aConversationID = UUID().uuidString
//    reference = db.collection(["activeChatRooms", aChatRoomID, aConversationID].joined(separator: "/"))
//    reference?.parent!.setData([
//      "conversationID": aConversationID,
//      "isFull": false,
//      "person0uid": "\(currentUser!.uid)",
//      "person1uid": ""
//
//    ]) { err in
//      if let err = err {
//        print("Error adding document: \(err)")
//      }
//    }
//
//    let vc = TextChatViewController(user: currentUser!, reference: reference)
////    view.window?.rootViewController = vc
////    view.window?.makeKeyAndVisible()
//    vc.modalPresentationStyle = .fullScreen
//    self.present(vc, animated: true, completion: nil)
    
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
