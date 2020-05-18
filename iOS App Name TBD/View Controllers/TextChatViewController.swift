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

final class TextChatViewController: MessagesViewController {
  
  private let db = Firestore.firestore()
  private var reference: CollectionReference? // reference to database
  
  private let user: User
  private let channel: Channel
  private var messages: [Message] = []
  private var messageListener: ListenerRegistration?
  
  init(user: User, channel: Channel) {
    self.user = user
    self.channel = channel
    super.init(nibName: nil, bundle: nil)
    title = "Time left"
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    messageListener?.remove()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.becomeFirstResponder()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    print("view did disappear")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("TextChatViewController")
    guard let id = channel.id else {
      navigationController?.popViewController(animated: true)
      print("Uh oh. Pop view controller: There is no channel.id")
      return
    }
    
    let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
    view.addSubview(navBar)

    let navItem = UINavigationItem(title: "Messages")
    let backItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(backToHome))
    navItem.rightBarButtonItem = backItem
    navBar.setItems([navItem], animated: false)
    print(view.safeAreaInsets.bottom)
    
    reference = db.collection(["channels", id, "thread"].joined(separator: "/"))
    
    messageListener = reference?.addSnapshotListener({ (querySnapshot, error) in
      guard let snapshot = querySnapshot else {
        print("Error when listening for channel updates \(error?.localizedDescription ?? "No error")")
        return
      }
      
      snapshot.documentChanges.forEach { change in
        self.handleDocumentChange(change)
      }
    })
    
    navigationItem.largeTitleDisplayMode = .never
    
    maintainPositionOnKeyboardFrameChanged = true
    messageInputBar.inputTextView.tintColor = .systemBlue
    messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
    
    messageInputBar.delegate = self
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
    print("end of viewdidload")
    
  }


  // MARK: - Actions
  @objc func backToHome() {
//    let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
//    // Make profile ViewController appear fullscrean
//    view.window?.rootViewController = homeViewController
//    view.window?.makeKeyAndVisible()
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Helpers
  
  private func save(_ message: Message) {
    reference?.addDocument(data: message.representation) { error in
      if let e = error {
        print("Error sending message: \(e.localizedDescription)")
        return
      }
      
      self.messagesCollectionView.scrollToBottom()
    }
  }

  private func insertNewMessage(_ message: Message) {
    print("insert new message entered")
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
    print("insert new message exited")
  }
  
  private func handleDocumentChange(_ change: DocumentChange) {
    print("enter handleDocumentChange")
    print("change: \(change.document)")
    guard let message = Message(document: change.document) else {
      return
    }
    print("document change with message: \(message)")
    
    switch change.type {
      case .added:
      insertNewMessage(message)
      default: break
    }
  }

  
}

// MARK: - MessagesDataSource

extension TextChatViewController: MessagesDataSource {
  

  // 1
  func currentSender() -> SenderType {
    return Sender(senderId: user.uid, displayName: "eric")
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
    print("celltoplabel entered")
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
    print("display header entered/exited")
    return true // you can use this method to display things like timestamp of a message
  }

  func messageStyle(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft

    // 3
    return .bubbleTail(corner, .curved)
  }
}


// MARK: - MessagesLayoutDelegate

extension TextChatViewController: MessagesLayoutDelegate {

  func avatarSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {

    // 1
    return .zero // returning zero for the avatar will hide it from the view
  }

  func footerViewSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {
    print("size of footer entered")
    // 2
    return CGSize(width: 0, height: 8) // add padding for better readability
  }

  func heightForLocation(message: MessageType, at indexPath: IndexPath,
    with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

    // 3
    print("height entered/exit")
    return 0 // probably won't need to use location messages so just make the height zero for now
  }
}


// MARK: - MessageInputBarDelegate

extension TextChatViewController: InputBarAccessoryViewDelegate {
  
  @objc(inputBar:didPressSendButtonWith:) func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

    // 1
    print("inputbar entered")
    let message = Message(user: user, content: text)

    // 2
    save(message)

    // 3
    inputBar.inputTextView.text = ""
    print("inputbar exit")
  }
  
  @objc(inputBar:didChangeIntrinsicContentTo:) func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
    print("Intrinsic content changed")
  }
  
  @objc(inputBar:textViewTextDidChangeTo:) func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
    print("textViewDidChangeTo")
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
