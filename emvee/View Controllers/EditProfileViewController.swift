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
  
  
  override func viewWillAppear(_ animated: Bool) {
    let userID = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    
    db.collection("users").document(userID!).getDocument { (snapshot, error) in
      if let document = snapshot {
        let bio = document.get("bio")
        self.preferredGenderButton.setTitle("Interested in \(document.get("preferredGender") ?? "finding friends")", for: .normal)
        self.genderButton.setTitle("\(document.get("gender") ?? "")", for: .normal)
        self.hometownButton.setTitle("From \(document.get("hometown") ?? "somewhere on earth")", for: .normal)
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
    
    hometownButton = UIButton()
    hometownButton.translatesAutoresizingMaskIntoConstraints = false
    StyleUtilities.styleBasicInfoButton(hometownButton)
    hometownButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    scrollView.addSubview(hometownButton)
    hometownButton.topAnchor.constraint(equalTo: preferredGenderButton.bottomAnchor, constant: 5).isActive = true
    hometownButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    hometownButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    hometownButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
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
    currentLocationButton.topAnchor.constraint(equalTo: currentLocationButton.bottomAnchor, constant: 5).isActive = true
    genderGreaterThanImage.centerYAnchor.constraint(equalTo: genderButton.centerYAnchor).isActive = true
    genderGreaterThanImage.trailingAnchor.constraint(equalTo: genderButton.trailingAnchor, constant: -genderButton.layer.cornerRadius / 2).isActive = true
    
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
  
  @objc func transitionToEditGender() {
    let vc = EditBasicInfoViewController(title: "Edit Gender", labelText: "I am a...", numOfButtons: 3)
    vc.buttons[0].setTitle("Man", for: .normal)
    vc.buttons[1].setTitle("Woman", for: .normal)
    vc.buttons[2].setTitle("Other", for: .normal)
    show(vc, sender: nil)
  }
  
  @objc func transitionToEditCurrentLocation() {
    let vc = EditBasicInfoViewController(title: "Edit Current Location", labelText: "I am living in...", numOfButtons: 0, textFieldText: currentLocationText)
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
