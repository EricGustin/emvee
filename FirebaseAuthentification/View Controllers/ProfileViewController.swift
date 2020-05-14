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
  
  
  @IBOutlet weak var aboutMeTextView: UITextView!
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var nameAndAgeLabel: UILabel!
  @IBOutlet weak var currentLocationLabel: UILabel!
  @IBAction func homeButtonClicked(_ sender: UIButton) {
    transitionToHome()
  }
  @IBAction func settingsButtonClicked(_ sender: UIButton) {
    transitionToSettings()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("In profileViewController")
    profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editProfilePicture)))
    profilePicture.isUserInteractionEnabled = true
    
    aboutMeTextView.delegate = self
    
    //  self.interactionController = LeftEdgeInteractionController(viewController: self)
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    updateCloudFirestoreField("bio", aboutMeTextView.text ?? 0)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    if 3*textView.frame.size.height <= textView.frame.size.width {
      textView.translatesAutoresizingMaskIntoConstraints = true
      textView.frame.size.height = textView.contentSize.height
    } else {
      textView.isScrollEnabled = false
    }
  }
  
  func updateCloudFirestoreField(_ fieldName: String, _ newValue: Any) {
    guard let userID = Auth.auth().currentUser?.uid else {
      print("Error accessing userID")
      return
    }
    let db = Firestore.firestore() // initialize an instance of Cloud Firestore
    db.collection("users").document(userID).updateData([fieldName: newValue])
  }
  
  @objc func editProfilePicture() {
    let picker = UIImagePickerController()
    
    picker.delegate = self
    picker.allowsEditing = true
    present(picker, animated: true, completion: nil)
    
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    var selectedImage: UIImage?
    
    if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
      print(editedImage)
      selectedImage = editedImage
    } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
      print(originalImage)
      selectedImage = originalImage
    }
    
    if let profileImage = selectedImage {
      profilePicture.image = profileImage
    }
    
    dismiss(animated: true, completion: nil) // dismiss the UIImagePickerControllers and go back to profile VC
    
    uploadProfilePictureToFirebase()
  }
  
  func uploadProfilePictureToFirebase() {
    
    guard let image = profilePicture.image, let data = image.jpegData(compressionQuality: 1.0) else {
      print("Couldnt convert image to data")
      return
    }
    
    //let imageName = UUID().uuidString // this would be the alternate path instead of using UserID
    
    let userID = Auth.auth().currentUser?.uid
    
    let storage = Storage.storage()
    let storageRef = storage.reference() // a reference is essentially a pointer to a file in the cloud
    let profilePictureRef = storageRef.child("profilePictures").child(userID!)
    
    // upload the picture to Firebase
    profilePictureRef.putData(data, metadata: nil) { (metadata, error) in
      if error != nil {
        print("Error putting data.")
        return
      }
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    print("picker canceled")
    dismiss(animated: true, completion: nil)
  }
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  override func viewWillAppear(_ animated: Bool) {
    // Get user data from Firebase Database
    let userID = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    db.collection("users").document(userID!).getDocument { (snapshot, error) in
      if let document = snapshot {
        let firstName = document.get("firstName") ?? ""
        let dateOfBirth = document.get("birthday")
        let bio = document.get("bio")
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy"
        let currentDate = dateFormatter.string(from: date)
        
        let age: Int = self.getAge(currentDate: currentDate as String, dateOfBirth: dateOfBirth! as! String)
        
        self.nameAndAgeLabel.text = "\(firstName), \(age)"
        self.aboutMeTextView.text = bio as? String
      }
    }
    textViewDidChange(aboutMeTextView) // initialize a proper size for the textView
    downloadProfilePictureFromFirebase()
  }
  
  func downloadProfilePictureFromFirebase() {
    guard let userID = Auth.auth().currentUser?.uid else {
      print("Error generating UserID.")
      return
    }
    let profilePictureRef = Storage.storage().reference().child("profilePictures").child(userID)
//    profilePictureRef.downloadURL { (url, error) in
//      if error != nil {
//        print("Error when downloading profile picture URL from Firebase Storage.")
//        return
//      }
//      guard let url = url else {
//        print("Error assigning url.")
//        return
//      }
//      print("URL: \(url)")
//
//    }
    // Download profile picture in memory  with a maximum allowed size of 1MB
    profilePictureRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
      if error != nil {
        print("Error getting data from Firebase Storage")
        return
      } else {
        let profileImage = UIImage(data: data!)
        self.profilePicture.image = profileImage
      }
    }
    
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
  
  func getAge(currentDate: String, dateOfBirth: String) -> Int {
    let currentDateArray: [String] = currentDate.wordList
    let dateOfBirthArray: [String] = dateOfBirth.wordList
    for element in currentDateArray { print(element) }
    for element in dateOfBirthArray { print(element) }
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

extension String {
    var wordList: [String] {
        return components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
    }
}
