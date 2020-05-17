//
//  Constants.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import Foundation

struct Constants {
  struct Storyboard {
    static let homeViewController = "homeViewController"
    static let welcomeViewController = "welcomeViewController"
    static let profileViewController = "profileViewController"
    static let settingsViewController = "settingsViewController"
    static let textChatViewController = "textChatViewController"
  }
  
  struct Dates {
    static let months: [String: Int] = [
      "January": 1, "February": 2, "March": 3, "April": 4, "May": 5,
      "June": 6, "July": 7, "August": 8, "September": 9, "October": 10,
      "November": 11, "December": 12
    ]
  }
}
