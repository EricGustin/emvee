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

class SettingsViewController: UIViewController {
  
  private var logoutButton: UIButton?
  private var profileButton: UIButton?
  
  
  // MARK: - Navigation
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In settingsViewController")
    view.backgroundColor = .systemGray6
    setUpSubviews()
    setUpNavigationBar()
    
    let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(gesture:)))
    swipeGesture.direction = .left
    view.addGestureRecognizer(swipeGesture)
  }

  


  // MARK: - Transistions
  func transitionToWelcome() {
    let vc = WelcomeViewController()
    navigationController?.pushViewControllerFromBottom(rootVC: vc)
  }
  
  @objc func transitionToProfile() {
    UserDefaults.standard.set(false, forKey: "isProfileLoaded")
    navigationController?.popViewControllerToLeft()
  }
  
  // MARK: - Actions
  @objc func swipeDetected(gesture: UISwipeGestureRecognizer) {
    transitionToProfile()
  }
  
  @objc func logoutButtonClicked() {
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
  
  private func setUpNavigationBar() {
    title = "Settings"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 28), size: 28)]
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton!)
    navigationItem.leftBarButtonItem = UIBarButtonItem()
  }
  
  private func setUpSubviews() {
    
    profileButton = UIButton()
    profileButton?.translatesAutoresizingMaskIntoConstraints = false
    profileButton?.setBackgroundImage(UIImage(systemName: "person.circle"), for: .normal)
    profileButton?.tintColor = .systemTeal
    view.addSubview(profileButton!)
    profileButton?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
    profileButton?.widthAnchor.constraint(equalToConstant: 40).isActive = true
    profileButton?.heightAnchor.constraint(equalToConstant: 40).isActive = true
    profileButton?.addTarget(self, action: #selector(transitionToProfile), for: .touchUpInside)
    
    logoutButton = UIButton()
    logoutButton?.setTitleColor(.white, for: .normal)
    logoutButton?.setTitle("Logout", for: .normal)
    logoutButton?.titleLabel?.font = UIFont(name: "American Typewriter", size: 16)
    logoutButton?.addTarget(self, action: #selector(logoutButtonClicked), for: .touchUpInside)
    StyleUtilities.styleFilledButton(logoutButton!)
    view.addSubview(logoutButton!)
    logoutButton?.translatesAutoresizingMaskIntoConstraints = false
    logoutButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    logoutButton?.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5).isActive = true
    logoutButton?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    logoutButton?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
}
