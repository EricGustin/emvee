//
//  EditProfileViewController.swift
//  emvee
//
//  Created by Eric Gustin on 6/23/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {
  
  private var scrollView: UIScrollView!
  private var profilePictureVertStack: UIStackView!
  private var profilePicturesHorizStacks: [UIStackView]!
  private var profilePicturesContainer: [UIView]!
  private var profilePictures: [UIImageView]!
  private var deleteProfilePictureButtonContainers: [UIView]!
  private var deleteProfilePictureButtons: [UIButton]!
  private var profilePictureBeingEditedIndex: Int!  // The index of the profile picture being edited
  private var profilePictureBeingDeletedIndex: Int!  // The index of the profile picture that was deleted
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemGray6
    
    setUpNavigationBar()
    setupSubviews()
    downloadProfilePicturesFromFirebase()
  }
  
  private func setUpNavigationBar() {
    title = "Edit Profile"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(transitionToProfile))
  }
  
  private func setupSubviews() {
    
    profilePicturesContainer = [UIView]()
    profilePictures = [UIImageView]()
    for index in 0..<6 {
      // Set up each container for profile pictures
      profilePicturesContainer.append(UIView())
      profilePicturesContainer[index].layer.borderColor = UIColor.lightGray.cgColor
      profilePicturesContainer[index].layer.borderWidth = 0.25
      profilePicturesContainer[index].layer.cornerRadius = (UIScreen.main.bounds.width - 40) / 6  // 40 represents the sum of profilePictureVertStack leading and trailing, and the spacing of the profilePicturesHorizStacks. Divide by 6 because there are 3 profile pictures per row and you want the radius of each photo, so we divide by 6.
      
      // Set up each profile picture view
      profilePictures.append(UIImageView(image: UIImage()))
      profilePictures[index].backgroundColor = .white
      profilePictures[index].contentMode = .scaleAspectFill
      profilePictures[index].translatesAutoresizingMaskIntoConstraints = false
      profilePictures[index].isUserInteractionEnabled = true
      profilePictures[index].layer.borderWidth = 4.75
      profilePictures[index].layer.borderColor = UIColor.white.cgColor
      profilePictures[index].layer.cornerRadius = (UIScreen.main.bounds.width - 40 - 1.5) / 6  // 40 represents the sum of profilePictureVertStack leading and trailing, and the spacing of the profilePicturesHorizStacks. The 1.5 is profilePicturesContainer[index].layer.borderWidth * 6. Divide by 6 because there are 3 profile pictures per row and you want the radius of each photo, so we divide by 6.
      profilePictures[index].layer.masksToBounds = true
      profilePictures[index].tag = index  // the tag is used to keep track of which profilePicture is supposed to changed/edited
      profilePictures[index].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(aProfilePictureTapped)))
      profilePicturesContainer[index].addSubview(profilePictures[index])
      profilePictures[index].leadingAnchor.constraint(equalTo: profilePicturesContainer[index].leadingAnchor, constant: profilePicturesContainer[index].layer.borderWidth).isActive = true
      profilePictures[index].topAnchor.constraint(equalTo: profilePicturesContainer[index].topAnchor, constant: profilePicturesContainer[index].layer.borderWidth).isActive = true
      profilePictures[index].trailingAnchor.constraint(equalTo: profilePicturesContainer[index].trailingAnchor, constant: -profilePicturesContainer[index].layer.borderWidth).isActive = true
      profilePictures[index].bottomAnchor.constraint(equalTo: profilePicturesContainer[index].bottomAnchor, constant: -profilePicturesContainer[index].layer.borderWidth).isActive = true
      
    }
    
    profilePicturesHorizStacks = [UIStackView]()
    for i in 0...1 {
      profilePicturesHorizStacks.append(UIStackView(arrangedSubviews: Array(profilePicturesContainer[(i*3)..<(3+i*3)])))
      profilePicturesHorizStacks[i].axis = .horizontal
      profilePicturesHorizStacks[i].distribution = .fillEqually
      profilePicturesHorizStacks[i].spacing = 10
    }
    
    scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
    scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    
    profilePictureVertStack = UIStackView(arrangedSubviews: [profilePicturesHorizStacks[0], profilePicturesHorizStacks[1]])
    profilePictureVertStack.axis = .vertical
    profilePictureVertStack.distribution = .fillEqually
    profilePictureVertStack.spacing = 10
    profilePictureVertStack.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(profilePictureVertStack)
    profilePictureVertStack.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 1.0).isActive = true
    profilePictureVertStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10).isActive = true
    profilePictureVertStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
    profilePictureVertStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
    profilePictureVertStack.heightAnchor.constraint(equalTo: profilePictureVertStack.widthAnchor, multiplier: 2/3).isActive = true
    
    deleteProfilePictureButtonContainers = [UIView]()
    deleteProfilePictureButtons = [UIButton]()
    for index in 0..<6 {
      deleteProfilePictureButtonContainers.append(UIView())
      deleteProfilePictureButtonContainers[index].translatesAutoresizingMaskIntoConstraints = false
      deleteProfilePictureButtonContainers[index].backgroundColor = view.backgroundColor
      deleteProfilePictureButtonContainers[index].layer.cornerRadius = profilePictures[index].layer.cornerRadius / 3
      deleteProfilePictureButtonContainers[index].layer.masksToBounds = true
      deleteProfilePictureButtonContainers[index].isHidden = true
      scrollView.addSubview(deleteProfilePictureButtonContainers[index])
      deleteProfilePictureButtonContainers[index].widthAnchor.constraint(equalTo: profilePictures[index].widthAnchor, multiplier: 1/3).isActive = true
      deleteProfilePictureButtonContainers[index].heightAnchor.constraint(equalTo: profilePictures[index].heightAnchor, multiplier: 1/3).isActive = true
      deleteProfilePictureButtonContainers[index].bottomAnchor.constraint(equalTo: profilePictures[index].bottomAnchor).isActive = true
      deleteProfilePictureButtonContainers[index].trailingAnchor.constraint(equalTo: profilePictures[index].trailingAnchor, constant: deleteProfilePictureButtonContainers[index].frame.width/2).isActive = true
      
      deleteProfilePictureButtons.append(UIButton())
      deleteProfilePictureButtons[index].tag = index
      deleteProfilePictureButtons[index].setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
      deleteProfilePictureButtons[index].backgroundColor = view.backgroundColor
      deleteProfilePictureButtons[index].tintColor = .lightGray
      deleteProfilePictureButtons[index].translatesAutoresizingMaskIntoConstraints = false
      deleteProfilePictureButtonContainers[index].addSubview(deleteProfilePictureButtons[index])
      deleteProfilePictureButtons[index].widthAnchor.constraint(equalTo: profilePictures[index].widthAnchor, multiplier: 1/3).isActive = true
      deleteProfilePictureButtons[index].heightAnchor.constraint(equalTo: profilePictures[index].heightAnchor, multiplier: 1/3).isActive = true
      deleteProfilePictureButtons[index].bottomAnchor.constraint(equalTo: profilePictures[index].bottomAnchor).isActive = true
      deleteProfilePictureButtons[index].trailingAnchor.constraint(equalTo: profilePictures[index].trailingAnchor, constant: deleteProfilePictureButtonContainers[index].frame.width/2).isActive = true
      
      deleteProfilePictureButtons[index].addTarget(self, action: #selector(aDeleteProfilePictureButtonTapped(sender:)), for: .touchUpInside)
    }
    
    
    // Lastly, calculate the content size of the scrollView
    scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
    
  }
  
  private func downloadProfilePicturesFromFirebase() {
    
    guard let userID = Auth.auth().currentUser?.uid else {
      print("Error generating UserID.")
      return
    }
    
    for i in 0..<6 {
      let aProfilePictureRef = Storage.storage().reference().child("profilePictures/\(userID)/picture\(i)")
      // Download profile picture in memory  with a maximum allowed size of 1MB
      aProfilePictureRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
        if error != nil {
          print("Error getting profile picture data or no picture exists. Setting picture to default.")
          self.profilePictures[i].image = UIImage(named: "defaultProfileImage@4x")
          return
        } else {
          let aProfilePicture = UIImage(data: data!)
          self.profilePictures[i].image = aProfilePicture
          self.deleteProfilePictureButtonContainers[i].isHidden = false
        }
      }
    }
    
  }
  
  private func uploadProfilePictureToFirebase() {
    guard let image = profilePictures[profilePictureBeingEditedIndex].image,
      let nonCompressedData = image.jpegData(compressionQuality: 1.0),
      let data = image.jpegData(compressionQuality: CGFloat((1048576) / nonCompressedData.count)) // 1024*1024 = 1048576 bytes = 1mb
      else {
        print("Couldnt convert image to data")
        return
    }

    guard let userID = Auth.auth().currentUser?.uid else {
      print("Error generating UserID.")
      return
    }

    let aProfilePictureRef = Storage.storage().reference().child("profilePictures/\(userID)/picture\( profilePictureBeingEditedIndex ?? 0)")
    
    // upload the picture to Firebase
    aProfilePictureRef.putData(data, metadata: nil) { (metadata, error) in
      if error != nil {
        print("Error putting profilePictureRef data.")
        return
      }
    }
  }
  
  @objc private func aDeleteProfilePictureButtonTapped(sender: UIButton) {
    print("Now all i have to do is delete the photo locally, in the cloud, and move the other photos around.")
    
    profilePictureBeingDeletedIndex = sender.tag
    deleteProfilePicture()
  }
  
  private func deleteProfilePicture() {
    
    for index in profilePictureBeingDeletedIndex..<profilePictures.count-1 {
      //  Delete photo locally & move the other photos accordingly
      profilePictures[index].image = profilePictures[index+1].image
      if profilePictures[index].image == UIImage(named: "defaultProfileImage@4x") {
        deleteProfilePictureButtonContainers[index].isHidden = true
        deleteProfilePictureButtons[index].isHidden = true
        // Delete from Firebase?
 
      } else {
        // Upload the new picture to firebase, effectively deleting the old picture
        profilePictureBeingEditedIndex = index
        uploadProfilePictureToFirebase()
      }
    }
    //  Ensure that the last profile picture is set to the default image since the above for-loop doesn't assign an image to it
    profilePictures[profilePictures.count-1].image = UIImage(named: "defaultProfileImage@4x")
    deleteProfilePictureButtonContainers[profilePictures.count-1].isHidden = true
    deleteProfilePictureButtons[profilePictures.count-1].isHidden = true
    
    for index in 0..<profilePictures.count {
      if profilePictures[index].image == UIImage(named: "defaultProfileImage@4x") {
        //  Delete from firebase
        guard let userID = Auth.auth().currentUser?.uid else {
          print("Error generating UserID.")
          return
        }
        let deletePictureRef = Storage.storage().reference().child("profilePictures/\(userID)/picture\(index)")
        deletePictureRef.delete { (error) in
          if error != nil {
            print("Error deleting profile picture.")
          }
        }
        break
      }
    }
    
    
  }
  
  @objc private func aProfilePictureTapped(_ gestureRecognizer: UITapGestureRecognizer) {
    
    guard gestureRecognizer.view != nil else { return }
    
    profilePictureBeingEditedIndex = gestureRecognizer.view!.tag

    presentImagePickerControllerActionSheet() // UIImagePickerControllerDelegate extension method
  }
  
  @objc private func transitionToProfile() {
    self.dismiss(animated: true, completion: nil)
  }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  private func presentImagePickerControllerActionSheet() {
    // Make actions for the UIAlertController
    let photoLibraryAction = UIAlertAction(title: "Choose from library", style: .default) { (action) in
      self.presentImagePickerController(sourceType: .photoLibrary)
    }
    let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { (action) in
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
  
  private func presentImagePickerController(sourceType: UIImagePickerController.SourceType) {
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
      profilePictures[profilePictureBeingEditedIndex ?? 0].image = profileImage
      deleteProfilePictureButtonContainers[profilePictureBeingEditedIndex ?? 0].isHidden = false
      deleteProfilePictureButtons[profilePictureBeingEditedIndex ?? 0].isHidden = false
    }
    
    dismiss(animated: true, completion: nil) // dismiss the UIImagePickerControllers and go back to profile VC
    
    uploadProfilePictureToFirebase()
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }

}
