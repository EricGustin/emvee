//
//  EditProfileViewController.swift
//  emvee
//
//  Created by Eric Gustin on 6/23/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: EditableProfileSuperViewController {
  
  private var myBasicInfoLabel: UILabel!
  private var genderButton: UIButton!
  private var genderGreaterThanImage: UIImageView!
  private var locationButton: UIButton!
  private var locationGreaterThanImage: UIImageView!
  private var hometownButton: UIButton!
  private var hometownGreaterThanImage: UIImageView!
  
  
  override func viewWillAppear(_ animated: Bool) {
    let userID = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    
    db.collection("users").document(userID!).getDocument { (snapshot, error) in
      if let document = snapshot {
        let bio = document.get("bio")
        
        self.aboutMeTextView.text = bio as? String
        self.savedAboutMeText = bio as? String
        self.displayBioCharsLeft()
      }
    }
    textViewDidChange(aboutMeTextView) // initialize a proper size for the textView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpNavigationBar()
    setUpSubviews()
  }
  
  private func setUpNavigationBar() {
    title = "Edit Profile"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(transitionToProfile))
  }
  
  private func setUpSubviews() {
    myBasicInfoLabel = UILabel()
    myBasicInfoLabel.translatesAutoresizingMaskIntoConstraints = false
    myBasicInfoLabel.text = "My basic info"
    myBasicInfoLabel.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Semibold", size: 16), size: 16)
    myBasicInfoLabel.textColor = .black
    myBasicInfoLabel.textAlignment = .center
    scrollView.addSubview(myBasicInfoLabel)
    myBasicInfoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,  constant: UIScreen.main.bounds.width / 20 + 25).isActive = true  // Logic behind the constant: The aboutMeTextView is centered and has a width of 0.9 * view.width, thus the aboutMeTextView's leading is effectively view.width / 20. In addition, adding 25 in order to match the aboutMeTextView's corner radius which is essential for the desired position.
    myBasicInfoLabel.topAnchor.constraint(equalTo: aboutMeTextView.bottomAnchor, constant: 30).isActive = true
    
    genderButton = UIButton()
    genderButton.translatesAutoresizingMaskIntoConstraints = false
    genderButton.setTitle("Man", for: .normal)
    StyleUtilities.styleBasicInfoButton(genderButton)
    genderButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    scrollView.addSubview(genderButton)
    genderButton.topAnchor.constraint(equalTo: myBasicInfoLabel.bottomAnchor, constant: 5).isActive = true
    genderButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    genderButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    genderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    genderButton.addTarget(self, action: #selector(transitionToEditGender), for: .touchUpInside)
    
    locationButton = UIButton()
    locationButton.translatesAutoresizingMaskIntoConstraints = false
    locationButton.setTitle("Lives in Spokane, WA", for: .normal)
    StyleUtilities.styleBasicInfoButton(locationButton)
    locationButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    scrollView.addSubview(locationButton)
    locationButton.topAnchor.constraint(equalTo: genderButton.bottomAnchor, constant: 5).isActive = true
    locationButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    locationButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    locationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    locationButton.addTarget(self, action: #selector(transitionToEditCurrentLocation), for: .touchUpInside)
    
    genderGreaterThanImage = UIImageView(image: UIImage(systemName: "greaterthan"))
    genderGreaterThanImage.translatesAutoresizingMaskIntoConstraints = false
    genderGreaterThanImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.8)
    genderGreaterThanImage.tintColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
    genderGreaterThanImage.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
    genderButton.addSubview(genderGreaterThanImage)
    genderGreaterThanImage.centerYAnchor.constraint(equalTo: genderButton.centerYAnchor).isActive = true
    genderGreaterThanImage.trailingAnchor.constraint(equalTo: genderButton.trailingAnchor, constant: -genderButton.layer.cornerRadius / 2).isActive = true
    
    locationGreaterThanImage = UIImageView(image: UIImage(systemName: "greaterthan"))
    locationGreaterThanImage.translatesAutoresizingMaskIntoConstraints = false
    locationGreaterThanImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.8)
    locationGreaterThanImage.tintColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
    locationGreaterThanImage.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
    locationButton.addSubview(locationGreaterThanImage)
    locationGreaterThanImage.centerYAnchor.constraint(equalTo: locationButton.centerYAnchor).isActive = true
    locationGreaterThanImage.trailingAnchor.constraint(equalTo: locationButton.trailingAnchor, constant: -locationButton.layer.cornerRadius / 2).isActive = true
    
    hometownButton = UIButton()
    hometownButton.translatesAutoresizingMaskIntoConstraints = false
    hometownButton.setTitle("From Stayton, OR", for: .normal)
    StyleUtilities.styleBasicInfoButton(hometownButton)
    hometownButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    scrollView.addSubview(hometownButton)
    hometownButton.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: 5).isActive = true
    hometownButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    hometownButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    hometownButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    hometownButton.addTarget(self, action: #selector(transitionToEditHometownLocation), for: .touchUpInside)
    
    hometownGreaterThanImage = UIImageView(image: UIImage(systemName: "greaterthan"))
    hometownGreaterThanImage.translatesAutoresizingMaskIntoConstraints = false
    hometownGreaterThanImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.8)
    hometownGreaterThanImage.tintColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
    hometownGreaterThanImage.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
    hometownButton.addSubview(hometownGreaterThanImage)
    hometownGreaterThanImage.centerYAnchor.constraint(equalTo: hometownButton.centerYAnchor).isActive = true
    hometownGreaterThanImage.trailingAnchor.constraint(equalTo: hometownButton.trailingAnchor, constant: -hometownButton.layer.cornerRadius / 2).isActive = true
  }
  
  @objc func transitionToEditGender() {
    let vc = EditGenderViewController()
    show(vc, sender: nil)
  }
  
  @objc func transitionToEditCurrentLocation() {
    let vc = EditCurrentLocationViewController()
    show(vc, sender: nil)
  }
  
  @objc func transitionToEditHometownLocation() {
    let vc = EditHometownLocationViewController()
    show(vc, sender: nil)
  }
  
  @objc private func transitionToProfile() {
    self.dismiss(animated: true, completion: nil)
  }
  
}
