//
//  TextChatViewController.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/15/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import FirebaseFirestore
import InputBarAccessoryView
import FirebaseAuth

final class TextChatViewController: MessagesViewController {
  
  private let db = Firestore.firestore()
  private var conversationRef: CollectionReference? // reference to database
  private let chatRoomID: String
  private let conversationID: String
  
  private let chatRoomRef: DocumentReference?
  
  private let user: User
  private var messages: [Message] = []
  private var messageListener: ListenerRegistration?
  private var userJoinedListener: ListenerRegistration?
  
  private var navBar = UINavigationBar()
  private var navItem = UINavigationItem(title: "Waiting for a stranger to join")
  private var backItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(backToHome))
  
  private var timeLeft = 2
  private var timer: Timer!
  
  init(user: User, chatRoomID: String, conversationID: String) { // initializer for joining an already existing chat room
    self.user = user
    self.chatRoomID = chatRoomID
    self.conversationID = conversationID
    self.chatRoomRef = db.collection("activeChatRooms").document(chatRoomID)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    messageListener?.remove()
    userJoinedListener?.remove()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if UserDefaults.standard.bool(forKey: "isComingFromVideoChat") {
      UserDefaults.standard.set(false, forKey: "isComingFromVideoChat")
      dismiss(animated: false, completion: nil)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.becomeFirstResponder()
  }
  
  override func viewSafeAreaInsetsDidChange() {
    navBar = UINavigationBar(frame: CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.size.width, height: 44))
    view.addSubview(navBar)
    navItem.rightBarButtonItem = backItem
    navBar.setItems([navItem], animated: false)
    
    let topInset: CGFloat = navBar.frame.maxY
    messagesCollectionView.contentInset.top = topInset
    messagesCollectionView.scrollIndicatorInsets.top = topInset
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //self.view.backgroundColor = UIColor.white
    if conversationRef == nil {
      conversationRef = db.collection("activeChatRooms").document(chatRoomID).collection(conversationID)
    }
    // the chat's id is ref!.documentID
    messageListener = conversationRef?.addSnapshotListener({ (querySnapshot, error) in
      guard let snapshot = querySnapshot else {
        print("Error when listening for conversation updates \(error?.localizedDescription ?? "ERROR")")
        return
      }
      snapshot.documentChanges.forEach { change in
        self.handleDocumentChange(change)
      }
    })
    
    userJoinedListener = chatRoomRef?.addSnapshotListener({ (querySnapshot, error) in
      guard let snapshot = querySnapshot else {
        print("Error when listening for isActive updates \(error?.localizedDescription ?? "ERROR")")
        return
      }
      
      if self.view.window != nil {
        if snapshot.get("isActive") != nil {
          let userLeftAlert = UIAlertController(title: "The stanger left the chat", message: "", preferredStyle: .alert)
          let userLeftAction = UIAlertAction(title: "OK", style: .default, handler: {
            action in self.backToHome()
          })
          userLeftAlert.addAction(userLeftAction)
          self.present(userLeftAlert, animated: true, completion: nil)
        }
      }
    })
    
    let chatRoomRef = db.collection("activeChatRooms").document(chatRoomID)
    chatRoomRef.getDocument { (document, err) in
      if let document = document, document.exists {
        guard let uid0 = document.get("person0uid") else { return }
        if uid0 as! String != self.user.uid { // case where if this is the second person in the chat
          // then this user is the second person to join, so we can get the other person's name and info without using a listener
          let otherUserRef = self.db.collection("users").document("\(uid0)")
          otherUserRef.getDocument { (userDoc, err) in
            if let userDoc = userDoc, userDoc.exists {
              // Display the other user's name and age
              let otherUserFirstName = userDoc.get("firstName") ?? "Anonymous"
              let otherUserBirthday = userDoc.get("birthday") ?? ""
              let date = Date()
              let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "MMMM dd yyyy"
              let currentDate = dateFormatter.string(from: date)
              self.navItem.title = "Talking to \(otherUserFirstName), \(self.getOtherUserAge(currentDate: currentDate, dateOfBirth: otherUserBirthday as! String))"
              
              // Start countdown to video chat
              self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
            }
          }
        } else { // case where if this is a new chat room and they're the only one in it. Need to add a listener so that when the next person joins, we can get their name and age
          chatRoomRef.addSnapshotListener { (documentSnapshot, err) in
            guard let document = documentSnapshot else {
              print("Error fetching document \(err!)")
              return
            }
            guard let uid1 = document.get("person1uid") else { return }
            if uid1 as! String != "" {
              let otherUserRef = self.db.collection("users").document("\(uid1)")
              otherUserRef.getDocument { (userDoc, err) in
                if let userDoc = userDoc, userDoc.exists {
                  // Display the other user's name and age
                  let otherUserFirstName = userDoc.get("firstName") ?? "Anonymous"
                  let otherUserBirthday = userDoc.get("birthday") ?? ""
                  let date = Date()
                  let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "MMMM dd yyyy"
                  let currentDate = dateFormatter.string(from: date)
                  self.navItem.title = "Talking to \(otherUserFirstName), \(self.getOtherUserAge(currentDate: currentDate, dateOfBirth: otherUserBirthday as! String))"
                  // Start countdown to video chat
                  self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
                } else {
                  print("if let userDoc = userDoc, userDoc.exists { failed for new chat room")
                }
              }
            }
          }
        }
      }
    }
//    userJoinedListener = reference?.parent?.addSnapshotListener({ (querySnapshot, err) in
//      guard let snapshot = querySnapshot else {
//        print("Error when listening for ")
//        return
//      }
//      if snapshot.
//    })
    
    navigationItem.largeTitleDisplayMode = .never
    
    maintainPositionOnKeyboardFrameChanged = true
    messageInputBar.inputTextView.tintColor = .systemBlue
    messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
    
    messageInputBar.delegate = self
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
    // Get rid of the white space that the avatar occupies. Since avatar.isHidden == true, we don't need this whitespace
    if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
      layout.setMessageIncomingAvatarSize(.zero)
      layout.setMessageOutgoingAvatarSize(.zero)
    }
    
//    print(messagesCollectionView.frame.height)
//    messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
//    messagesCollectionView.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 20).isActive = true
//    print(messagesCollectionView.frame.height)
    
    let whiteColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    view.backgroundColor = whiteColor
    
//    guard let flowLayout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
//        print("Can't get flowLayout")
//        return
//    }
//    flowLayout.collectionView?.backgroundColor = whiteColor
    
  }
  
  // MARK: - Actions
  @objc func backToHome() {
    print("isFull set to true. no longer joinable")
    chatRoomRef?.updateData(["isFull": true, "isActive": false])
    dismiss(animated: true, completion: nil)
  }
  
  @objc func counter() {
    timeLeft -= 1
    if timeLeft >= 0 {
      if timeLeft <= 5 {
        navItem.title = "Time until video chat: \(timeLeft)"
      }
      if timeLeft == 0 {
        transitionToVideoChat()
      }
    }
  }
  
  // MARK: - Helpers
  
  private func save(_ message: Message) {
    conversationRef?.addDocument(data: message.representation) { error in
      if let e = error {
        print("Error sending message: \(e.localizedDescription)")
        return
      }
      
      self.messagesCollectionView.scrollToBottom()
    }
  }
  
  private func insertNewMessage(_ message: Message) {
    guard !messages.contains(message) else {
      return
    }
    messages.append(message)
    messages.sort()
    let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
    let shouldScrollToBottom = isLatestMessage // && messagesCollectionView.isAtBottom
    messagesCollectionView.reloadData()
    if shouldScrollToBottom {
      DispatchQueue.main.async {
        self.messagesCollectionView.scrollToBottom(animated: true)
      }
    }
  }
  
  private func handleDocumentChange(_ change: DocumentChange) {
    guard let message = Message(document: change.document) else {
      return
    }
    switch change.type {
      case .added:
        insertNewMessage(message)
      default: break
    }
  }
  
  // MARK: Calculations
  func getOtherUserAge(currentDate: String, dateOfBirth: String) -> Int {
    let currentDateArray: [String] = currentDate.wordList
    let dateOfBirthArray: [String] = dateOfBirth.wordList
    var age = Int(currentDateArray[2])! - Int(dateOfBirthArray[2])!
    if (Constants.Dates.months[dateOfBirthArray[0]] ?? 0 > Constants.Dates.months[currentDateArray[0]] ?? 0) {
      age -= 1
    } else if (dateOfBirthArray[0] == currentDateArray[0]) {
      if (dateOfBirthArray[1] > currentDateArray[1]) {
        age -= 1
      }
    }
    return age
  }
  
  // MARK: Transition
  func transitionToVideoChat() {
    // hide views so that when the user transitions from video -> text -> home, they don't see their old conversation
    navBar.isHidden = true
    messageInputBar.isHidden = true
    messagesCollectionView.isHidden = true
    
    let vc = VideoChatViewController(chatRoomID: chatRoomID)
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil)
  }

}

// MARK: - MessagesDataSource

extension TextChatViewController: MessagesDataSource {
  // 1
  func currentSender() -> SenderType {
    var displayName: String = ""
    db.collection("users").document(user.uid).getDocument { (snapshot, error) in
    if let document = snapshot {
      displayName = document.get("firstName") as! String
      }
    }
    return Sender(senderId: user.uid, displayName: displayName)
  }
  
  // 2
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    return messages.count
  }
  
  // 3
  func messageForItem(at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
  
  // 4
  func cellTopLabelAttributedText(for message: MessageType,
                                  at indexPath: IndexPath) -> NSAttributedString? {
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor(white: 0.3, alpha: 1)
      ]
    )
  }
}


extension TextChatViewController: MessagesDisplayDelegate {
  
  func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                       in messagesCollectionView: MessagesCollectionView) -> UIColor {
    // 1
    return isFromCurrentSender(message: message) ? .blue : .gray
  }
  
  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                           in messagesCollectionView: MessagesCollectionView) -> Bool {
    // 2
    return false // you can use this method to display things like timestamp of a message
  }
  
  func messageStyle(for message: MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    // 3
    return .bubbleTail(corner, .curved)
  }
  
  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    avatarView.isHidden = true
  }
}


// MARK: - MessagesLayoutDelegate

extension TextChatViewController: MessagesLayoutDelegate {
  
  func avatarSize(for message: MessageType, at indexPath: IndexPath,
                  in messagesCollectionView: MessagesCollectionView) -> CGSize {
    // 1
    print("in avatar size")
    
    return .zero // returning zero for the avatar will hide it from the view
  }
  
  func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> CGSize {
    // 2
    return CGSize(width: 0, height: 8) // add padding for better readability
  }
  
  func heightForLocation(message: MessageType, at indexPath: IndexPath,
                         with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    // 3
    return 0 // probably won't need to use location messages so just make the height zero for now
  }
}


// MARK: - MessageInputBarDelegate

extension TextChatViewController: InputBarAccessoryViewDelegate {
  
  @objc(inputBar:didPressSendButtonWith:) func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    // 1
    let message = Message(user: user, content: text)
    // 2
    save(message)
    // 3
    inputBar.inputTextView.text = ""
  }
  
  @objc(inputBar:didChangeIntrinsicContentTo:) func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
  }
  
  @objc(inputBar:textViewTextDidChangeTo:) func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
  }
  
}

// MARK: - UIImagePickerControllerDelegate

extension TextChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
}

extension TextChatViewController: MessageLabelDelegate {
  
  func didSelectAddress(_ addressComponents: [String: String]) {
    print("Address Selected: \(addressComponents)")
  }
  
  func didSelectDate(_ date: Date) {
    print("Date Selected: \(date)")
  }
  
  func didSelectPhoneNumber(_ phoneNumber: String) {
    print("Phone Number Selected: \(phoneNumber)")
  }
  
  func didSelectURL(_ url: URL) {
    print("URL Selected: \(url)")
  }
  
  func didSelectTransitInformation(_ transitInformation: [String: String]) {
    print("TransitInformation Selected: \(transitInformation)")
  }
  
  func didSelectHashtag(_ hashtag: String) {
    print("Hashtag selected: \(hashtag)")
  }
  
  func didSelectMention(_ mention: String) {
    print("Mention selected: \(mention)")
  }
  
  func didSelectCustom(_ pattern: String, match: String?) {
    print("Custom data detector patter selected: \(pattern)")
  }

}
