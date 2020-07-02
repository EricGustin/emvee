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
  
  // Navigation Bar And Items
  let navBar = UINavigationBar()
  let navItem = UINavigationItem(title: "Settings")
  let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(transitionToProfile))
  private var logoutButton: UIButton?
  
  
  
  // MARK: - Navigation
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In settingsViewController")
    view.backgroundColor = .systemGray6
    setUpNavigationBar()
    setUpSubviews()
    
    let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(gesture:)))
    swipeGesture.direction = .left
    view.addGestureRecognizer(swipeGesture)
  }

  


  // MARK: - Transistions
  func transitionToWelcome() {
    let vc = WelcomeViewController()
    let nc = NavigationController(vc)
    nc.modalPresentationStyle = .fullScreen
    self.present(nc, animated: true, completion: nil)
  }
  
  @objc func transitionToProfile() {
    self.dismiss(animated: true, completion: nil)
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
    
  }
  
  private func setUpSubviews() {
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
