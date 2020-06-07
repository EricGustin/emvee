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
  @IBOutlet weak var enterChatRoomButton: UIButton!
  @IBOutlet weak var enterVideoChatRoomButton: UIButton!
  
  @IBAction func profileButtonClicked(_ sender: UIButton) {
    transitionToProfile()
  }

  @IBAction func joinVideoChatRoom(_ sender: Any) {
    transitionToVideoChat()
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
          
          let vc = TextChatViewController(user: self.currentUser!, chatRoomID: aChatRoomID, conversationID: aConversationID)
          vc.modalPresentationStyle = .fullScreen
          self.present(vc, animated: true, completion: nil)
        }
        else {
          let aChatRoom = querySnapshot!.documents[querySnapshot!.count-1] // the last in the array AKA the chat room that has been waiting the longest
          let aChatRoomID = aChatRoom.documentID
          db.collection("activeChatRooms").document(aChatRoomID).updateData([
            "isFull": true,
            "person1uid": self.currentUser!.uid
          ])
          print(aChatRoom.data())
          let aConversationID = aChatRoom.get("conversationID") as? String ?? "noConversationID"

          let vc = TextChatViewController(user: self.currentUser!, chatRoomID: aChatRoomID, conversationID: aConversationID)
          vc.modalPresentationStyle = .fullScreen
          self.present(vc, animated: true, completion: nil)
        }
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    findingPerfectMatchLabel.text = "Welcome!"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In homeViewController")
    UserDefaults.standard.set(true, forKey: "isUserSignedIn")
    StyleUtilities.styleFilledButton(enterChatRoomButton)
  }
  
  func transitionToProfile() {
    let profileViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.profileViewController) as? ProfileViewController
    // Make profile ViewController appear fullscrean
    view.window?.rootViewController = profileViewController
    view.window?.makeKeyAndVisible()
  }
  
  func transitionToVideoChat() {
//    let videoChatViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.videoChatViewController) as? VideoChatViewController
//    // Make profile ViewController appear fullscrean
//    videoChatViewController?.roomName = "234"
//    view.window?.rootViewController = videoChatViewController
//    view.window?.makeKeyAndVisible()
    
    let vc = VideoChatViewController(chatRoomID: "234")
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil)
  }
  
}
