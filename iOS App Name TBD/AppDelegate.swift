//
//  AppDelegate.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  // let userDefault = UserDefaults.standard
  // let launchedBefore = UserDefaults.standard.bool(forKey: "isUserSignedIn")
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    FirebaseApp.configure()
    return true
  }

}

