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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate & UITextViewDelegate {
  
  @IBOutlet weak var bioCharsLeftLabel: UILabel!
  @IBOutlet weak var aboutMeTextView: UITextView!
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var nameAndAgeLabel: UILabel!
  @IBOutlet weak var currentLocationLabel: UILabel!
  @IBOutlet weak var editBioButton: UIButton!
  
  // MARK: - ACTIONS
  @IBAction func homeButtonClicked(_ sender: UIButton) {
    transitionToHome()
  }
  
  @IBAction func settingsButtonClicked(_ sender: UIButton) {
    transitionToSettings()
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
  
  @objc func editProfilePicture() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    present(picker, animated: true, completion: nil)
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
    
    profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editProfilePicture)))
    profilePicture.isUserInteractionEnabled = true
    
    aboutMeTextView.delegate = self
    
    
    let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(gesture:)))
    leftSwipeGesture.direction = .left
    view.addGestureRecognizer(leftSwipeGesture)
    let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDetected(gesture:)))
    rightSwipeGesture.direction = .right
    view.addGestureRecognizer(rightSwipeGesture)
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
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
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
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    var selectedImage: UIImage?
    if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
      selectedImage = editedImage
    } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
      selectedImage = originalImage
    }
    
    if let profileImage = selectedImage {
      profilePicture.image = profileImage
    }
    
    dismiss(animated: true, completion: nil) // dismiss the UIImagePickerControllers and go back to profile VC
    
    uploadProfilePictureToFirebase()
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
        print(error)
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
    
    bioCharsLeftLabel.text = String(255 - currChars)
    if currChars < 230 {
      bioCharsLeftLabel.textColor = UIColor.lightGray
    } else {
      bioCharsLeftLabel.textColor = UIColor.red
    }
  }
}

// MARK: - Extensions
extension String {
  var wordList: [String] {
    return components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
  }
}
