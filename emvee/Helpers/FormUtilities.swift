//
//  FormUtilities.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import Foundation

class FormUtilities {
 
 static func isPasswordValid(_ password : String) -> Bool {
  
  let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
  return passwordTest.evaluate(with: password)
 }
}
