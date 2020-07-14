//
//  ProfilePreviewPopup.swift
//  emvee
//
//  Created by Eric Gustin on 6/26/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ProfilePreviewPopup: UIView, Popup {

  private var profilePictures = [UIImageView]()
  private var name: String?
  private var aboutMeText: String?
  private var remoteUserUID: String?
  
  private let container: UIView = {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.backgroundColor = .systemGray6
    container.layer.cornerRadius = 24
    return container
  }()
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = .clear
    return scrollView
  }()
  
  private let profilePicturesContainer: UIView = {
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.layer.borderWidth = 0.25
    container.layer.borderColor = UIColor.lightGray.cgColor
    return container
  }()
  
  private var profilePicturesScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = .white
    scrollView.isPagingEnabled = true
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.layer.borderColor = UIColor.white.cgColor
    scrollView.layer.borderWidth = 5
    scrollView.layer.masksToBounds = true
    return scrollView
  }()
  
  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.text = self.name
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Bold", size: 18), size: 18)
    label.textColor = .black
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private var aboutRemoteUserLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Semibold", size: 16), size: 16)
    label.textColor = .black
    return label
  }()
  
  private lazy var aboutRemoteUserTextView: UITextView = {
    let textView = UITextView()
    if self.aboutMeText != nil {
      textView.text = self.aboutMeText
      textView.translatesAutoresizingMaskIntoConstraints = false
      textView.isEditable = false
      textView.isScrollEnabled = true
      textView.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter", size: 12), size: 12)
      textView.textColor = .black
      textView.layer.cornerRadius = 25
      textView.layer.borderColor = UIColor.lightGray.cgColor
      textView.layer.borderWidth = 0.25
      textView.backgroundColor = .white
      textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    return textView
  }()
  
  private var basicInfoLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont(descriptor: UIFontDescriptor(name: "American Typewriter Semibold", size: 16), size: 16)
    label.textColor = .black
    return label
  }()
  
  
  private var genderButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    StyleUtilities.styleBasicInfoButton(button)
    button.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    button.heightAnchor.constraint(equalToConstant: 35).isActive = true
    return button
  }()
  
  private var preferredGenderButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    StyleUtilities.styleBasicInfoButton(button)
    button.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    button.heightAnchor.constraint(equalToConstant: 35).isActive = true
    return button
  }()
  
  private var hometownButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    StyleUtilities.styleBasicInfoButton(button)
    button.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    button.heightAnchor.constraint(equalToConstant: 35).isActive = true
    return button
  }()
  
  private var currentLocationButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    StyleUtilities.styleBasicInfoButton(button)
    button.tintColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
    button.heightAnchor.constraint(equalToConstant: 35).isActive = true
    return button
  }()
  
  private lazy var basicInfoVerticalStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 5
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.addArrangedSubview(basicInfoLabel)
    stack.addArrangedSubview(genderButton)
    stack.addArrangedSubview(preferredGenderButton)
    stack.addArrangedSubview(hometownButton)
    stack.addArrangedSubview(currentLocationButton)
    return stack
  }()
  
  required init(name: String?, aboutMeText: String?, remoteUserUID: String?) {
    super.init(frame: .zero)
    self.remoteUserUID = remoteUserUID
    self.name = name
    self.aboutMeText = aboutMeText
    postInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    postInit()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {}
  
  private func postInit() {
    scrollView.delegate = self
    backgroundColor = UIColor.gray.withAlphaComponent(0.7)
    self.frame = UIScreen.main.bounds
    
    getRemoteUserFieldsFromFirebase()
    setUpSubviews()
    animateIn()
    setUpGestures()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //  Source: Agent Smith from Github post https://stackoverflow.com/questions/43494848/detect-any-tap-outside-the-current-view
    let touch = touches.first
    guard let location = touch?.location(in: self) else { return }
    if !container.frame.contains(location) {
      animateOut()
    }
  }
  
  internal func setUpSubviews() {
    
    self.addSubview(scrollView)
    scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true  // 20 + the height of the messageInputBar
    scrollView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
    
    scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    
    scrollView.addSubview(container)
    container.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    container.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true  // 20 + the height of the messageInputBar
    container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
    container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    
    
    scrollView.addSubview(profilePicturesContainer)
    profilePicturesContainer.centerXAnchor.constraint(equalTo: container.safeAreaLayoutGuide.centerXAnchor).isActive = true
    NSLayoutConstraint(item: profilePicturesContainer, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 0.5, constant: 0).isActive = true
    profilePicturesContainer.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.5).isActive = true
    profilePicturesContainer.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.5).isActive = true
    profilePicturesContainer.contentMode = .scaleAspectFill
    profilePicturesContainer.layer.cornerRadius = UIScreen.main.bounds.width / 5
    profilePicturesContainer.layer.masksToBounds = true
    
    scrollView.addSubview(profilePicturesScrollView)
    profilePicturesScrollView.centerXAnchor.constraint(equalTo: container.safeAreaLayoutGuide.centerXAnchor).isActive = true
    NSLayoutConstraint(item: profilePicturesScrollView, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 0.5, constant: 0).isActive = true
    profilePicturesScrollView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.5).isActive = true
    profilePicturesScrollView.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.5).isActive = true
    profilePicturesScrollView.contentMode = .scaleAspectFill
    profilePicturesScrollView.layer.cornerRadius = UIScreen.main.bounds.width / 5
    profilePicturesScrollView.layer.masksToBounds = true
    scrollView.contentSize = CGSize(width: profilePicturesScrollView.frame.width*3, height: profilePicturesScrollView.frame.height)
    
    // Add profile pictures to profilePicturesScrollView
    profilePictures = [UIImageView]()
    for _ in 0..<6 { profilePictures.append(UIImageView()) }
    downloadRemoteProfilePicturesFromFirebase()
    
    scrollView.addSubview(nameLabel)
    nameLabel.heightAnchor.constraint(equalToConstant: 23).isActive = true
    nameLabel.centerXAnchor.constraint(equalTo: profilePicturesContainer.centerXAnchor).isActive = true
    nameLabel.topAnchor.constraint(equalTo: profilePicturesContainer.bottomAnchor, constant: 20).isActive = true
    
    scrollView.addSubview(aboutRemoteUserLabel)
    aboutRemoteUserLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    aboutRemoteUserLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 80).isActive = true
    aboutRemoteUserLabel.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.9).isActive = true
    aboutRemoteUserLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
    
    scrollView.addSubview(aboutRemoteUserTextView)
    aboutRemoteUserTextView.topAnchor.constraint(equalTo: aboutRemoteUserLabel.bottomAnchor, constant: 0).isActive = true
    aboutRemoteUserTextView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.9).isActive = true
    aboutRemoteUserTextView.heightAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.3).isActive = true
    aboutRemoteUserTextView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
    
    scrollView.addSubview(basicInfoVerticalStack)
    basicInfoVerticalStack.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.9).isActive = true
    basicInfoVerticalStack.topAnchor.constraint(equalTo: aboutRemoteUserTextView.bottomAnchor, constant: 60).isActive = true
    basicInfoVerticalStack.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
    
    // Lastly, calculate the content size of the scrollView
    scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: self.frame.width * 0.64 + (self.frame.height-90) * 0.125 + 550)
  }
  
  private func getRemoteUserFieldsFromFirebase() {
    // TODO: Get the bio and name fields as well instead of passing them as a parameter of the class
    let db = Firestore.firestore()
    db.collection("users").document(remoteUserUID!).getDocument { (snapshot, error) in
      if let document = snapshot {
        self.aboutRemoteUserLabel.text = "    About \(document.get("firstName") ?? "")"
        self.basicInfoLabel.text = "    Basic info about \(document.get("firstName") ?? "")"
        self.genderButton.setTitle("I am a \(document.get("gender") ?? "")", for: .normal)
        self.preferredGenderButton.setTitle("I am interested in \(document.get("preferredGender") ?? "")", for: .normal)
        self.hometownButton.setTitle("I am from \(document.get("hometown") ?? "")", for: .normal)
        self.currentLocationButton.setTitle("I am living in \(document.get("currentLcoation") ?? "")", for: .normal)
      }
    }
  }
  
  private func downloadRemoteProfilePicturesFromFirebase() {

    var imageIndex = 0
    for i in 0..<6 {
      let aProfilePictureRef = Storage.storage().reference().child("profilePictures/\(remoteUserUID!)/picture\(i)")
      // Download profile picture in memory  with a maximum allowed size of 1MB
      aProfilePictureRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
        if error != nil {
          return
        } else {
          let aProfilePicture = UIImage(data: data!)
          self.profilePictures[i].image = aProfilePicture
          self.profilePictures[imageIndex].frame = CGRect(x: CGFloat(imageIndex) * 0.8*self.safeAreaLayoutGuide.layoutFrame.width/2, y: 0, width: 0.8*UIScreen.main.bounds.width/2, height: 0.8*UIScreen.main.bounds.width/2)
          self.profilePictures[imageIndex].contentMode = .scaleAspectFill
          self.profilePictures[imageIndex].clipsToBounds = true
          self.profilePicturesScrollView.addSubview(self.profilePictures[imageIndex])
          self.profilePicturesScrollView.contentSize.width += (self.profilePicturesContainer.frame.width - 0.5)
          imageIndex += 1
        }
      }
    }
  }
  
  internal func animateIn() {
    container.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
    scrollView.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
    self.alpha = 0
    self.scrollView.alpha = 0
    self.profilePicturesScrollView.alpha = 0
    self.container.alpha = 0
    profilePicturesContainer.alpha = 0
    nameLabel.alpha = 0
    aboutRemoteUserTextView.alpha = 0
    basicInfoVerticalStack.alpha = 0
    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
      self.alpha = 1
      self.container.alpha = 1
      self.scrollView.alpha = 1
      self.profilePicturesContainer.alpha = 1
      self.profilePicturesScrollView.alpha = 1
      self.nameLabel.alpha = 1
      self.aboutRemoteUserTextView.alpha = 1
      self.basicInfoVerticalStack.alpha = 1
      self.container.transform = .identity  // reset transform
      self.scrollView.transform = .identity
    })
  }
  
  func setUpGestures() {}
  
  func animateOut() {
    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseIn, animations: {
      self.container.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
      self.scrollView.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
      self.alpha = 0
      self.container.alpha = 0
      self.scrollView.alpha = 0
      self.profilePicturesContainer.alpha = 0
      self.profilePicturesScrollView.alpha = 0
      self.nameLabel.alpha = 0
      self.aboutRemoteUserTextView.alpha = 0
      self.basicInfoVerticalStack.alpha = 0
    }) { (complete) in
      if complete {
        self.removeFromSuperview()
      }
    }
  }
  
}

extension ProfilePreviewPopup : UIScrollViewDelegate {
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if scrollView.contentOffset.y <= 0 {
      animateOut()
    }
  }
}
