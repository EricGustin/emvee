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
  
  //  Views
  private var scrollView: UIScrollView!
  private var profilePictureVertStack: UIStackView!
  private var profilePicturesHorizStacks: [UIStackView]!
  private var profilePicturesContainer: [UIView]!
  private var profilePictures: [UIImageView]!
  private var deleteProfilePictureButtonContainers: [UIView]!
  private var deleteProfilePictureButtons: [UIButton]!
  private var aboutMeLabel: UILabel!
  private var aboutMeTextView: UITextView!
  private var aboutMeCharsRemainingLabel: UILabel!
  private var myBasicInfoLabel: UILabel!
  private var genderButton: UIButton!
  private var genderGreaterThanImage: UIImageView!
  private var locationButton: UIButton!
  private var locationGreaterThanImage: UIImageView!
  private var hometownButton: UIButton!
  private var hometownGreaterThanImage: UIImageView!
  //  Variables & constants
  private var savedAboutMeText: String?
  private var profilePictureBeingEditedIndex: Int!  // The index of the profile picture being edited
  private var profilePictureBeingDeletedIndex: Int!  // The index of the profile picture that was deleted
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemGray6
    
    setUpNavigationBar()
    setupSubviews()
    downloadProfilePicturesFromFirebase()
    
    // Adjust scrollView's inset when needed e.g. when keyboard is shown / is hidden
    NotificationCenter.default.addObserver(self, selector: #selector(adjustInsetForKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(adjustInsetForKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
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
    
    aboutMeLabel = UILabel()
    aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
    aboutMeLabel.text = "About me"
    aboutMeLabel.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Semibold", size: 16), size: 16)
    aboutMeLabel.textColor = .black
    aboutMeLabel.textAlignment = .center
    scrollView.addSubview(aboutMeLabel)
    aboutMeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,  constant: UIScreen.main.bounds.width / 20 + 25).isActive = true  // Logic behind the constant: The aboutMeTextView is centered and has a width of 0.9 * view.width, thus the aboutMeTextView's leading is effectively view.width / 20. In addition, adding 25 in order to match the aboutMeTextView's corner radius which is essential for the desired position.
    aboutMeLabel.topAnchor.constraint(equalTo: profilePictureVertStack.bottomAnchor, constant: 80).isActive = true
    
    // Lastly, calculate the content size of the scrollView
    scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
    
    aboutMeTextView = UITextView()
    aboutMeTextView.delegate = self
    aboutMeTextView.translatesAutoresizingMaskIntoConstraints = false
    aboutMeTextView.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter", size: 12), size: 12)
    aboutMeTextView.layer.cornerRadius = 25
    aboutMeTextView.layer.borderColor = UIColor.lightGray.cgColor
    aboutMeTextView.layer.borderWidth = 0.25
    aboutMeTextView.backgroundColor = .white
    aboutMeTextView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    scrollView.addSubview(aboutMeTextView)
    aboutMeTextView.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 5).isActive = true
    aboutMeTextView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
    aboutMeTextView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true  // 3:1 AspectRatio
    aboutMeTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    aboutMeTextView.addKeyboardToolBar(leftTitle: "Cancel", rightTitle: "Save", target: self, selector: #selector(dismissKeyboard(sender:)))
    
    aboutMeCharsRemainingLabel = UILabel()
    aboutMeCharsRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
    aboutMeCharsRemainingLabel.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter", size: 12), size: 12)
    aboutMeCharsRemainingLabel.textColor = .lightGray
    aboutMeCharsRemainingLabel.textAlignment = .center
    scrollView.addSubview(aboutMeCharsRemainingLabel)
    aboutMeCharsRemainingLabel.bottomAnchor.constraint(equalTo: aboutMeTextView.bottomAnchor, constant: -aboutMeTextView.layer.cornerRadius / 2).isActive = true
    aboutMeCharsRemainingLabel.trailingAnchor.constraint(equalTo: aboutMeTextView.trailingAnchor, constant: -aboutMeTextView.layer.cornerRadius / 2).isActive = true
    
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
  
  @objc func adjustInsetForKeyboard(_ notification: Notification) {
    
    guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    let keyboardScreenEndFrame = keyboardValue.cgRectValue
    let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
    
    let willHideKeyboard = notification.name == UIResponder.keyboardWillHideNotification
    
    if willHideKeyboard { // if keyboard will hide
      scrollView.contentInset = .zero
    } else { // if keyboard will show
      scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
      scrollView.setContentOffset(CGPoint(x: 0, y: 250), animated: true)
    }
    scrollView.scrollIndicatorInsets = scrollView.contentInset
    
    // disable or enable user interaction for all views that can be interacted with
    for picture in profilePictures {
      picture.isUserInteractionEnabled = willHideKeyboard
    }
    for deleteButton in deleteProfilePictureButtons {
      deleteButton.isUserInteractionEnabled = willHideKeyboard
    }
    scrollView.isScrollEnabled = willHideKeyboard
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
          self.changeProfileImageToPlusSignFormat(index: i)
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
  // I want to "Build the Future".
  private func changeProfileImageToPlusSignFormat(index: Int) {
    profilePictures[index].image = UIImage(systemName: "plus")
    profilePictures[index].tintColor = .lightGray
    profilePictures[index].backgroundColor = .systemGray6
    profilePictures[index].contentMode = .center
  }
  
  private func changeProfileImageToNormalFormat(index: Int) {
    profilePictures[index].tintColor = .none
    profilePictures[index].backgroundColor = .none
    profilePictures[index].contentMode = .scaleAspectFill
  }
  
  @objc private func aDeleteProfilePictureButtonTapped(sender: UIButton) {
    let confirmDeleteAlert = UIAlertController(title: "Are you sure that you want to delete this picture from your profile?", message: "", preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
      self.profilePictureBeingDeletedIndex = sender.tag
      self.deleteProfilePicture()
    }
    let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
    }
    confirmDeleteAlert.addAction(yesAction)
    confirmDeleteAlert.addAction(noAction)
    present(confirmDeleteAlert, animated: true, completion: nil)
  }
  
  private func deleteProfilePicture() {
    
    for index in profilePictureBeingDeletedIndex..<profilePictures.count-1 {
      //  Delete photo locally & move the other photos accordingly
      profilePictures[index].image = profilePictures[index+1].image
      if profilePictures[index].image == UIImage(systemName: "plus") {
        changeProfileImageToPlusSignFormat(index: index)
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
    profilePictures[profilePictures.count-1].image = UIImage(systemName: "plus")
    changeProfileImageToPlusSignFormat(index: profilePictures.count-1)
    deleteProfilePictureButtonContainers[profilePictures.count-1].isHidden = true
    deleteProfilePictureButtons[profilePictures.count-1].isHidden = true
    
    for index in 0..<profilePictures.count {
      if profilePictures[index].image == UIImage(systemName: "plus") {
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
       // break
      }
    }
    
    
  }
  
  @objc func dismissKeyboard(sender: UIBarButtonItem) {
    if sender.title == "Save" {
      saveTextView(firestoreField: "bio", textView: aboutMeTextView)
      savedAboutMeText = aboutMeTextView.text
    } else {
      aboutMeTextView.text = savedAboutMeText
    }
    self.view.endEditing(true)
  }
  
  func saveTextView(firestoreField: String, textView: UITextView) {
    updateCloudFirestoreField(firestoreField, textView.text ?? 0)
  }
  
  func updateCloudFirestoreField(_ fieldName: String, _ newValue: Any) {
    guard let userID = Auth.auth().currentUser?.uid else {
      print("Error accessing userID")
      return
    }
    let db = Firestore.firestore() // initialize an instance of Cloud Firestore
    db.collection("users").document(userID).updateData([fieldName: newValue])
  }
  
  // The user has a maximum of 255 characters for their bio. This function calculates the number of chars That they can still add to their bio and updates the bioCharsLeftLabel accordingly.
  func displayBioCharsLeft() {
    let currChars = aboutMeTextView.text.count
    
    aboutMeCharsRemainingLabel.animateTransform(withIncreaseDuration: 0.1, withDecreaseDuration: 0.1, withIncreaseScale: 1.1, withDecreaseScale: 1)
    
    aboutMeCharsRemainingLabel.text = String(255 - currChars)
    
    if currChars < 230 {
      aboutMeCharsRemainingLabel.textColor = UIColor.lightGray
    } else {
      aboutMeCharsRemainingLabel.textColor = UIColor.red
    }
  }
  
  @objc private func aProfilePictureTapped(_ gestureRecognizer: UITapGestureRecognizer) {
    
    guard gestureRecognizer.view != nil else { return }
    
    profilePictureBeingEditedIndex = gestureRecognizer.view!.tag
    if profilePictures[profilePictureBeingEditedIndex].image == UIImage(systemName: "plus") {
      //  Change the index to the first ImageView that is not filled with a profile picture
      for index in 0..<profilePictures.count {
        if profilePictures[index].image == UIImage(systemName: "plus") {
          profilePictureBeingEditedIndex = index
          break
        }
      }
    }
    
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
    addActionSheetForiPad(actionSheet: alert)
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
      profilePictures[profilePictureBeingEditedIndex].image = profileImage
      changeProfileImageToNormalFormat(index: profilePictureBeingEditedIndex)
      deleteProfilePictureButtonContainers[profilePictureBeingEditedIndex].isHidden = false
      deleteProfilePictureButtons[profilePictureBeingEditedIndex].isHidden = false
    }
    
    dismiss(animated: true, completion: nil) // dismiss the UIImagePickerControllers and go back to profile VC
    
    uploadProfilePictureToFirebase()
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }

}

extension EditProfileViewController: UITextViewDelegate {
  
  // Adds the new character to the user's bio if it doesn't exceed 255 chars, else no update occurs
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if 255 - aboutMeTextView.text.count == 0 {
      if range.length != 1 {
        return false
      }
    }
    return true
  }

  func textViewDidBeginEditing(_ textView: UITextView) {
    print("Did begin editing")
  }
  
  func textViewDidChange(_ textView: UITextView) {
    displayBioCharsLeft()
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    print("textView done editing.")
  }
  
}
