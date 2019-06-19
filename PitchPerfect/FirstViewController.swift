//
//  FirstViewController.swift
//  PitchPerfect
//
//  Created by Darwin Bohorquez on 6/17/19.
//  Copyright © 2019 Darwin Bohorquez. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation

class FirstViewController: UIViewController, UNUserNotificationCenterDelegate, AVAudioRecorderDelegate {

    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    var audioRecorder: AVAudioRecorder!
    let session = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        UNUserNotificationCenter.current().delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Stop recording button disabled
        super.viewWillAppear(animated)
        stopRecordingButton.isEnabled = false
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: textBox.text != "" ? textBox.text : "no ingreso texto", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            self.userPressedOk()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func userPressedOk() {
        textBox.text = nil
    }
    
    @IBAction func notificationButtonPress(_ sender: Any) {
        print("pressed notification button")
        
        let content = UNMutableNotificationContent()
        content.title = "notificacion"
        content.body = textBox.text != "" ? textBox.text! : "bla bla bla"
        content.sound = UNNotificationSound.default
        content.badge = 0
        content.categoryIdentifier = "app-notification"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "app-notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    @IBAction func recordButtonPress(_ sender: Any) {
        recordingLabel.text = "Recording in progress"
        recordButton.isEnabled = false
        stopRecordingButton.isEnabled = true
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecordingButtonPress(_ sender: Any) {
        recordButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        recordingLabel.text = "Tap to Record"
        
        audioRecorder.stop()
//        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecordingSegue", sender: audioRecorder.url)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecordingSegue" {
            let playSoundVC = segue.destination as! SecondViewController
            let recordedAudioURL = sender as! URL
            playSoundVC.recordedAudioURL = recordedAudioURL
        }
    }
}

