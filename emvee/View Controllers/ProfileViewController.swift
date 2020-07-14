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
  private var profilePicturesContainer: UIView!
  private var profilePicturesScrollView: UIScrollView!
  private var profilePictures = [UIImageView]()
  private var editProfileButton: UIButton!
  private var nameAndAgeLabel: UILabel!
  private var aboutMeLabel: UILabel!
  private var aboutMeTextView: UITextView!
  private var myBasicInfoLabel: UILabel!
  private var genderButton: UIButton!
  private var preferredGenderButton: UIButton!
  private var hometownButton: UIButton!
  private var currentLocationButton: UIButton!
  private var profilePicturesPageControl: UIPageControl!
  
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
    if UserDefaults.standard.bool(forKey: "isProfileLoaded") { // i.e coming from EditProfileVC or SettingsVC
      UserDefaults.standard.set(false, forKey: "isProfileLoaded")
      profilePicturesPageControl.numberOfPages = 0
      profilePicturesScrollView.contentOffset.x = 0
      self.profilePicturesScrollView.contentSize.width = 0
      
      profilePictures.removeAll(keepingCapacity: true)
      for _ in 0..<6 { profilePictures.append(UIImageView()) }
      downloadProfilePicturesFromFirebase()
    }
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
    
    profilePicturesContainer = UIView(frame: CGRect(x: view.safeAreaLayoutGuide.layoutFrame.width/4 - 0.25, y: view.safeAreaLayoutGuide.layoutFrame.height/12 - 0.25, width: UIScreen.main.bounds.width/2 + 0.5, height: UIScreen.main.bounds.width/2 + 0.5))
    profilePicturesContainer.layer.borderColor = UIColor.lightGray.cgColor
    profilePicturesContainer.layer.borderWidth = 0.5
    profilePicturesContainer.layer.cornerRadius = profilePicturesContainer.frame.width/2
    profilePicturesContainer.layer.masksToBounds = true
    scrollView.addSubview(profilePicturesContainer)
    
    // ScrollView that holds profile pictures
    profilePicturesScrollView = UIScrollView()
    profilePicturesScrollView.delegate = self
    profilePicturesScrollView.backgroundColor = .white
    profilePicturesScrollView.isPagingEnabled = true
    profilePicturesScrollView.showsVerticalScrollIndicator = false
    profilePicturesScrollView.showsHorizontalScrollIndicator = false
    profilePicturesScrollView.layer.borderColor = UIColor.white.cgColor
    profilePicturesScrollView.layer.borderWidth = 5
    profilePicturesScrollView.layer.masksToBounds = true
    profilePicturesScrollView.frame = CGRect(x: view.safeAreaLayoutGuide.layoutFrame.width/4, y: view.safeAreaLayoutGuide.layoutFrame.height/12, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
    profilePicturesScrollView.layer.cornerRadius = profilePicturesScrollView.frame.width / 2
    scrollView.addSubview(profilePicturesScrollView)
    
    // Add profile pictures to profilePicturesScrollView
    profilePictures = [UIImageView]()
    for _ in 0..<6 { profilePictures.append(UIImageView()) }
    downloadProfilePicturesFromFirebase()
    
    editProfileButton = UIButton(frame: CGRect(x: 7*view.safeAreaLayoutGuide.layoutFrame.width/12 - 0.25, y: profilePicturesContainer.frame.maxY - UIScreen.main.bounds.width/6 - 0.5, width: UIScreen.main.bounds.width/6 + 0.5, height: UIScreen.main.bounds.width/6 + 0.5))
    editProfileButton.setBackgroundImage(UIImage(systemName: "pencil.circle"), for: .normal)
    editProfileButton.backgroundColor = view.backgroundColor
    editProfileButton.layer.cornerRadius = (UIScreen.main.bounds.width/6 + 0.5)/2
    editProfileButton.tintColor = .lightGray
    scrollView.addSubview(editProfileButton)
    editProfileButton.addTarget(self, action: #selector(transitionToEditProfile), for: .touchUpInside)
    
    profilePicturesPageControl = UIPageControl()
    profilePicturesPageControl.currentPageIndicatorTintColor = .white
    profilePicturesPageControl.pageIndicatorTintColor = .lightGray
    profilePicturesPageControl.numberOfPages = 0 // Adds 1 each time a profile picture is downloaded from Firebase
    profilePicturesPageControl.hidesForSinglePage = true
    profilePicturesPageControl.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(profilePicturesPageControl)
    profilePicturesPageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    profilePicturesPageControl.topAnchor.constraint(equalTo: profilePicturesScrollView.bottomAnchor).isActive = true
    profilePicturesPageControl.heightAnchor.constraint(equalToConstant: 37).isActive = true
    
    nameAndAgeLabel = UILabel()
    nameAndAgeLabel.translatesAutoresizingMaskIntoConstraints = false
    nameAndAgeLabel.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 18), size: 18)
    nameAndAgeLabel.textColor = .black
    nameAndAgeLabel.textAlignment = .center
    nameAndAgeLabel.numberOfLines = 0
    scrollView.addSubview(nameAndAgeLabel)
    nameAndAgeLabel.centerXAnchor.constraint(equalTo: profilePicturesContainer.centerXAnchor).isActive = true
    nameAndAgeLabel.topAnchor.constraint(equalTo: profilePicturesPageControl.bottomAnchor, constant: 0).isActive = true
    nameAndAgeLabel.heightAnchor.constraint(equalToConstant: 23).isActive = true
    
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
    scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: view.frame.width * 0.8 + 490)
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
  
  private func downloadProfilePicturesFromFirebase() {
    
    guard let userID = Auth.auth().currentUser?.uid else {
      print("Error generating UserID.")
      return
    }
    
    var imageIndex = 0
    for i in 0..<6 {
      let aProfilePictureRef = Storage.storage().reference().child("profilePictures/\(userID)/picture\(i)")
      // Download profile picture in memory  with a maximum allowed size of 1MB
      aProfilePictureRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
        if error != nil {
          return
        } else {
          let aProfilePicture = UIImage(data: data!)
          self.profilePictures[i].image = aProfilePicture
          self.profilePictures[imageIndex].frame = CGRect(x: CGFloat(imageIndex) * self.view.safeAreaLayoutGuide.layoutFrame.width/2, y: 0, width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
          self.profilePictures[imageIndex].contentMode = .scaleAspectFill
          self.profilePictures[imageIndex].clipsToBounds = true
          self.profilePicturesScrollView.addSubview(self.profilePictures[imageIndex])
          self.profilePicturesScrollView.contentSize.width += (self.profilePicturesContainer.frame.width - 0.5)
          self.profilePicturesPageControl.numberOfPages += 1
          imageIndex += 1
        }
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
    textField.resignFirstResponder()
    return true
  }
}

extension ProfileViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    profilePicturesPageControl.currentPage = Int((scrollView.contentOffset.x + 0.5*scrollView.frame.size.width) / scrollView.frame.size.width)
    if scrollView.contentOffset.x < 0 {
      scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    } else if scrollView.contentOffset.x > (scrollView.contentSize.width - profilePicturesContainer.frame.width) {
      scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width - profilePicturesContainer.frame.width, y: 0), animated: false)
    }
  }
}
