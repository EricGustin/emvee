//
//  ViewController.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class WelcomeViewController: UIViewController {
  
  private var background: UIImageView?
  private var logo: UIImageView?
  private var signUpButton: UIButton?
  private var loginButton: UIButton?
  private var verticalStack: UIStackView?

  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpSubviews()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    print("User is signed in?: \(UserDefaults.standard.bool(forKey: "isUserSignedIn"))")
    if Auth.auth().currentUser?.uid == nil { // check if as user is signed in
      UserDefaults.standard.set(false, forKey: "isUserSignedIn")
    }
    if UserDefaults.standard.bool(forKey: "isUserSignedIn") {
      guard let userID = Auth.auth().currentUser?.uid else {
        print("Error accessing userID")
        return
      }
      let db = Firestore.firestore() // initialize an instance of Cloud Firestore
      // Add the user to the onlineUsers document
      db.collection("onlineUsers").document(userID).setData(["userID": userID])
      transitionToHome()
    }
  }
  
  func transitionToHome() {
    let vc = HomeViewController()
    let nc = NavigationController(vc)
    nc.modalPresentationStyle = .fullScreen
    self.present(nc, animated: true, completion: nil)
  }
  
  func setUpSubviews() {
    
    background = UIImageView(image: UIImage(named: "background@4x"))
    background?.translatesAutoresizingMaskIntoConstraints = false
    background?.contentMode = .scaleAspectFill
    view.addSubview(background!)
    background?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    background?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    background?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    background?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
    logo = UIImageView(image: UIImage(named: "emveeLogoLightNoBackground@4x"))
    logo?.translatesAutoresizingMaskIntoConstraints = false
    logo?.contentMode = .scaleAspectFit
    view.addSubview(logo!)
    logo?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    NSLayoutConstraint(item: logo!, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.2, constant: 0).isActive = true
    logo?.widthAnchor.constraint(equalTo: background!.widthAnchor, multiplier: 2/3).isActive = true
    logo?.heightAnchor.constraint(equalTo: logo!.widthAnchor, multiplier: 8/15).isActive = true
    
    signUpButton = UIButton()
    signUpButton?.setTitle("Sign Up With Email", for: .normal)
    signUpButton?.titleLabel?.font = UIFont(name: "American Typewriter", size: 16)
    signUpButton?.setTitleColor(.white, for: .normal)
    StyleUtilities.styleFilledButton(signUpButton!)
    signUpButton?.translatesAutoresizingMaskIntoConstraints = false
    signUpButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    signUpButton?.addTarget(self, action: #selector(transitionToSignUp), for: .touchUpInside)
    
    loginButton = UIButton()
    loginButton?.setTitle("Login With Email", for: .normal)
    loginButton?.titleLabel?.font = UIFont(name: "American Typewriter", size: 16)
    loginButton?.setTitleColor(.black, for: .normal)
    StyleUtilities.styleHollowButton(loginButton!)
    loginButton?.translatesAutoresizingMaskIntoConstraints = false
    loginButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
    loginButton?.addTarget(self, action: #selector(transitionToLogin), for: .touchUpInside)
    
    verticalStack = UIStackView()
    verticalStack?.axis = .vertical
    verticalStack?.translatesAutoresizingMaskIntoConstraints = false
    verticalStack?.spacing = 20
    verticalStack?.addArrangedSubview(signUpButton!)
    verticalStack?.addArrangedSubview(loginButton!)
    view.addSubview(verticalStack!)
    verticalStack?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    verticalStack?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40).isActive = true
    verticalStack?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
  }
  
  @objc private func transitionToSignUp() {
    let vc = SignUpViewController()
    let nc = NavigationController(vc)
    nc.modalPresentationStyle = .fullScreen
    self.present(nc, animated: true, completion: nil)
  }
  
  @objc private func transitionToLogin() {
    let vc = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginViewController) as? LoginViewController
    view.window?.rootViewController = vc
    view.window?.makeKeyAndVisible()
  }
  
}

