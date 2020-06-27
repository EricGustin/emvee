//
//  Popup.swift
//  emvee
//
//  Created by Eric Gustin on 6/27/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

protocol Popup {
  func setUpSubviews()
  func animateIn()
  func setUpGestures()
  func animateOut()
}
