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
    let db = Firestore.firestore()
    
    // Get all documents (chatRooms) inside the activeChatRooms collection that are not full
    db.collection("activeChatRooms").whereField("isFull", isEqualTo: false).getDocuments { (querySnapshot, err) in
      if err != nil {
        print("Error when fetching documents in activeChatRooms")
      } else {
        if querySnapshot!.documents.count == 0 {
          print("There are no empty chat rooms. Creating a new one now.")
          var reference: CollectionReference? = nil
          let aChatRoomID = UUID().uuidString
          let aConversationID = UUID().uuidString
          reference = db.collection(["activeChatRooms", aChatRoomID, aConversationID].joined(separator: "/"))
          reference?.parent!.setData([
            "conversationID": aConversationID,
            "isFull": false,
            "person0uid": "\(self.currentUser!.uid)",
            "person1uid": ""
          ]) { err in
            if let err = err {
              print("Error adding document: \(err)")
            }
          }
          
          let vc = TextChatViewController(user: self.currentUser!, reference: reference)
          vc.modalPresentationStyle = .fullScreen
          self.present(vc, animated: true, completion: nil)
        }
        else {
          print("Joining an already existing chat room.")
          let aChatRoom = querySnapshot!.documents[querySnapshot!.count-1] // the last in the array AKA the chat room that has been waiting the longest
          let aChatRoomID = aChatRoom.documentID
          db.collection("activeChatRooms").document(aChatRoomID).updateData([
            "isFull": true,
            "person1uid": self.currentUser!.uid
          ])
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
    }
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
