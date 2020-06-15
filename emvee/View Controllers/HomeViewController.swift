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
  
  var arrowCircleImage: UIImageView!
  var profileButton: UIButton?
  var infoButton: UIButton?
  var emveeLabel: UILabel?
  var getToChattingButton: UIButton?
  
  //@IBOutlet weak var profileButton: UIButton!
  @IBOutlet weak var enterVideoChatRoomButton: UIButton!

  
  
  
  @objc func profileButtonClicked(_ sender: UIButton) {
    transitionToProfile()
  }
  @objc func infoButtonClicked() {
    
  }

  @IBAction func joinVideoChatRoom(_ sender: Any) {
    transitionToVideoChat()
  }
  
  @objc func joinChatRoom() {
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
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In HomeViewController")
    
    setUpViews()
    
    UserDefaults.standard.set(true, forKey: "isUserSignedIn")
    UserDefaults.standard.set(false, forKey: "isComingFromVideo")
    
    let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(gesture:)))
    swipeGesture.direction = .right
    view.addGestureRecognizer(swipeGesture)
  }
  
  func setUpViews() {
    // set up profileButton
    profileButton = UIButton(type: .custom)
    profileButton!.translatesAutoresizingMaskIntoConstraints = false
    profileButton!.setBackgroundImage(UIImage(systemName: "person.circle"), for: .normal)
    profileButton!.tintColor = .systemTeal
    profileButton!.addTarget(self, action: #selector(profileButtonClicked), for: .touchUpInside)
    view.addSubview(profileButton!)
    let profileButtonWidth = NSLayoutConstraint(item: profileButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
    let profileButtonHeight = NSLayoutConstraint(item: profileButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
    let profileButtonLeading = NSLayoutConstraint(item: profileButton!, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leadingMargin, multiplier: 1.0, constant: 20)
    let profileButtonTop = NSLayoutConstraint(item: profileButton!, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: 20)
    view.addConstraints([profileButtonWidth, profileButtonHeight, profileButtonLeading, profileButtonTop])
    
    // set up infoButton
    infoButton = UIButton(type: .custom)
    infoButton!.translatesAutoresizingMaskIntoConstraints = false
    infoButton!.setBackgroundImage(UIImage(systemName: "info.circle"), for: .normal)
    infoButton!.tintColor = .systemTeal
    infoButton!.addTarget(self, action: #selector(infoButtonClicked), for: .touchUpInside)
    view.addSubview(infoButton!)
    let infoButtonWidth = NSLayoutConstraint(item: infoButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
    let infoButtonHeight = NSLayoutConstraint(item: infoButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
    let infoButtontrailing = NSLayoutConstraint(item: infoButton!, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailingMargin, multiplier: 1.0, constant: -20)
    let infoButtonTop = NSLayoutConstraint(item: infoButton!, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: 20)
    view.addConstraints([infoButtonWidth, infoButtonHeight, infoButtontrailing, infoButtonTop])
    
    // Set up emvee label
    emveeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    emveeLabel?.text = "emvee"
    emveeLabel?.textColor = .black
    emveeLabel?.textAlignment = .center
    emveeLabel?.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 36), size: 36)
    emveeLabel?.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(emveeLabel!)
    let emveeLabelCenterX = NSLayoutConstraint(item: emveeLabel!, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1.0, constant: 0)
    let emveeLabelCenterY = NSLayoutConstraint(item: emveeLabel!, attribute: .centerY, relatedBy: .equal, toItem: profileButton, attribute: .centerY, multiplier: 1.0, constant: 0)
    view.addConstraints([emveeLabelCenterX, emveeLabelCenterY])
    
    // Set up GetToChattingButton
    getToChattingButton = UIButton(type: .custom)
    getToChattingButton?.setTitle("Get To Chatting", for: .normal)
    getToChattingButton?.titleLabel?.font = UIFont(name: "American Typewriter", size: 32)
    getToChattingButton?.setTitleColor(.white, for: .normal)
    getToChattingButton?.setTitleColor(.lightGray, for: .selected)
    getToChattingButton?.titleLabel?.lineBreakMode = .byWordWrapping
    getToChattingButton?.titleLabel?.textAlignment = .center
    getToChattingButton?.titleLabel?.numberOfLines = 0
    StyleUtilities.styleFilledButton(getToChattingButton!)
    getToChattingButton?.translatesAutoresizingMaskIntoConstraints = false
    getToChattingButton!.addTarget(self, action: #selector(joinChatRoom), for: .touchUpInside)
    view.addSubview(getToChattingButton!)
    let getToChattingButtonWidth = NSLayoutConstraint(item: getToChattingButton!, attribute: .width, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .width, multiplier: 0.75, constant: 0)
    let getToChattingButtonHeight = NSLayoutConstraint(item: getToChattingButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
    let getToChattingButtonCenterX = NSLayoutConstraint(item: getToChattingButton!, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1.0, constant: 0)
    let getToChattingButtonCenterY = NSLayoutConstraint(item: getToChattingButton!, attribute: .centerY, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: 4/3, constant: 0)
    view.addConstraints([getToChattingButtonWidth, getToChattingButtonHeight, getToChattingButtonCenterX, getToChattingButtonCenterY])
    
    // Set up arrow circle image view
    arrowCircleImage = UIImageView(image: UIImage(named: "arrowCircle@4x"))
    arrowCircleImage?.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(arrowCircleImage!)
    let arrowCircleTop = NSLayoutConstraint(item: arrowCircleImage!, attribute: .top, relatedBy: .equal, toItem: profileButton, attribute: .bottom, multiplier: 1.0, constant: 50)
    let arrowCircleBottom = NSLayoutConstraint(item: arrowCircleImage!, attribute: .bottom, relatedBy: .equal, toItem: getToChattingButton, attribute: .top, multiplier: 1.0, constant: -50)
    let arrowCircleWidth = NSLayoutConstraint(item: arrowCircleImage!, attribute: .width, relatedBy: .equal, toItem: arrowCircleImage!, attribute: .height, multiplier: 1.0, constant: 0)
    let arrowCircleCenterX = NSLayoutConstraint(item: arrowCircleImage!, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1.0, constant: 0)
    view.addConstraints([arrowCircleTop, arrowCircleBottom, arrowCircleWidth, arrowCircleCenterX])

  }
  
  @objc func swipeDetected(gesture: UISwipeGestureRecognizer) {
    transitionToProfile()
  }
  
  func transitionToProfile() {
    let profileViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.profileViewController) as? ProfileViewController
    // Make profile ViewController appear fullscrean
    view.window?.rootViewController = profileViewController
    view.window?.makeKeyAndVisible()
  }
  
  
  // MARK: -- NOTE THIS IS A TESTING FUNCTION AND NOT FOR PRODUCTION USE
  func transitionToVideoChat() {
    let vc = VideoChatViewController(chatRoomID: "234")
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil)
  }
  
}
