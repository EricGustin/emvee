//
//  NavigationController.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/16/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
  
  init(_ rootVC: UIViewController) {
    super.init(nibName: nil, bundle: nil)
    pushViewController(rootVC, animated: false)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationBar.backgroundColor = .white
    navigationBar.tintColor = .black

  }
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle ?? .default
  }
  
}
