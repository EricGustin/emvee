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
  // Labels
//  let showMeLabel = UILabel()
//  let menLabel = UILabel()
//  let womenLabel = UILabel()
//  let allLabel = UILabel()
//   Radio Buttons
//  var genderRadioButtons = [UIRadioButton(), UIRadioButton(), UIRadioButton()]
//   Vertical Stacks
//  let radioButtonVStack = UIStackView()
//  let genderVStack = UIStackView()
//  let radioGenderHStack = UIStackView()
//  let genderPreferenceOuterVStack = UIStackView()
  // Navigation Bar And Items
  let navBar = UINavigationBar()
  let navItem = UINavigationItem(title: "Settings")
  let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(transitionToProfile))
  @IBOutlet weak var radioButton1: UIButton!
  @IBOutlet weak var radioButton2: UIButton!
  @IBOutlet weak var radioButton3: UIButton!
  @IBOutlet weak var saveSettingsButton: UIButton!
  @IBOutlet weak var logoutButton: UIButton!
  
  
  
  // MARK: - Navigation
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In settingsViewController")
    setViews()
    setUpElements()
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
  @IBAction func radioButton1Clicked(_ sender: UIButton) { onClick(sender) }
  @IBAction func radioButton2Clicked(_ sender: UIButton) { onClick(sender) }
  @IBAction func radioButton3Clicked(_ sender: UIButton) { onClick(sender) }
  @IBAction func doneButtonClicked(_ sender: UIButton) {
    transitionToProfile()
  }
  
  @IBAction func saveSettingsButtonClicked(_ sender: UIButton) {
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
  
  func setUpElements() {
    StyleUtilities.styleFilledButton(saveSettingsButton)
    StyleUtilities.styleHollowButton(logoutButton)
  }
  
  func setViews() {
    // 1. Navigation Bar Stuff
    let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
    view.addSubview(navBar)
    let navItem = UINavigationItem(title: "Settings")
    let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(transitionToProfile))
    navItem.rightBarButtonItem = doneItem
    navBar.setItems([navItem], animated: false)
    
    // 1. Set Delegates and add to view
//    for radioButton in genderRadioButtons {
//      radioButton.delegate = self
//      radioButton.translatesAutoresizingMaskIntoConstraints = false
//      view.addSubview(radioButton)
//    }
    // 2. Set AutoresizingMask
//    showMeLabel.translatesAutoresizingMaskIntoConstraints = false
//    menLabel.translatesAutoresizingMaskIntoConstraints = false
//    womenLabel.translatesAutoresizingMaskIntoConstraints = false
//    allLabel.translatesAutoresizingMaskIntoConstraints = false
//    radioButtonVStack.translatesAutoresizingMaskIntoConstraints = false
//    genderVStack.translatesAutoresizingMaskIntoConstraints = false
//    radioGenderHStack.translatesAutoresizingMaskIntoConstraints = false
//    genderPreferenceOuterVStack.translatesAutoresizingMaskIntoConstraints = false
    // 3. Set Titles/Text
//    showMeLabel.text = "Show Me"
//    menLabel.text = "Men"
//    womenLabel.text = "Women"
//    allLabel.text = "All"
    // 4. Set colors
//    showMeLabel.textColor = .black
//    menLabel.textColor = .black
//    womenLabel.textColor = .black
//    allLabel.textColor = .black
    // 5. Set font, size, boldness
//    showMeLabel.font = UIFont.boldSystemFont(ofSize: showMeLabel.font.pointSize)
    // Set Stack Axis
//    radioButtonVStack.axis = .vertical
//    genderVStack.axis = .vertical
//    genderVStack.backgroundColor = .darkGray
//    radioGenderHStack.axis = .horizontal
//    genderPreferenceOuterVStack.axis = .vertical
    // Set stack spacing
//    radioButtonVStack.spacing = 3 // note: genderVStack will have centerY to radioButtonVStack
//    radioGenderHStack.spacing = 10
//    genderPreferenceOuterVStack.spacing = 5
    // Add items into stacks
//    for radioButton in genderRadioButtons {
//      radioButtonVStack.addArrangedSubview(radioButton)
//    }
//    genderVStack.addArrangedSubview(menLabel)
//    genderVStack.addArrangedSubview(womenLabel)
//    genderVStack.addArrangedSubview(allLabel)
//    genderVStack.distribution = .fill
//    radioGenderHStack.addArrangedSubview(radioButtonVStack)
//    radioGenderHStack.addArrangedSubview(genderVStack)
//    genderPreferenceOuterVStack.addArrangedSubview(showMeLabel)
//    genderPreferenceOuterVStack.addArrangedSubview(radioGenderHStack)
// 6. Add views to the superview. Note: UIRadioButtons added to view above
//    view.addSubview(radioButtonVStack)
//    view.addSubview(genderVStack)
//    view.addSubview(radioGenderHStack)
//    view.addSubview(genderPreferenceOuterVStack)
//    view.addSubview(showMeLabel)
//    view.addSubview(menLabel)
//    view.addSubview(womenLabel)
//    view.addSubview(allLabel)
    
    // Set Constraints
//    genderVStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
//    genderVStack.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 40).isActive = true
//    let constraint = NSLayoutConstraint(item: genderRadioButtons[0], attribute: .top, relatedBy: .equal, toItem: navBar, attribute: .bottom, multiplier: 1, constant: 40)
//    NSLayoutConstraint(item: genderRadioButtons[0], attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 20).isActive = true
//    print(genderRadioButtons[0].superview?.convert(genderRadioButtons[0].frame, to: nil))
//    print(showMeLabel.superview?.convert(showMeLabel.frame, to: nil))
//    NSLayoutConstraint(item: showMeLabel, attribute: .top, relatedBy: .equal, toItem: navBar, attribute: .bottom, multiplier: 1.0, constant: 40).isActive = true
//    NSLayoutConstraint(item: showMeLabel, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1.0, constant: 20).isActive = true
    
//    NSLayoutConstraint(item: showMeLabel, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 20).isActive = true
//    NSLayoutConstraint(item: showMeLabel, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1.0, constant: 20).isActive = true
    //    NSLayoutConstraint.activate([
    //      maleRadioButton.topAnchor.constraint(equalToSystemSpacingBelow: showMeLabel.bottomAnchor, multiplier: 1)
    //      maleRadioButton.
    //    ])
  }
  
  // MARK: - Protocols
  func onClick(_ sender: UIButton) {
    let genderRadioButtons: [UIButton] = [radioButton1, radioButton2, radioButton3]
    for button in genderRadioButtons {
      if sender == button {
        print(button.state)
        button.isSelected = true
      } else {
        button.isSelected = false
      }
    }
  }
}
