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
  
  //@IBOutlet weak var previewView: VideoView!
  //@IBOutlet weak var disconnectButton: UIButton!
  //@IBOutlet weak var muteButton: UIButton!
  
  init(chatRoomID: String) { // initializer for joining an already existing chat room
    self.roomName = chatRoomID
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @IBAction func disconnectButtonClicked(_ sender: UIButton) {
    room?.disconnect()
    // and then transition
  }
  
  @IBAction func muteButtonClicked(_ sender: UIButton) {
    print("mute button clicked")
    if (self.localAudioTrack != nil) {
      self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
      
      // Update the button title
      if (self.localAudioTrack?.isEnabled == true) {
  //      self.muteButton.setImage(UIImage(named: "mute@4x"), for: .normal)
      } else {
   //     self.muteButton.setImage(UIImage(named: "unmute@4x"), for: .normal)
      }
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("in video view controller")
    
    requestAccessToken()
    
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
    let tokenURL = "http://fdd7bffe31bf.ngrok.io"
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
     //   localVideoTrack!.addRenderer(self.previewView)
      
      //          if (frontCamera != nil && backCamera != nil) {
      //              // We will flip camera on tap.
      //              let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.flipCamera))
      //              self.previewView.addGestureRecognizer(tap)
      //          }
      
      camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
        if error != nil {
          print("couldn't capture preview video")
        } else {
      //    self.previewView.shouldMirror = (captureDevice.position == .front)
        }
      }
    }
    else {
      print("No front or back capture device found!")
    }
  }
  func setupRemoteVideoView() {
    // Creating `VideoView` programmatically
    self.remoteView = VideoView(frame: CGRect.zero, delegate: self)
    self.view.insertSubview(self.remoteView!, at: 1)
    print("setting up remote view")
    // `VideoView` supports scaleToFill, scaleAspectFill and scaleAspectFit
    // scaleAspectFit is the default mode when you create `VideoView` programmatically.
    self.remoteView!.contentMode = .scaleAspectFit
    
    let centerX = NSLayoutConstraint(item: self.remoteView!,
                                     attribute: NSLayoutConstraint.Attribute.centerX,
                                     relatedBy: NSLayoutConstraint.Relation.equal,
                                     toItem: self.view,
                                     attribute: NSLayoutConstraint.Attribute.centerX,
                                     multiplier: 1,
                                     constant: 0);
    self.view.addConstraint(centerX)
    let centerY = NSLayoutConstraint(item: self.remoteView!,
                                     attribute: NSLayoutConstraint.Attribute.centerY,
                                     relatedBy: NSLayoutConstraint.Relation.equal,
                                     toItem: self.view,
                                     attribute: NSLayoutConstraint.Attribute.centerY,
                                     multiplier: 1,
                                     constant: 0);
    self.view.addConstraint(centerY)
    let width = NSLayoutConstraint(item: self.remoteView!,
                                   attribute: NSLayoutConstraint.Attribute.width,
                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                   toItem: self.view,
                                   attribute: NSLayoutConstraint.Attribute.width,
                                   multiplier: 1,
                                   constant: 0);
    self.view.addConstraint(width)
    let height = NSLayoutConstraint(item: self.remoteView!,
                                    attribute: NSLayoutConstraint.Attribute.height,
                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                    toItem: self.view,
                                    attribute: NSLayoutConstraint.Attribute.height,
                                    multiplier: 1,
                                    constant: 0);
    self.view.addConstraint(height)
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
    //   setupRemoteVideoView()
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
