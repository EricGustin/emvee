//
//  SetUpProfileViewController.swift
//  emvee
//
//  Created by Eric Gustin on 6/30/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class SetUpProfileViewController: EditableProfileSuperViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpNavigationBar()
  }
  
  private func setUpNavigationBar() {
    title = "Set Up Profile"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "American Typewriter", size: 28)!]
    navigationController?.navigationBar.backgroundColor = .systemGray6
  }
}
