//
//  VideoChatViewController.swift
//  iOSApp
//
//  Created by Eric Gustin on 6/5/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//

import UIKit
import TwilioVideo

class VideoChatViewController: UIViewController {
   
  var accessToken: String = ""
  var room: Room?
  var localVideoTrack: LocalVideoTrack?
  var localAudioTrack = LocalAudioTrack()
  var localDataTrack = LocalDataTrack()
  var camera: CameraSource?
  var remoteView: VideoView?
  
  var roomName: String
  
  var previewView: VideoView?
  var disconnectButton: UIButton?
  var muteButton: UIButton?
  var flipCameraButton: UIButton?
  
  let frontCamera = CameraSource.captureDevice(position: .front)
  let backCamera = CameraSource.captureDevice(position: .back)
  
  init(chatRoomID: String) { // initializer for joining an already existing chat room
    self.roomName = chatRoomID
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func disconnect() {
    disconnectButton!.backgroundColor = UIColor(red: 1, green: 0, blue: 50/255, alpha: 1)
    room?.disconnect()
    transitionToHome()
  }
  
  @objc func muteButtonClicked() {
    print("mute button clicked")
    if (self.localAudioTrack != nil) {
      self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
      
      // Update the button title
      if (self.localAudioTrack?.isEnabled == true) {
        muteButton?.tintColor = UIColor.init(red: 59/255, green: 100/255, blue: 180/255, alpha: 1)
        muteButton?.backgroundColor = .white
      } else {
        muteButton?.tintColor = .white
        muteButton?.backgroundColor = UIColor.init(red: 59/255, green: 100/255, blue: 180/255, alpha: 1)
      }
    }
  }
  
  @objc func flipCamera() {
    print("double clicked")
    if frontCamera != nil && backCamera != nil && camera != nil {
      print("again")
      if camera!.device == frontCamera {
        camera!.selectCaptureDevice(backCamera!)
        flipCameraButton?.tintColor = .white
        flipCameraButton?.backgroundColor = UIColor.init(red: 59/255, green: 100/255, blue: 180/255, alpha: 1)
      } else {
        camera!.selectCaptureDevice(frontCamera!)
        flipCameraButton?.tintColor = UIColor.init(red: 59/255, green: 100/255, blue: 180/255, alpha: 1)
        flipCameraButton?.backgroundColor = .white
      }
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("in video view controller")
    addNotifications()
    requestAccessToken()
    setupViews()
    
    while accessToken == "" {
    }
    
    print("Access token " + accessToken)
    startPreview()
    
    let connectOptions = ConnectOptions(token: accessToken) { (builder) in
      builder.roomName = self.roomName
      
      if let audioTrack = self.localAudioTrack {
        builder.audioTracks = [ audioTrack ]
      }
      if let dataTrack = self.localDataTrack {
        builder.dataTracks = [ dataTrack ]
      }
      if let videoTrack = self.localVideoTrack {
        builder.videoTracks = [ videoTrack ]
      }
      
    }
    room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
    print("Joined a room")
    
    if (frontCamera != nil && backCamera != nil) {
      // Flip camera on tap.
      let tap = UITapGestureRecognizer(target: self, action: #selector(flipCamera))
      tap.numberOfTapsRequired = 2
      previewView?.addGestureRecognizer(tap)
      remoteView?.addGestureRecognizer(tap)
    }
  }
  
  private func addNotifications() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(goHome), name: UIApplication.didEnterBackgroundNotification, object: nil)
  }
  
  func requestAccessToken() {
    let tokenURL = "http://2240042d9e2b.ngrok.io"
    if let url = URL(string: tokenURL) {
      let task = URLSession.shared.dataTask(with: url) {
        data, response, error in
        if error != nil {
          print(error!)
        } else {
          if let responseString = String(data: data!, encoding: .utf8) {
            print("response string: " + responseString)
            self.accessToken = responseString
          }
        }
      }
      task.resume()
    }
  }
  
  func startPreview() {
    
    if (frontCamera != nil || backCamera != nil) {
      // Preview our local camera track in the local video preview view.
      camera = CameraSource(delegate: self)
      localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")
      
      // Add renderer to video track for local preview
      localVideoTrack!.addRenderer(previewView!)
      
      camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
        if error != nil {
          print("couldn't capture preview video")
        } else {
          self.previewView!.shouldMirror = (captureDevice.position == .front)
        }
      }
    }
    else {
      print("No front or back capture device found!")
    }
  }
  
  // set up, initialize and set constraints for programmatic views
  func setupViews() {
    // Preview View
    previewView = VideoView.init(frame: CGRect.zero, delegate: self)
    view.addSubview(previewView!)
    previewView?.translatesAutoresizingMaskIntoConstraints = false
    let previewViewWidth = NSLayoutConstraint(item: previewView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120);
    let previewViewHeight = NSLayoutConstraint(item: previewView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 160);
    let previewViewHorizontal = NSLayoutConstraint(item: previewView!, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 20)
    let previewViewVertical = NSLayoutConstraint(item: previewView!, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20)
    view.addConstraints([previewViewWidth, previewViewHeight, previewViewHorizontal, previewViewVertical])
    
    // Disconnect Button
    disconnectButton = UIButton(type: .custom)
    disconnectButton?.setImage(UIImage(systemName: "phone.down.fill"), for: .normal)
    disconnectButton?.setImage(UIImage(systemName: "phone.down.fill"), for: .selected)
    disconnectButton?.tintColor = .white
    disconnectButton?.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    disconnectButton?.contentHorizontalAlignment = .fill
    disconnectButton?.contentVerticalAlignment = .fill
    disconnectButton?.contentEdgeInsets = UIEdgeInsets(top: 22, left: 7.5, bottom: 22, right: 7.5)
    disconnectButton!.addTarget(self, action: #selector(disconnect), for: .touchUpInside)
    view.addSubview(disconnectButton!)
    disconnectButton?.translatesAutoresizingMaskIntoConstraints = false
    let disconnectButtonWidth = NSLayoutConstraint(item: disconnectButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 64);
    let disconnectButtonHeight = NSLayoutConstraint(item: disconnectButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 64);
    let disconnectButtonHorizontal = NSLayoutConstraint(item: disconnectButton!, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1, constant: 0)
    let disconnectButtonVertical = NSLayoutConstraint(item: disconnectButton!, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -20)
    view.addConstraints([disconnectButtonWidth, disconnectButtonHeight, disconnectButtonHorizontal, disconnectButtonVertical])
    disconnectButton?.layer.cornerRadius = disconnectButtonWidth.constant / 2
    
    // Mute Button
    muteButton = UIButton(type: .custom)
    muteButton!.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
    muteButton!.setImage(UIImage(systemName: "mic.fill"), for: .selected)
    muteButton?.tintColor = UIColor.init(red: 59/255, green: 100/255, blue: 180/255, alpha: 1)
    muteButton?.backgroundColor = .white
    muteButton?.contentHorizontalAlignment = .fill
    muteButton?.contentVerticalAlignment = .fill
    muteButton?.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    muteButton!.addTarget(self, action: #selector(muteButtonClicked), for: .touchUpInside)
    view.addSubview(muteButton!)
    muteButton?.translatesAutoresizingMaskIntoConstraints = false
    let muteButtonWidth = NSLayoutConstraint(item: muteButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 56);
    let muteButtonHeight = NSLayoutConstraint(item: muteButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 56);
    let muteButtonHorizontal = NSLayoutConstraint(item: muteButton!, attribute: .trailing, relatedBy: .equal, toItem: disconnectButton, attribute: .leading, multiplier: 1, constant: -40)
    let muteButtonVertical = NSLayoutConstraint(item: muteButton!, attribute: .centerY, relatedBy: .equal, toItem: disconnectButton, attribute: .centerY, multiplier: 1, constant: 0)
    view.addConstraints([muteButtonWidth, muteButtonHeight, muteButtonHorizontal, muteButtonVertical])
    muteButton?.layer.cornerRadius = muteButtonWidth.constant / 2
    
    // Camera Button
    flipCameraButton = UIButton(type: .custom)
    flipCameraButton!.setImage(UIImage(systemName: "camera.rotate.fill"), for: .normal)
    flipCameraButton!.setImage(UIImage(systemName: "camera.rotate"), for: .selected)
    flipCameraButton?.tintColor = UIColor.init(red: 59/255, green: 100/255, blue: 180/255, alpha: 1)
    flipCameraButton?.backgroundColor = .white
    flipCameraButton?.contentHorizontalAlignment = .fill
    flipCameraButton?.contentVerticalAlignment = .fill
    flipCameraButton?.contentEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
    flipCameraButton!.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
    view.addSubview(flipCameraButton!)
    flipCameraButton?.translatesAutoresizingMaskIntoConstraints = false
    let flipCameraButtonWidth = NSLayoutConstraint(item: flipCameraButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 56);
    let flipCameraButtonHeight = NSLayoutConstraint(item: flipCameraButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 56);
    let flipCameraButtonHorizontal = NSLayoutConstraint(item: flipCameraButton!, attribute: .leading, relatedBy: .equal, toItem: disconnectButton, attribute: .trailing, multiplier: 1, constant: 40)
    let flipCameraButtonVertical = NSLayoutConstraint(item: flipCameraButton!, attribute: .centerY, relatedBy: .equal, toItem: disconnectButton, attribute: .centerY, multiplier: 1, constant: 0)
    view.addConstraints([flipCameraButtonWidth, flipCameraButtonHeight, flipCameraButtonHorizontal, flipCameraButtonVertical])
    flipCameraButton?.layer.cornerRadius = flipCameraButtonWidth.constant / 2
  }
  
  @objc func goHome() {
    transitionToHome()
  }
  
  // MARK: Transitions
  private func transitionToHome() {
    UserDefaults.standard.set(true, forKey: "isComingFromVideoChat")
    camera?.stopCapture()
    navigationController?.pushViewController(HomeViewController(), animated: false)
  }
  
  func exitAlert() {
    self.dismiss(animated: true, completion: nil)
    transitionToHome()
  }
}

extension VideoChatViewController : RoomDelegate {
  
  func roomDidConnect(room: Room) {
    print("Did connect to room")
    if let localParticipant = room.localParticipant {
      print("Local identity \(localParticipant.identity)")
      
      // set the delegate of the local participant to receive callbacks
      localParticipant.delegate = self
    }
    
    print("Number of connected Participants \(room.remoteParticipants.count)")
    
    for remoteParticipant in room.remoteParticipants {
      remoteParticipant.delegate = self
    }
  }
  
  func participantDidConnect(room: Room, participant: RemoteParticipant) {
    print("Participant \(participant.identity) has joined Room \(room.name)")
    
    participant.delegate = self // delegate of the remote participant can now recieve callbacks
  }
  
  func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
    print ("Participant \(participant.identity) has left Room \(room.name)")
    // create alert
    let userLeftAlert = UIAlertController(title: "Your new friend left the chat", message: "", preferredStyle: .alert)
    let userLeftAction = UIAlertAction(title: "OK", style: .default, handler: {
      action in self.exitAlert()
    })
    userLeftAlert.addAction(userLeftAction)
    self.present(userLeftAlert, animated: true, completion: nil)
  }
  
}

extension VideoChatViewController : RemoteParticipantDelegate {
  
  func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack,
                                publication: RemoteVideoTrackPublication,
                                participant: RemoteParticipant) {
    
    print("Participant \(participant.identity) added a video track.")
    
    if let remoteView = VideoView.init(frame: self.view.bounds,
                                       delegate: self) {
      videoTrack.addRenderer(remoteView)
      self.view.addSubview(remoteView)
      self.remoteView = remoteView
      print("remote view alternate setup")
      view.sendSubviewToBack(self.remoteView!)
    }
  }
  
}

extension VideoChatViewController : LocalParticipantDelegate {
  
}

extension VideoChatViewController: VideoViewDelegate {
  
  // subscribe to events
  func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
    print("The dimensions of the video track changed to: \(dimensions.width)x\(dimensions.height)")
    self.view.setNeedsLayout()
  }
}

extension VideoChatViewController : CameraSourceDelegate {
  
}
