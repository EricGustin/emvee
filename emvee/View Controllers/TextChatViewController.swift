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
  private var localUserName: String?
  private var localProfilePicture: UIImage?
  private var remoteProfilePicture: UIImage?
  private var remoteAboutMeText: String?
  private var remoteUserUID: String?

  private var remoteNameAndAge: String?
  
  private let chatRoomRef: DocumentReference?
  
  private let localUser: User
  private var messages: [Message] = []
  private var messageListener: ListenerRegistration?
  private var userJoinedListener: ListenerRegistration?
  
  private var timeLeft = 75
  private var timer: Timer?
  private var localUserLeftChat: Bool?
  
  private var profilePreviewPopup: ProfilePreviewPopup?
  
  init(user: User, chatRoomID: String, conversationID: String) { // initializer for joining an already existing chat room
    self.localUser = user
    self.chatRoomID = chatRoomID
    self.conversationID = conversationID
    self.chatRoomRef = db.collection("activeChatRooms").document(chatRoomID)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    print("Deinit")
    messageListener?.remove()
    userJoinedListener?.remove()
    // timer.invalidate() NOTE: ONCE I FIX THE MEMORY LEAK I CAN UNCOMMENT THIS
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
    
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In TextChatViewController")
    addNotifications()
    
    if conversationRef == nil {
      conversationRef = db.collection("activeChatRooms").document(chatRoomID).collection(conversationID)
    }
    
    let localUserRef = db.collection("users").document("\(localUser.uid)")
    localUserRef.getDocument { (userDoc, err) in
      print("document exists")
      if let userDoc = userDoc, userDoc.exists {
        self.localUserName = userDoc.get("firstName") as? String
      }
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
      
      if self.timer != nil {
        self.timer!.invalidate()
        self.timer = nil
      }
      if !(self.localUserLeftChat ?? false) {
        if snapshot.get("isActive") != nil { // if its not nil, then it is must be false i.e chat has ended
          
          
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
        if uid0 as! String != self.localUser.uid { // case where if this is the second person in the chat
          // then this user is the second person to join, so we can get the other person's name and info without using a listener
          self.remoteUserUID = uid0 as? String
          let remoteUserRef = self.db.collection("users").document("\(uid0)")
          remoteUserRef.getDocument { (userDoc, err) in
            if let userDoc = userDoc, userDoc.exists {
              self.chatRoomRef?.updateData(["isFull": true]) // make the chat room unjoinable
              
              self.messageInputBar.inputTextView.tintColor = .systemBlue
              self.messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
              self.messageInputBar.delegate = self
              
              // Get the remote user's profile picture so that it can be displayed as an avatar
              self.downloadProfilePictureFromFirebase(uid: uid0 as! String)
              
              // Display the other user's name and age
              let remoteName = userDoc.get("firstName") as? String
              let remoteUserBirthday = userDoc.get("birthday") ?? ""
              self.remoteAboutMeText = userDoc.get("bio") as? String
              let date = Date()
              let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "MMMM dd yyyy"
              let currentDate = dateFormatter.string(from: date)
              self.remoteNameAndAge = "\(remoteName ?? "User"), \(self.getOtherUserAge(currentDate: currentDate, dateOfBirth: remoteUserBirthday as! String))"
              self.title = "Talking to \(self.remoteNameAndAge ?? "User")"
              
              // Start countdown to video chat
              if self.timer == nil {
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
              }
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
              self.remoteUserUID = uid1 as? String
              let remoteUser = self.db.collection("users").document("\(uid1)")
              remoteUser.getDocument { (userDoc, err) in
                if let userDoc = userDoc, userDoc.exists {
                  self.chatRoomRef?.updateData(["isFull": true]) // make the chat room unjoinable
                  
                  self.messageInputBar.inputTextView.tintColor = .systemBlue
                  self.messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
                  self.messageInputBar.delegate = self
                  
                  // Get the remote user's profile picture so that it can be displayed as an avatar
                  self.downloadProfilePictureFromFirebase(uid: uid1 as! String)
                  
                  // Display the other user's name and age
                  let remoteName = userDoc.get("firstName") as? String
                  let remoteUserBirthday = userDoc.get("birthday") ?? ""
                  self.remoteAboutMeText = userDoc.get("bio") as? String
                  let date = Date()
                  let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "MMMM dd yyyy"
                  let currentDate = dateFormatter.string(from: date)
                  self.remoteNameAndAge = "\(remoteName ?? "User"), \(self.getOtherUserAge(currentDate: currentDate, dateOfBirth: remoteUserBirthday as! String))"
                  self.title = "Talking to \(self.remoteNameAndAge ?? "User")"
                  // Start countdown to video chat
                  if self.timer == nil {
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
                  }
                } else {
                  print("if let userDoc = userDoc, userDoc.exists { failed for new chat room")
                }
              }
            }
          }
        }
      }
    }
    
    navigationItem.largeTitleDisplayMode = .never
    
    maintainPositionOnKeyboardFrameChanged = true
    
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
    let whiteColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    view.backgroundColor = whiteColor
    
    downloadProfilePictureFromFirebase(uid: localUser.uid)
    setUpNavigationBar()
  }
  
  private func addNotifications() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(backToHome), name: UIApplication.didEnterBackgroundNotification, object: nil)
  }
  
  private func setUpNavigationBar() {
    title = "Waiting for a stanger to join"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 16), size: 16)]
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Leave", style: .done, target: self, action: #selector(backToHome))
    navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Semibold", size: 16), size: 16)], for: .normal)
    navigationItem.leftBarButtonItem = UIBarButtonItem() // Temporary is overwritten once the remote user joins the chat.
  }
  
  // MARK: - Actions
  @objc func backToHome() {
    chatRoomRef?.updateData(["isFull": true, "isActive": false])
    if timer != nil {
      timer!.invalidate()
      timer = nil
    }
    if self.timer != nil {
      self.timer!.invalidate()
      self.timer = nil
    }
    inputAccessoryView?.isHidden = true
    inputAccessoryView?.resignFirstResponder()
    localUserLeftChat = true
    navigationController?.popViewControllerToBottom()
  }
  
  @objc func counter() {
    
    if timeLeft > 0 {
      timeLeft -= 1
      if timeLeft <= 50 {
//        navItem.title = "Time until video chat: \(timeLeft)"
        self.title = "Time until video chat: \(timeLeft)"
      }
    }

    if timeLeft == 0 {
      chatRoomRef?.getDocument(completion: { (document, err) in
        if let document = document, document.exists {
          if document.get("isActive") == nil {
            self.timer!.invalidate() // NOTE: Get rid of this line when memory leak is fixed
            self.transitionToVideoChat()
          } else {
            self.dismiss(animated: true, completion: nil)
            self.backToHome()
          }
        }
      })
    }
  }
  
  private func downloadProfilePictureFromFirebase(uid: String) {
    
    let profilePictureRef = Storage.storage().reference().child("profilePictures/\(uid)/picture0")
    // Download profile picture in memory  with a maximum allowed size of 1MB
    profilePictureRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
      if error != nil {
        return
      } else {
        let profileImage = UIImage(data: data!)
        if self.localUser.uid == uid {
          self.localProfilePicture = profileImage!
            //?? UIImage(named: "defaultProfileImage")!
        } else {
          self.remoteProfilePicture = profileImage ?? UIImage(named: "defaultProfileImage")!
          
          //  Set up the left navigation item (remote person's profile picture)
          let leftNavigationItemButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
          leftNavigationItemButton.setImage(self.remoteProfilePicture, for: .normal)
          leftNavigationItemButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showRemoteProfilePopup)))
          leftNavigationItemButton.imageView?.contentMode = .scaleAspectFill
          leftNavigationItemButton.imageView?.layer.cornerRadius = 22
          let leftNavigationItemButtonContainer = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 44, height: 44)))
          leftNavigationItemButtonContainer.addSubview(leftNavigationItemButton)
          let leftButton = UIBarButtonItem(customView: leftNavigationItemButtonContainer)
          self.navigationItem.leftBarButtonItem = leftButton

        }
      }
    }
  }
  
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
  
  private func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
      guard indexPath.section + 1 < messages.count else { return false }
    return messages[indexPath.section].sender.senderId == messages[indexPath.section + 1].sender.senderId
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
    messageInputBar.isHidden = true
    messagesCollectionView.isHidden = true
    navigationController?.navigationBar.isHidden = true
    
    let vc = VideoChatViewController(chatRoomID: chatRoomID)
    navigationController?.pushViewControllerFromBottom(rootVC: vc)
  }
  
  @objc public func showRemoteProfilePopup() {
    if profilePreviewPopup == nil || !profilePreviewPopup!.isDescendant(of: view) {
      profilePreviewPopup = ProfilePreviewPopup(name: remoteNameAndAge, aboutMeText: remoteAboutMeText, remoteUserUID: remoteUserUID)
      view.addSubview(profilePreviewPopup!)
    }
  }

}

// MARK: - MessagesDataSource

extension TextChatViewController: MessagesDataSource {
  // 1
  func currentSender() -> SenderType {
    return Sender(senderId: localUser.uid, displayName: localUserName ?? "Anonymous")
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
      attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1),
                   NSAttributedString.Key.foregroundColor: UIColor.black ]
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

    let avatar = (message.sender.senderId == localUser.uid) ? Avatar(image: localProfilePicture, initials: "EG") : Avatar(image: remoteProfilePicture, initials: "EG")

    avatarView.set(avatar: avatar)
    print("Index path: \(indexPath)")
    avatarView.isHidden = isNextMessageSameSender(at: indexPath)
    avatarView.layer.borderWidth = 2
    avatarView.layer.borderColor = UIColor.blue.cgColor
    print("avatar stuff")
    avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showRemoteProfilePopup)))
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
  
  func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
   // return 18
    return 0
  }
}


// MARK: - MessageInputBarDelegate

extension TextChatViewController: InputBarAccessoryViewDelegate {
  
  @objc(inputBar:didPressSendButtonWith:) func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    // 1
    let message = Message(user: localUser, content: text)
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
