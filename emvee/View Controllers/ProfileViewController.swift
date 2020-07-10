//
//  ProfileViewController.swift
//  FirebaseAuthentification
//
//  Created by Eric Gustin on 5/8/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController {
  
  private var scrollView: UIScrollView!
  private var settingsButton: UIButton!
  private var homeButton: UIButton!
  private var profilePictureContainer: UIView!
  private var profilePicture: UIImageView!
  private var editProfilePictureButtonContainer: UIView!
  private var editProfilePictureButton: UIButton!
  private var nameAndAgeLabel: UILabel!
  private var aboutMeLabel: UILabel!
  private var aboutMeTextView: UITextView!
  private var myBasicInfoLabel: UILabel!
  private var genderButton: UIButton!
  private var preferredGenderButton: UIButton!
  private var hometownButton: UIButton!
  private var currentLocationButton: UIButton!


  private var savedAboutMeText: String?
  
  // MARK: - ACTIONS
  @objc func homeButtonClicked(_ sender: UIButton) {
    transitionToHome()
  }
  
  @objc func settingsButtonClicked(_ sender: UIButton) {
    transitionToSettings()
  }
    
  @objc func profilePictureTapped() { // change so that it gives a preview of how other people see their profile
    
  }
  
  @objc func swipeDetected(gesture: UISwipeGestureRecognizer) {
    if gesture.direction == .left {
      transitionToHome()
    } else if gesture.direction == .right {
      transitionToSettings()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    // Get user data from Firebase Database
    let userID = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    
    db.collection("users").document(userID!).getDocument { (snapshot, error) in
      if let document = snapshot {
        let firstName = document.get("firstName") ?? ""
        let dateOfBirth = document.get("birthday")
        let bio = document.get("bio")
        // Calculate user's age
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy"
        let currentDate = dateFormatter.string(from: date)
        let age: Int = self.getAge(currentDate: currentDate as String, dateOfBirth: dateOfBirth! as! String)
        
        self.nameAndAgeLabel.text = "\(firstName), \(age)"
        self.aboutMeTextView.text = bio as? String
        self.preferredGenderButton.setTitle("Interested in \(document.get("preferredGender") ?? "finding friends")", for: .normal)
        self.genderButton.setTitle("\(document.get("gender") ?? "")", for: .normal)
        self.hometownButton.setTitle("From \(document.get("hometown") ?? "somewhere on earth")", for: .normal)
        self.currentLocationButton.setTitle("Living in \(document.get("currentLcoation") ?? "a city on earth")", for: .normal)
      }
    }
    downloadProfilePictureFromFirebase()
  }
  
  // MARK: - Navigation
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemGray6
    setUpSubViews()
    setUpNavigationBar()
    
    let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(gesture:)))
    leftSwipeGesture.direction = .left
    view.addGestureRecognizer(leftSwipeGesture)
    let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(gesture:)))
    rightSwipeGesture.direction = .right
    view.addGestureRecognizer(rightSwipeGesture)
  
  }
  
  private func setUpSubViews() {
    
    scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = .clear
    view.addSubview(scrollView)
    scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    settingsButton = UIButton()
    settingsButton.translatesAutoresizingMaskIntoConstraints = false
    settingsButton.setBackgroundImage(UIImage(systemName: "gear"), for: .normal)
    settingsButton.tintColor = .systemTeal
    scrollView.addSubview(settingsButton)
    settingsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
    settingsButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20).isActive = true
    settingsButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
    settingsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    settingsButton.addTarget(self, action: #selector(settingsButtonClicked), for: .touchUpInside)
    
    homeButton = UIButton()
    homeButton.translatesAutoresizingMaskIntoConstraints = false
    homeButton.setBackgroundImage(UIImage(systemName: "house"), for: .normal)
    homeButton.tintColor = .systemTeal
    scrollView.addSubview(homeButton)
    homeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
    homeButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20).isActive = true
    homeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
    homeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    homeButton.addTarget(self, action: #selector(homeButtonClicked), for: .touchUpInside)
    
    profilePictureContainer = UIView()
    profilePictureContainer.translatesAutoresizingMaskIntoConstraints = false
    profilePictureContainer.layer.borderWidth = 0.25
    profilePictureContainer.layer.borderColor = UIColor.lightGray.cgColor
    scrollView.addSubview(profilePictureContainer)
    profilePictureContainer.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    NSLayoutConstraint(item: profilePictureContainer!, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 0.5, constant: 0).isActive = true
    profilePictureContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    profilePictureContainer.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    profilePictureContainer.contentMode = .scaleAspectFill
    profilePictureContainer.layer.cornerRadius = UIScreen.main.bounds.width / 4
    profilePictureContainer.layer.masksToBounds = true
    
    profilePicture = UIImageView(image: UIImage())
    profilePicture.backgroundColor = .white
    profilePicture.translatesAutoresizingMaskIntoConstraints = false
    profilePicture.isUserInteractionEnabled = true
    profilePicture.layer.borderColor = UIColor.white.cgColor
    profilePicture.layer.borderWidth = 4.75
    profilePictureContainer.addSubview(profilePicture)
    profilePicture.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    NSLayoutConstraint(item: profilePicture!, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 0.5, constant: 0).isActive = true
    profilePicture.leadingAnchor.constraint(equalTo: profilePictureContainer.leadingAnchor, constant: profilePictureContainer.layer.borderWidth).isActive = true
    profilePicture.topAnchor.constraint(equalTo: profilePictureContainer.topAnchor, constant: profilePictureContainer.layer.borderWidth).isActive = true
    profilePicture.trailingAnchor.constraint(equalTo: profilePictureContainer.trailingAnchor, constant: -profilePictureContainer.layer.borderWidth).isActive = true
    profilePicture.bottomAnchor.constraint(equalTo: profilePictureContainer.bottomAnchor, constant: -profilePictureContainer.layer.borderWidth).isActive = true
    profilePicture.contentMode = .scaleAspectFill
    profilePicture.layer.cornerRadius = (UIScreen.main.bounds.width - 0.5) / 4 // circle
    profilePicture.layer.masksToBounds = true
    profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped)))
    
    editProfilePictureButtonContainer = UIView()
    editProfilePictureButtonContainer.translatesAutoresizingMaskIntoConstraints = false
    editProfilePictureButtonContainer.backgroundColor = view.backgroundColor
    scrollView.addSubview(editProfilePictureButtonContainer)
    editProfilePictureButtonContainer.widthAnchor.constraint(equalTo: profilePicture.widthAnchor, multiplier: 1/3).isActive = true
    editProfilePictureButtonContainer.heightAnchor.constraint(equalTo: profilePicture.heightAnchor, multiplier: 1/3).isActive = true
    editProfilePictureButtonContainer.bottomAnchor.constraint(equalTo: profilePicture.bottomAnchor).isActive = true
    editProfilePictureButtonContainer.trailingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: editProfilePictureButtonContainer.frame.width/2).isActive = true
    editProfilePictureButtonContainer.layer.cornerRadius = profilePicture.layer.cornerRadius * (1/3)
    editProfilePictureButtonContainer.layer.masksToBounds = true
    
    editProfilePictureButton = UIButton()
    editProfilePictureButton.setBackgroundImage(UIImage(systemName: "pencil.circle"), for: .normal)
    editProfilePictureButton.backgroundColor = view.backgroundColor
    editProfilePictureButton.translatesAutoresizingMaskIntoConstraints = false
    editProfilePictureButton.tintColor = .lightGray
    editProfilePictureButtonContainer.addSubview(editProfilePictureButton)
    editProfilePictureButton.widthAnchor.constraint(equalTo: profilePicture.widthAnchor, multiplier: 1/3).isActive = true
    editProfilePictureButton.heightAnchor.constraint(equalTo: profilePicture.heightAnchor, multiplier: 1/3).isActive = true
    editProfilePictureButton.bottomAnchor.constraint(equalTo: profilePicture.bottomAnchor).isActive = true
    editProfilePictureButton.trailingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: editProfilePictureButton.frame.width/2).isActive = true
    editProfilePictureButton.addTarget(self, action: #selector(transitionToEditProfile), for: .touchUpInside)
  
    nameAndAgeLabel = UILabel()
    nameAndAgeLabel.translatesAutoresizingMaskIntoConstraints = false
    nameAndAgeLabel.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 18), size: 18)
    nameAndAgeLabel.textColor = .black
    nameAndAgeLabel.textAlignment = .center
    nameAndAgeLabel.numberOfLines = 0
    scrollView.addSubview(nameAndAgeLabel)
    nameAndAgeLabel.centerXAnchor.constraint(equalTo: profilePicture.centerXAnchor).isActive = true
    nameAndAgeLabel.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 20).isActive = true
    
    aboutMeLabel = UILabel()
    aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
    aboutMeLabel.text = "About me"
    aboutMeLabel.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Semibold", size: 16), size: 16)
    aboutMeLabel.textColor = .black
    aboutMeLabel.textAlignment = .center
    scrollView.addSubview(aboutMeLabel)
    aboutMeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,  constant: UIScreen.main.bounds.width / 20 + 25).isActive = true  // Logic behind the constant: The aboutMeTextView is centered and has a width of 0.9 * view.width, thus the aboutMeTextView's leading is effectively view.width / 20. In addition, adding 25 in order to match the aboutMeTextView's corner radius which is essential for the desired position.

    aboutMeLabel.topAnchor.constraint(equalTo: nameAndAgeLabel.bottomAnchor, constant: 80).isActive = true
    
    aboutMeTextView = UITextView()
    aboutMeTextView.translatesAutoresizingMaskIntoConstraints = false
    aboutMeTextView.isEditable = false
    aboutMeTextView.isScrollEnabled = true
    aboutMeTextView.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter", size: 12), size: 12)
    aboutMeTextView.layer.cornerRadius = 25
    aboutMeTextView.layer.borderColor = UIColor.lightGray.cgColor
    aboutMeTextView.layer.borderWidth = 0.25
    aboutMeTextView.backgroundColor = .white
    aboutMeTextView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    scrollView.addSubview(aboutMeTextView)
    aboutMeTextView.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 5).isActive = true
    aboutMeTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    aboutMeTextView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true
    aboutMeTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
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
    
    preferredGenderButton = UIButton()
    preferredGenderButton.translatesAutoresizingMaskIntoConstraints = false
    StyleUtilities.styleBasicInfoButton(preferredGenderButton)
    preferredGenderButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    scrollView.addSubview(preferredGenderButton)
    preferredGenderButton.topAnchor.constraint(equalTo: genderButton.bottomAnchor, constant: 5).isActive = true
    preferredGenderButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    preferredGenderButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    preferredGenderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    currentLocationButton = UIButton()
    currentLocationButton.translatesAutoresizingMaskIntoConstraints = false
    StyleUtilities.styleBasicInfoButton(currentLocationButton)
    currentLocationButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    scrollView.addSubview(currentLocationButton)
    currentLocationButton.topAnchor.constraint(equalTo: preferredGenderButton.bottomAnchor, constant: 5).isActive = true
    currentLocationButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    currentLocationButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    currentLocationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    hometownButton = UIButton()
    hometownButton.translatesAutoresizingMaskIntoConstraints = false
    StyleUtilities.styleBasicInfoButton(hometownButton)
    hometownButton.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    scrollView.addSubview(hometownButton)
    hometownButton.topAnchor.constraint(equalTo: currentLocationButton.bottomAnchor, constant: 5).isActive = true
    hometownButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    hometownButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
    hometownButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    // Lastly, calculate the content size of the scrollView
    scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
  }
  
  private func setUpNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingsButton!)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: homeButton!)
    title = "Profile"
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 28), size: 28)]
  }
  
  private func transitionToSettings() {
    let vc = SettingsViewController()
    navigationController?.pushViewControllerFromLeftToRight(rootVC: vc)
  }
  
  private func transitionToHome() {
    navigationController?.popViewControllerToLeft()
  }
  
  @objc private func transitionToEditProfile() {
    let vc = EditProfileViewController()
    navigationController?.pushViewControllerFromBottom(rootVC: vc)
  }
  
  // MARK: - Firebase Stuff
  func updateCloudFirestoreField(_ fieldName: String, _ newValue: Any) {
    guard let userID = Auth.auth().currentUser?.uid else {
      print("Error accessing userID")
      return
    }
    let db = Firestore.firestore() // initialize an instance of Cloud Firestore
    db.collection("users").document(userID).updateData([fieldName: newValue])
  }
  
  func downloadProfilePictureFromFirebase() {
    guard let userID = Auth.auth().currentUser?.uid else {
      print("Error generating UserID.")
      return
    }
    let profilePictureRef = Storage.storage().reference().child("profilePictures/\(userID)/picture0")
    // Download profile picture in memory  with a maximum allowed size of 1MB
    profilePictureRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
      if error != nil {
        print("Error getting profile picture data.")
        return
      } else {
        let profileImage = UIImage(data: data!)
        self.profilePicture.image = profileImage
      }
    }
  }
  
  // MARK: Calculations
  public func getAge(currentDate: String, dateOfBirth: String) -> Int {
    let currentDateArray: [String] = currentDate.wordList
    let dateOfBirthArray: [String] = dateOfBirth.wordList
    var age = Int(currentDateArray[2])! - Int(dateOfBirthArray[2])!
    if (Constants.Dates.months[dateOfBirthArray[0]] ?? 0 > Constants.Dates.months[currentDateArray[0]] ?? 0) {
      age -= 1
    } else if (dateOfBirthArray[0] == currentDateArray[0]) {
      if (dateOfBirthArray[1] > currentDateArray[1]) {
        age -= 1
      }
    }
    return age
  }
}

// MARK: - Extensions
extension String {
  
  var wordList: [String] {
    return components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
  }
  
}

extension ProfileViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    print("resigning keyboard")
    textField.resignFirstResponder()
    return true
  }
}
