//
//  DatabaseRepresentation.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/15/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import Foundation

protocol DatabaseRepresentation {
  var representation: [String: Any] { get }
}
