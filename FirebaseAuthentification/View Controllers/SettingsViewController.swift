//
//  SettingsViewController.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/9/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  @IBAction func doneButtonClicked(_ sender: UIButton) {
    transitionToProfile()
  }
  @IBAction func logoutButtonClicked(_ sender: UIButton) {
    UserDefaults.standard.set(false, forKey: "isUserSignedIn")
    transitionToWelcome()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In settingsViewController")
    
    // Do any additional setup after loading the view.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  func transitionToWelcome() {
    let welcomeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController) as? WelcomeViewController
    view.window?.rootViewController = welcomeViewController
    view.window?.makeKeyAndVisible()
  }
  
  func transitionToProfile() {
    let profileViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.profileViewController) as? ProfileViewController
    // Make profile ViewController appear fullscrean
    view.window?.rootViewController = profileViewController
    view.window?.makeKeyAndVisible()
  }
}
