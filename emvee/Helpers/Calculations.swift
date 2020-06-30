//
//  Calculations.swift
//  emvee
//
//  Created by Eric Gustin on 6/30/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import Foundation

class Calculations {
  
  //  Dates must be in for format of MMMM dd yyyy
  static public func getAge(currentDate: String, dateOfBirth: String) -> Int {
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
}
