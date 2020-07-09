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

  // UIViews
  var arrowCircleImage: UIImageView!
  var arrowCircleFlippedImage: UIImageView!
  var profileButton: UIButton?
  var infoButton: UIButton?
  var getToChattingButton: UIButton?
  var containerView: UIView?
  
  // Other Variables & Constants
  var spinsRemaining = 10
  let currentUser = Auth.auth().currentUser

  @objc func profileButtonClicked(_ sender: UIButton) {
    transitionToProfile()
  }
  @objc func infoButtonClicked() {
    let infoPopup = InfoPopup()
    view.addSubview(infoPopup)
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
          let nc = NavigationController(vc)
          nc.modalPresentationStyle = .fullScreen
          self.present(nc, animated: true, completion: nil)
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
          let nc = NavigationController(vc)
          nc.modalPresentationStyle = .fullScreen
          self.present(nc, animated: true, completion: nil)
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGray6
    
    setUpViews()
    setUpGestures()
    setUpNavigationBar()
    UserDefaults.standard.set(true, forKey: "isUserSignedIn")
    UserDefaults.standard.set(false, forKey: "isComingFromVideo")
  }
  
  func setUpGestures() {
    let arrowCircleTapGesture = UITapGestureRecognizer(target: self, action: #selector(arrowCircleTapDetected))
    containerView?.addGestureRecognizer(arrowCircleTapGesture)
    
    let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(transitionToProfile))
    view.addGestureRecognizer(swipeRightGesture)
  }
  
  func setUpViews() {
  
    // set up profileButton
    profileButton = UIButton(type: .custom)
    profileButton?.translatesAutoresizingMaskIntoConstraints = false
    profileButton?.setBackgroundImage(UIImage(systemName: "person.circle"), for: .normal)
    profileButton?.tintColor = .systemTeal
    profileButton?.addTarget(self, action: #selector(profileButtonClicked), for: .touchUpInside)
    view.addSubview(profileButton!)
    profileButton?.heightAnchor.constraint(equalToConstant: 40).isActive = true
    profileButton?.widthAnchor.constraint(equalToConstant: 40).isActive = true
    
    // set up infoButton
    infoButton = UIButton(type: .custom)
    infoButton?.translatesAutoresizingMaskIntoConstraints = false
    infoButton?.setBackgroundImage(UIImage(systemName: "info.circle"), for: .normal)
    infoButton?.tintColor = .systemTeal
    infoButton?.addTarget(self, action: #selector(infoButtonClicked), for: .touchUpInside)
    view.addSubview(infoButton!)
    infoButton?.heightAnchor.constraint(equalToConstant: 40).isActive = true
    infoButton?.widthAnchor.constraint(equalToConstant: 40).isActive = true

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
    getToChattingButton?.addTarget(self, action: #selector(joinChatRoom), for: .touchUpInside)
    view.addSubview(getToChattingButton!)
    let getToChattingButtonWidth = NSLayoutConstraint(item: getToChattingButton!, attribute: .width, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .width, multiplier: 0.75, constant: 0)
    let getToChattingButtonHeight = NSLayoutConstraint(item: getToChattingButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50)
    let getToChattingButtonCenterX = NSLayoutConstraint(item: getToChattingButton!, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1.0, constant: 0)
    let getToChattingButtonCenterY = NSLayoutConstraint(item: getToChattingButton!, attribute: .centerY, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: 4/3, constant: 0)
    view.addConstraints([getToChattingButtonWidth, getToChattingButtonHeight, getToChattingButtonCenterX, getToChattingButtonCenterY])
    
    // Set up arrow circle image view and its container view
    arrowCircleImage = UIImageView(image: UIImage(named: "arrowCircle@4x"))
    arrowCircleImage.translatesAutoresizingMaskIntoConstraints = false
    arrowCircleImage.isUserInteractionEnabled = true
    
    containerView = UIView(frame: arrowCircleImage.frame)
    view.addSubview(containerView!)
    containerView?.addSubview(arrowCircleImage)
    containerView?.translatesAutoresizingMaskIntoConstraints = false
    
    // Constraints for arrowCircle view
    arrowCircleImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
    let arrowCircleBottom = NSLayoutConstraint(item: arrowCircleImage!, attribute: .bottom, relatedBy: .equal, toItem: getToChattingButton, attribute: .top, multiplier: 1.0, constant: -50)
    let arrowCircleWidth = NSLayoutConstraint(item: arrowCircleImage!, attribute: .width, relatedBy: .equal, toItem: arrowCircleImage!, attribute: .height, multiplier: 1.0, constant: 0)
    let arrowCircleCenterX = NSLayoutConstraint(item: arrowCircleImage!, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1.0, constant: 0)
    view.addConstraints([arrowCircleBottom, arrowCircleWidth, arrowCircleCenterX])
    
    let containerCenterX = containerView!.centerXAnchor.constraint(equalTo: arrowCircleImage.centerXAnchor)
    let containerBottom = containerView!.bottomAnchor.constraint(equalTo: arrowCircleImage.bottomAnchor)
    let containerWidth = containerView!.widthAnchor.constraint(equalTo: arrowCircleImage.widthAnchor)
    let containerTop = containerView!.topAnchor.constraint(equalTo: arrowCircleImage.topAnchor)
    NSLayoutConstraint.activate([containerCenterX, containerBottom, containerWidth, containerTop])
    
    view.layoutIfNeeded()
  }
  
  func setUpNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton!)
    title = "emvee"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 28), size: 28)]
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton!)
  }
  
  @objc public func arrowCircleTapDetected() {
    if arrowCircleImage.isUserInteractionEnabled {
      arrowCircleImage.isUserInteractionEnabled = false
      // Spin arrowCircleView for the first. The spinArrowCircle function will continue to call itself until spinsRemaning=0
      _ = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(spinArrowCircle(timer:)), userInfo: nil, repeats: false)
    }
  }
  
  // Helper function for arrowCircleTapDetected event
  @objc func spinArrowCircle(timer: Timer) {
    
    UIView.transition(with: arrowCircleImage, duration: 0.4 - (Double(spinsRemaining) * 0.02), options: .transitionFlipFromLeft, animations: {
      self.arrowCircleImage.image = self.arrowCircleImage.image?.withHorizontallyFlippedOrientation()
    }, completion: nil)
    
    spinsRemaining -= 1
    
    if spinsRemaining <= 0 {
      // Done spinning
      spinsRemaining = 10
      arrowCircleImage.isUserInteractionEnabled = true
    } else {
      // Spin again!
      _ = Timer.scheduledTimer(timeInterval: 0.4 - (Double(spinsRemaining) * 0.02), target: self, selector: #selector(spinArrowCircle(timer:)), userInfo: nil, repeats: false)
    }
  }
  
    
  @objc func transitionToProfile() {
//    let vc = ProfileViewController()
//    let nc = NavigationController(vc)
//    nc.modalPresentationStyle = .fullScreen
//    self.present(nc, animated: true, completion: nil)
    let vc = ProfileViewController()
    show(vc, sender: nil)
  }
  
  
  // MARK: -- NOTE THIS IS A TESTING FUNCTION AND NOT FOR PRODUCTION USE
  private func transitionToVideoChat() {
    let vc = VideoChatViewController(chatRoomID: "234")
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil)
  }
  

  
}
