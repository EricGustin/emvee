//
//  SettingsViewController.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/9/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController, UIRadioButtonDelegate {
  // Labels
  let showMeLabel = UILabel()
  let menLabel = UILabel()
  let womenLabel = UILabel()
  let allLabel = UILabel()
  // Radio Buttons
  let maleRadioButton = UIRadioButton()
  let femaleRadioButton = UIRadioButton()
  let allRadioButton = UIRadioButton()
  // Navigation Bar And Items
//  let navBar = UINavigationBar()
//  let navItem = UINavigationItem(title: "Settings")
//  let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(transitionToProfile))
  // Vertical Stacks
  let genderVStack = UIStackView()
  
  
  
  // MARK: - Navigation
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In settingsViewController")
    setViews()
  }

  // MARK: - Transistions
  func transitionToWelcome() {
    let welcomeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController) as? WelcomeViewController
    view.window?.rootViewController = welcomeViewController
    view.window?.makeKeyAndVisible()
    dismiss(animated: false, completion: nil)
    print("Settings vc dismissed")
  }
  
  @objc func transitionToProfile() {
    let profileViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.profileViewController) as? ProfileViewController
    // Make profile ViewController appear fullscrean
    view.window?.rootViewController = profileViewController
    view.window?.makeKeyAndVisible()
  }
  
  // MARK: - IBActions
  @IBAction func doneButtonClicked(_ sender: UIButton) {
    transitionToProfile()
  }
  @IBAction func logoutButtonClicked(_ sender: UIButton) {
    print("Logout button clicked")
    UserDefaults.standard.set(false, forKey: "isUserSignedIn")
    guard let userID = Auth.auth().currentUser?.uid else {
      print("Error accessing userID")
      return
    }
    let db = Firestore.firestore() // initialize an instance of Cloud Firestore
    db.collection("onlineUsers").document(userID).delete() { err in
      if err != nil {
        print("Error removing document")
      } else {
        print("OnlineUser successfully removed!")
      }
    }
    do {
      try Auth.auth().signOut()
    } catch { print("Error logging out") }
    transitionToWelcome()
  }
  
  // MARK: Views
  func setViews() {
    // 1. Navigation Bar Stuff
    let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
    view.addSubview(navBar)
    let navItem = UINavigationItem(title: "SomeTitle")
    let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(transitionToProfile))
    navItem.rightBarButtonItem = doneItem
    navBar.setItems([navItem], animated: false)
    // 1. Set Delegates
    maleRadioButton.delegate = self
    femaleRadioButton.delegate = self
    allRadioButton.delegate = self
    // 2. Set AutoresizingMask
    showMeLabel.translatesAutoresizingMaskIntoConstraints = false
    menLabel.translatesAutoresizingMaskIntoConstraints = false
    womenLabel.translatesAutoresizingMaskIntoConstraints = false
    allLabel.translatesAutoresizingMaskIntoConstraints = false
    // 3. Set Titles/Text
    showMeLabel.text = "Show Me"
    menLabel.text = "Men"
    womenLabel.text = "Women"
    allLabel.text = "All"
    // 4. Set colors
    showMeLabel.textColor = .black
    menLabel.textColor = .black
    womenLabel.textColor = .black
    allLabel.textColor = .black
    // 5. Set font, size, boldness
    showMeLabel.font = UIFont.boldSystemFont(ofSize: showMeLabel.font.pointSize)
    // 6. Add views to the superview
    view.addSubview(showMeLabel)
    view.addSubview(menLabel)
    view.addSubview(womenLabel)
    view.addSubview(allLabel)
    view.addSubview(maleRadioButton)
    view.addSubview(femaleRadioButton)
    view.addSubview(allRadioButton)
    
    // Set Constraints
    NSLayoutConstraint(item: showMeLabel, attribute: .top, relatedBy: .equal, toItem: navBar, attribute: .bottom, multiplier: 1.0, constant: 40).isActive = true
    NSLayoutConstraint(item: showMeLabel, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1.0, constant: 20).isActive = true
//    NSLayoutConstraint(item: showMeLabel, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 20).isActive = true
//    NSLayoutConstraint(item: showMeLabel, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1.0, constant: 20).isActive = true
    //    NSLayoutConstraint.activate([
    //      maleRadioButton.topAnchor.constraint(equalToSystemSpacingBelow: showMeLabel.bottomAnchor, multiplier: 1)
    //      maleRadioButton.
    //    ])
  }
  
  // MARK: - Protocols
  func onClick(_ sender: UIView) {
    guard let currentRadioButton = sender as? UIRadioButton else {
      return
    }
    [maleRadioButton, femaleRadioButton, allRadioButton].forEach { $0.isChecked = false }
    currentRadioButton.isChecked = !maleRadioButton.isChecked
  }
}
