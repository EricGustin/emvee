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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let id = channel.id else {
      navigationController?.popViewController(animated: true)
      return
    }
    
    reference = db.collection(["channels", id, "thread"].joined(separator: "/"))
    
    navigationItem.largeTitleDisplayMode = .never
    
    maintainPositionOnKeyboardFrameChanged = true
    messageInputBar.inputTextView.tintColor = .systemBlue
    messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
    
    messageInputBar.delegate = self
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messagesLayoutDelegate = self
    messagesCollectionView.messagesDisplayDelegate = self
    
  }

}

extension TextChatViewController: InputBarAccessoryViewDelegate {
  
}

extension TextChatViewController: MessagesLayoutDelegate {
  
}

extension TextChatViewController: MessagesDataSource {
  
  func currentSender() -> SenderType {
    <#code#>
  }
  
  func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
    <#code#>
  }
  
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
    <#code#>
  }
  
  
}

extension TextChatViewController: MessagesDisplayDelegate {
  
}
