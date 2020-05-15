//
//  Message.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/15/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import Firebase
import MessageKit
import FirebaseFirestore

struct Message {
  
  let id: String?
  let content: String
  let sentDate: Date
  let sender: SenderType
  
  var data: MessageKind {
      return .text(content)
  }
  
  var messageId: String {
    return id ?? UUID().uuidString
  }
  
  var downloadURL: URL? = nil
  
  init(user: User, content: String) {
    sender = Sender(senderId: user.uid, displayName: "eric")
    self.content = content
    id = nil
    sentDate = Date()
  }
  
  init?(document: QueryDocumentSnapshot) {
    let data = document.data()
    
    guard let sentDate = data["created"] as? Date else {
      return nil
    }
    guard let senderID = data["senderID"] as? String else {
      return nil
    }
    guard let senderName = data["senderName"] as? String else {
      return nil
    }
    
    id = document.documentID
    self.sentDate = sentDate
    sender = Sender(senderId: senderID, displayName: senderName)
    
    if let content = data["content"] as? String {
      self.content = content
      downloadURL = nil
    } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
      downloadURL = url
      content = ""
    } else {
      return nil
    }
  }
  
}

extension Message: DatabaseRepresentation {
  var representation: [String : Any] {
    var rep: [String : Any] = [
      "created": sentDate,
      "senderID": sender.senderId,
      "senderName": sender.displayName
    ]
    
    if let url = downloadURL {
      rep["url"] = url.absoluteString
    } else {
      rep["content"] = content
    }
    return rep
  }
}

extension Message: Comparable {
  static func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Message, rhs: Message) -> Bool {
    return lhs.sentDate < rhs.sentDate
  }
}
