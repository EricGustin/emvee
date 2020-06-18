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

class ProfileViewController: UIViewController, UITextViewDelegate {
  
  //@IBOutlet weak var bioCharsLeftLabel: UILabel!
  //@IBOutlet weak var aboutMeTextView: UITextView!
  //@IBOutlet weak var profilePicture: UIImageView!
  //@IBOutlet weak var nameAndAgeLabel: UILabel!
  
  @IBOutlet weak var editBioButton: UIButton!
  
  private var settingsButton: UIButton!
  private var homeButton: UIButton!
  private var profilePicture: UIImageView!
  private var nameAndAgeLabel: UILabel!
  private var aboutMeLabel: UILabel!
  private var aboutMeTextView: UITextView!
  private var aboutMeCharsRemainingLabel: UILabel!
  
  
  // MARK: - ACTIONS
  @objc func homeButtonClicked(_ sender: UIButton) {
    transitionToHome()
  }
  
  @objc func settingsButtonClicked(_ sender: UIButton) {
    transitionToSettings()
  }
  
  private func setUpSubViews() {
    
    settingsButton = UIButton()
    settingsButton.translatesAutoresizingMaskIntoConstraints = false
    settingsButton.setBackgroundImage(UIImage(systemName: "gear"), for: .normal)
    settingsButton.tintColor = .systemTeal
    view.addSubview(settingsButton)
    settingsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
    settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    settingsButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
    settingsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    settingsButton.addTarget(self, action: #selector(settingsButtonClicked), for: .touchUpInside)
    
    homeButton = UIButton()
    homeButton.translatesAutoresizingMaskIntoConstraints = false
    homeButton.setBackgroundImage(UIImage(systemName: "house"), for: .normal)
    homeButton.tintColor = .systemTeal
    view.addSubview(homeButton)
    homeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
    homeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    homeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
    homeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    homeButton.addTarget(self, action: #selector(homeButtonClicked), for: .touchUpInside)
    

    profilePicture = UIImageView(image: UIImage(named: "defaultProfileImage@4x"))
    profilePicture.translatesAutoresizingMaskIntoConstraints = false
    profilePicture.isUserInteractionEnabled = true
    view.addSubview(profilePicture)
    profilePicture.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    NSLayoutConstraint(item: profilePicture!, attribute: .centerY, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: 0.5, constant: 0).isActive = true
    profilePicture.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    profilePicture.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
    profilePicture.contentMode = .scaleAspectFill
    profilePicture.layer.cornerRadius = UIScreen.main.bounds.width / 4
    profilePicture.layer.masksToBounds = true
    profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profilePictureTapped)))
    
    nameAndAgeLabel = UILabel()
    nameAndAgeLabel.translatesAutoresizingMaskIntoConstraints = false
    nameAndAgeLabel.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 18), size: 18)
    nameAndAgeLabel.textColor = .black
    nameAndAgeLabel.textAlignment = .center
    nameAndAgeLabel.numberOfLines = 0
    view.addSubview(nameAndAgeLabel)
    nameAndAgeLabel.centerXAnchor.constraint(equalTo: profilePicture.centerXAnchor).isActive = true
    nameAndAgeLabel.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 20).isActive = true
    
    aboutMeLabel = UILabel()
    aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
    aboutMeLabel.text = "About me"
    aboutMeLabel.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Semibold", size: 16), size: 16)
    aboutMeLabel.textColor = .black
    aboutMeLabel.textAlignment = .center
    view.addSubview(aboutMeLabel)
    aboutMeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,  constant: UIScreen.main.bounds.width / 20 + 25).isActive = true  // Logic behind the constant: The aboutMeTextView is centered and has a width of 0.9 * view.width, thus the aboutMeTextView's leading is effectively view.width / 20. In addition, adding 25 in order to match the aboutMeTextView's corner radius which is essential for the desired position.
    aboutMeLabel.topAnchor.constraint(equalTo: nameAndAgeLabel.bottomAnchor, constant: 80).isActive = true
    
    aboutMeTextView = UITextView()
    aboutMeTextView.delegate = self
    aboutMeTextView.translatesAutoresizingMaskIntoConstraints = false
    aboutMeTextView.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter", size: 12), size: 12)
    aboutMeTextView.layer.cornerRadius = 25
    aboutMeTextView.backgroundColor = .white
    view.addSubview(aboutMeTextView)
    aboutMeTextView.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 5).isActive = true
    aboutMeTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    aboutMeTextView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true  // 3:1 AspectRatio
    aboutMeTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
    aboutMeCharsRemainingLabel = UILabel()
    aboutMeCharsRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
    aboutMeCharsRemainingLabel.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter", size: 12), size: 12)
    aboutMeCharsRemainingLabel.textColor = .lightGray
    aboutMeCharsRemainingLabel.textAlignment = .center
    view.addSubview(aboutMeCharsRemainingLabel)
    aboutMeCharsRemainingLabel.bottomAnchor.constraint(equalTo: aboutMeTextView.bottomAnchor, constant: -aboutMeTextView.layer.cornerRadius / 2).isActive = true
    aboutMeCharsRemainingLabel.trailingAnchor.constraint(equalTo: aboutMeTextView.trailingAnchor, constant: -aboutMeTextView.layer.cornerRadius / 2).isActive = true
    
  }
  
  @IBAction func editBioButtonClicked(_ sender: UIButton) {
    if editBioButton.titleLabel?.text == "Edit" {
      aboutMeTextView.isEditable = true
      editBioButton.setTitle("Save", for: .normal)
    } else if editBioButton.titleLabel?.text == "Save" {
      aboutMeTextView.isEditable = false
      editBioButton.setTitle("Edit", for: .normal)
      aboutMetextViewWasSaved(aboutMeTextView)
    }
  }
  
  @objc func profilePictureTapped() {
    presentImagePickerControllerActionSheet()
  }
  
  @objc func swipeDetected(gesture: UISwipeGestureRecognizer) {
    if gesture.direction == .left {
      transitionToHome()
    } else if gesture.direction == .right {
      transitionToSettings()
    }
  }
  
  // MARK: - Navigation
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpSubViews()
    
    
    let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(gesture:)))
    leftSwipeGesture.direction = .left
    view.addGestureRecognizer(leftSwipeGesture)
    let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(gesture:)))
    rightSwipeGesture.direction = .right
    view.addGestureRecognizer(rightSwipeGesture)
    
    view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    
    
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
        self.displayBioCharsLeft()
      }
    }
    textViewDidChange(aboutMeTextView) // initialize a proper size for the textView
    downloadProfilePictureFromFirebase()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  func transitionToSettings() {
    let settingsViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.settingsViewController) as? SettingsViewController
    view.window?.rootViewController = settingsViewController
    view.window?.makeKeyAndVisible()
  }
  
  func transitionToHome() {
    let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
    view.window?.rootViewController = homeViewController
    view.window?.makeKeyAndVisible()
  }
  
  // MARK: - Delegates
  // Adds the new character to the user's bio if it doesn't exceed 255 chars, else no update occurs
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if 255 - aboutMeTextView.text.count == 0 {
      if range.length != 1 {
        // TODO: add an animation of the charsLeft label where it gets slightly bigger and then returns to normal size
        return false
      }
    }
    return true
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
  }
  
  func aboutMetextViewWasSaved(_ textView: UITextView) {
    updateCloudFirestoreField("bio", aboutMeTextView.text ?? 0)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    displayBioCharsLeft()
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
  
  func uploadProfilePictureToFirebase() {
    guard let image = profilePicture.image,
      let nonCompressedData = image.jpegData(compressionQuality: 1.0),
      let data = image.jpegData(compressionQuality: CGFloat((1048576) / nonCompressedData.count)) // 1024*1024 = 1048576 bytes = 1mb
    else {
      print("Couldnt convert image to data")
      return
    }
    
    let userID = Auth.auth().currentUser?.uid
    
    let storage = Storage.storage()
    let storageRef = storage.reference() // a reference is essentially a pointer to a file in the cloud
    let profilePictureRef = storageRef.child("profilePictures").child(userID!)
    
    // upload the picture to Firebase
    profilePictureRef.putData(data, metadata: nil) { (metadata, error) in
      if error != nil {
        print("Error putting profilePictureRef data.")
        return
      }
    }
  }
  
  func downloadProfilePictureFromFirebase() {
    guard let userID = Auth.auth().currentUser?.uid else {
      print("Error generating UserID.")
      return
    }
    let profilePictureRef = Storage.storage().reference().child("profilePictures").child(userID)
    print("Uid: \(userID)")
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
  func getAge(currentDate: String, dateOfBirth: String) -> Int {
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
  
  // The user has a maximum of 255 characters for their bio. This function calculates the number of chars
  // That they can still add to their bio and updates the bioCharsLeftLabel accordingly.
  func displayBioCharsLeft() {
    let currChars = aboutMeTextView.text.count
    
    aboutMeCharsRemainingLabel.text = String(255 - currChars)
    if currChars < 230 {
      aboutMeCharsRemainingLabel.textColor = UIColor.lightGray
    } else {
      aboutMeCharsRemainingLabel.textColor = UIColor.red
    }
  }
}

// MARK: - Extensions
extension String {
  
  var wordList: [String] {
    return components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
  }
  
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  // Presents a UIAlertController that gives the user the option to pick a profile picture from their existing library or from their camera.
  func presentImagePickerControllerActionSheet() {
    // Make actions for the UIAlertController
    let photoLibraryAction = UIAlertAction(title: "Choose from library", style: .default) { (action) in
      self.presentImagePickerController(sourceType: .photoLibrary)
    }
    let cameraAction = UIAlertAction(title: "Choose from camera", style: .default) { (action) in
      self.presentImagePickerController(sourceType: .camera)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    // Create UIAlertController
    let alert = UIAlertController(title: "Choose your image", message: nil, preferredStyle: .actionSheet)
    alert.addAction(photoLibraryAction)
    alert.addAction(cameraAction)
    alert.addAction(cancelAction)
    self.present(alert, animated: true, completion: nil)
    
    
  }
  
  func presentImagePickerController(sourceType: UIImagePickerController.SourceType) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    picker.sourceType = sourceType
    present(picker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    var selectedImage: UIImage?
    if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      selectedImage = editedImage
    } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      selectedImage = originalImage
    }
    
    if let profileImage = selectedImage {
      profilePicture.image = profileImage
    }
    
    dismiss(animated: true, completion: nil) // dismiss the UIImagePickerControllers and go back to profile VC
    
    uploadProfilePictureToFirebase()
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}
