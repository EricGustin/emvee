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
  private var preferredGenderButton: UIButton!
  private var preferredGenderGreaterThanImage: UIImageView!
  private var currentLocationButton: UIButton!
  private var currentLocationGreaterThanImage: UIImageView!
  private var hometownButton: UIButton!
  private var hometownGreaterThanImage: UIImageView!
  private var currentLocationText: String!
  private var hometownText: String!
  private var preferredGenderText: String!
  private var genderText: String!
  
  
  override func viewWillAppear(_ animated: Bool) {
    let userID = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    
    db.collection("users").document(userID!).getDocument { (snapshot, error) in
      if let document = snapshot {
        let bio = document.get("bio")
        self.preferredGenderText = "\(document.get("preferredGender") ?? "finding friends")"
        self.preferredGenderButton.setTitle("Interested in \(self.preferredGenderText ?? "finding friends")", for: .normal)
        self.genderText = "\(document.get("gender") ?? "")"
        self.genderButton.setTitle("\(self.genderText ?? "")", for: .normal)
        self.hometownText = "\(document.get("hometown") ?? "somewhere on earth")"
        self.hometownButton.setTitle("From \(self.hometownText ?? "somewhere on earth")", for: .normal)
        self.currentLocationText = "\(document.get("currentLcoation") ?? "a city on earth")"
        self.currentLocationButton.setTitle("Living in \(self.currentLocationText ?? "a city on earth")", for: .normal)
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
    StyleUtilities.styleBasicInfoButton(genderButton)
    genderButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    scrollView.addSubview(genderButton)
    genderButton.topAnchor.constraint(equalTo: myBasicInfoLabel.bottomAnchor, constant: 5).isActive = true
    genderButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    genderButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    genderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    genderButton.addTarget(self, action: #selector(transitionToEditGender), for: .touchUpInside)
    
    preferredGenderButton = UIButton()
    preferredGenderButton.translatesAutoresizingMaskIntoConstraints = false
    StyleUtilities.styleBasicInfoButton(preferredGenderButton)
    preferredGenderButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    scrollView.addSubview(preferredGenderButton)
    preferredGenderButton.topAnchor.constraint(equalTo: genderButton.bottomAnchor, constant: 5).isActive = true
    preferredGenderButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    preferredGenderButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    preferredGenderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    preferredGenderButton.addTarget(self, action: #selector(transitionToEditPreferredGender), for: .touchUpInside)
    
    hometownButton = UIButton()
    hometownButton.translatesAutoresizingMaskIntoConstraints = false
    StyleUtilities.styleBasicInfoButton(hometownButton)
    hometownButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    scrollView.addSubview(hometownButton)
    hometownButton.topAnchor.constraint(equalTo: preferredGenderButton.bottomAnchor, constant: 5).isActive = true
    hometownButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    hometownButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    hometownButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    hometownButton.addTarget(self, action: #selector(transitionToEditHometownLocation), for: .touchUpInside)
    
    currentLocationButton = UIButton()
    currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
    StyleUtilities.styleBasicInfoButton(currentLocationButton)
    currentLocationButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    scrollView.addSubview(currentLocationButton)
    currentLocationButton.topAnchor.constraint(equalTo: hometownButton.bottomAnchor, constant: 5).isActive = true
    currentLocationButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    currentLocationButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    currentLocationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    currentLocationButton.addTarget(self, action: #selector(transitionToEditCurrentLocation), for: .touchUpInside)
    
    genderGreaterThanImage = UIImageView(image: UIImage(systemName: "greaterthan"))
    genderGreaterThanImage.translatesAutoresizingMaskIntoConstraints = false
    genderGreaterThanImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.8)
    genderGreaterThanImage.tintColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
    genderGreaterThanImage.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
    genderButton.addSubview(genderGreaterThanImage)
    genderGreaterThanImage.centerYAnchor.constraint(equalTo: genderButton.centerYAnchor).isActive = true
    genderGreaterThanImage.trailingAnchor.constraint(equalTo: genderButton.trailingAnchor, constant: -genderButton.layer.cornerRadius / 2).isActive = true
    
    preferredGenderGreaterThanImage = UIImageView(image: UIImage(systemName: "greaterthan"))
    preferredGenderGreaterThanImage.translatesAutoresizingMaskIntoConstraints = false
    preferredGenderGreaterThanImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.8)
    preferredGenderGreaterThanImage.tintColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
    preferredGenderGreaterThanImage.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
    preferredGenderButton.addSubview(preferredGenderGreaterThanImage)
    preferredGenderGreaterThanImage.centerYAnchor.constraint(equalTo: preferredGenderButton.centerYAnchor).isActive = true
    preferredGenderGreaterThanImage.trailingAnchor.constraint(equalTo: preferredGenderButton.trailingAnchor, constant: -preferredGenderButton.layer.cornerRadius / 2).isActive = true
    
    currentLocationGreaterThanImage = UIImageView(image: UIImage(systemName: "greaterthan"))
    currentLocationGreaterThanImage.translatesAutoresizingMaskIntoConstraints = false
    currentLocationGreaterThanImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.8)
    currentLocationGreaterThanImage.tintColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
    currentLocationGreaterThanImage.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
    currentLocationButton.addSubview(currentLocationGreaterThanImage)
    currentLocationGreaterThanImage.centerYAnchor.constraint(equalTo: currentLocationButton.centerYAnchor).isActive = true
    currentLocationGreaterThanImage.trailingAnchor.constraint(equalTo: currentLocationButton.trailingAnchor, constant: -currentLocationButton.layer.cornerRadius / 2).isActive = true
    
    hometownGreaterThanImage = UIImageView(image: UIImage(systemName: "greaterthan"))
    hometownGreaterThanImage.translatesAutoresizingMaskIntoConstraints = false
    hometownGreaterThanImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.8)
    hometownGreaterThanImage.tintColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
    hometownGreaterThanImage.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .heavy)
    hometownButton.addSubview(hometownGreaterThanImage)
    hometownGreaterThanImage.centerYAnchor.constraint(equalTo: hometownButton.centerYAnchor).isActive = true
    hometownGreaterThanImage.trailingAnchor.constraint(equalTo: hometownButton.trailingAnchor, constant: -hometownButton.layer.cornerRadius / 2).isActive = true
  }
  
  private func getButtonTag(text: String) -> Int? {
    switch text {
      case "Male": return 0
      case "Men": return 0
      case "Female": return 1
      case "Women": return 1
      case "Other": return 2
      case "All": return 2
      default: return nil
    }
  }
  
  @objc private func transitionToEditGender() {
    let vc = EditBasicInfoViewController(title: "Edit Gender", labelText: "I am a...", numOfButtons: 3, buttonTag: getButtonTag(text: genderText))
    vc.buttons[0].setTitle("Male", for: .normal)
    vc.buttons[1].setTitle("Female", for: .normal)
    vc.buttons[2].setTitle("Other", for: .normal)
    show(vc, sender: nil)
  }
  
  @objc private func transitionToEditPreferredGender() {
    let vc = EditBasicInfoViewController(title: "Edit Preferred Gender(s)", labelText: "I'm interested in...", numOfButtons: 3, buttonTag: getButtonTag(text: preferredGenderText))
    vc.buttons[0].setTitle("Men", for: .normal)
    vc.buttons[1].setTitle("Women", for: .normal)
    vc.buttons[2].setTitle("All", for: .normal)
    show(vc, sender: nil)
  }
  
  @objc private func transitionToEditCurrentLocation() {
    let vc = EditBasicInfoViewController(title: "Edit Current Location", labelText: "I am living in...", numOfButtons: 0, textFieldText: currentLocationText)
    show(vc, sender: nil)
  }
  
  @objc private func transitionToEditHometownLocation() {
    let vc = EditBasicInfoViewController(title: "Edit Hometown", labelText: "I am from...", numOfButtons: 0, textFieldText: hometownText)
    show(vc, sender: nil)
  }
  
  @objc private func transitionToProfile() {
    self.dismiss(animated: true, completion: nil)
  }
  
}
