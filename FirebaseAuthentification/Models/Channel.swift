//
//  Channel.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/15/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import FirebaseFirestore

struct Channel {
  
  let id: String?
  let name: String
  
  init(name: String) {
    id = nil
    self.name = name
  }
  
  init?(document: QueryDocumentSnapshot) {
    let data = document.data()
    guard let name = data["name"] as? String else {
      return nil
    }
    
    id = document.documentID
    self.name = name
  }
}

extension Channel: DatabaseRepresentation {
  var representation: [String : Any] {
    var rep = ["name": name]
    
    if let id = id {
      rep["id"] = id
    }
    return rep
  }
  
}

extension Channel: Comparable {
  
    static func == (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.name < rhs.name
  }
}
