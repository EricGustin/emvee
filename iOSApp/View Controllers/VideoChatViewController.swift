//
//  VideoChatViewController.swift
//  iOSApp
//
//  Created by Eric Gustin on 6/5/20.
//  Copyright © 2020 Eric Gustin. All rights reserved.
//
// API_KEY (SID) SKd2c0eef25c29276ca62b7710819ce5b9
// SECRET Qna8T6Zo01NlqtINlcq6fqV7Y0en8VTG
// Account SID AC0f05752188e1d00c4eae5a05e5e8c3fe
// Auth Token b7b5fd1a02344af7fc8b94070190016b

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
  
  init(chatRoomID: String) { // initializer for joining an already existing chat room
    self.roomName = chatRoomID
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func disconnect() {
    room?.disconnect()
    transitionToHome()
    
  }
  
  @objc func muteButtonClicked(_ sender: UIButton) {
    print("mute button clicked")
    if (self.localAudioTrack != nil) {
      self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
      
      // Update the button title
      if (self.localAudioTrack?.isEnabled == true) {
       // self.muteButton.setImage(UIImage(named: "mute@4x"), for: .normal)
      } else {
       // self.muteButton.setImage(UIImage(named: "unmute@4x"), for: .normal)
      }
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("in video view controller")
    
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
  }
  
  func requestAccessToken() {
    let tokenURL = "http://c129e9720d90.ngrok.io"
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
    let frontCamera = CameraSource.captureDevice(position: .front)
    let backCamera = CameraSource.captureDevice(position: .back)
    
    if (frontCamera != nil || backCamera != nil) {
      // Preview our local camera track in the local video preview view.
      camera = CameraSource(delegate: self)
      localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")
      
      // Add renderer to video track for local preview
      localVideoTrack!.addRenderer(previewView!)
      
      //          if (frontCamera != nil && backCamera != nil) {
      //              // We will flip camera on tap.
      //              let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.flipCamera))
      //              self.previewView.addGestureRecognizer(tap)
      //          }
      
      camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
        if error != nil {
          print("couldn't capture preview video")
        } else {
        // self.previewView.shouldMirror = (captureDevice.position == .front)
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
    disconnectButton!.setImage(UIImage(named: "end@4x"), for: .normal)
    disconnectButton!.setImage(UIImage(named: "end_pressed@4x"), for: .selected)
    disconnectButton!.addTarget(self, action: #selector(disconnect), for: .touchUpInside)
    view.addSubview(disconnectButton!)
    disconnectButton?.translatesAutoresizingMaskIntoConstraints = false
    let disconnectButtonWidth = NSLayoutConstraint(item: disconnectButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 64);
    let disconnectButtonHeight = NSLayoutConstraint(item: disconnectButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 64);
    let disconnectButtonHorizontal = NSLayoutConstraint(item: disconnectButton!, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1, constant: 0)
    let disconnectButtonVertical = NSLayoutConstraint(item: disconnectButton!, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -20)
    view.addConstraints([disconnectButtonWidth, disconnectButtonHeight, disconnectButtonHorizontal, disconnectButtonVertical])
    
    // Mute Button
    muteButton = UIButton(type: .custom)
    muteButton!.setImage(UIImage(named: "mute@4x"), for: .normal)
    muteButton!.setImage(UIImage(named: "unmute@4x"), for: .selected)
    view.addSubview(muteButton!)
    muteButton?.translatesAutoresizingMaskIntoConstraints = false
    let muteButtonWidth = NSLayoutConstraint(item: muteButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 56);
    let muteButtonHeight = NSLayoutConstraint(item: muteButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 56);
    let muteButtonHorizontal = NSLayoutConstraint(item: muteButton!, attribute: .trailing, relatedBy: .equal, toItem: disconnectButton, attribute: .leading, multiplier: 1, constant: -40)
    let muteButtonVertical = NSLayoutConstraint(item: muteButton!, attribute: .centerY, relatedBy: .equal, toItem: disconnectButton, attribute: .centerY, multiplier: 1, constant: 0)
    view.addConstraints([muteButtonWidth, muteButtonHeight, muteButtonHorizontal, muteButtonVertical])
  }
  
  // MARK: Transitions
  func transitionToHome() {
    UserDefaults.standard.set(true, forKey: "isComingFromVideoChat")
    self.dismiss(animated: false, completion: nil)
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
