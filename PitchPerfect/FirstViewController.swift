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

class FirstViewController: UIViewController, UNUserNotificationCenterDelegate, AVAudioRecorderDelegate, UITextFieldDelegate {
    
    // MARK: Variables

    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    var audioRecorder: AVAudioRecorder!
    let session = AVAudioSession.sharedInstance()
    var notificationsAmount = 0
    
    // MARK: Load functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        UNUserNotificationCenter.current().delegate = self
        textBox.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Stop recording button disabled
        super.viewWillAppear(animated)
        configureUI(false)
    }
    
    // MARK: UI Functions
    
    func configureUI(_ recording : Bool) {
        if(recording) {
            recordingLabel.text = "Recording in progress"
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
        } else {
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            recordingLabel.text = "Tap to Record"
        }
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: textBox.text != "" ? textBox.text : "no ingreso texto", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            self.userPressedOk()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func userPressedOk() {
        textBox.text = nil
    }
    
    @IBAction func notificationButtonPress(_ sender: Any) {
        let content = UNMutableNotificationContent()
        let appIdentifier = "PitchPerfect"
        content.title = "notificacion"
        content.body = textBox.text != "" ? textBox.text! : "bla bla bla"
        content.sound = UNNotificationSound.default
        content.badge = 0
        content.categoryIdentifier = appIdentifier
        content.threadIdentifier = appIdentifier
        notificationsAmount += 1
        let requestId = appIdentifier + String(notificationsAmount)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: requestId, content: content, trigger: trigger)
        
        //Category
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: appIdentifier, actions: [snoozeAction, deleteAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        UNUserNotificationCenter.current().add(request)
    }
    
    @IBAction func recordButtonPress(_ sender: Any) {
        configureUI(true)
        
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
        configureUI(false)
        
        audioRecorder.stop()
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

