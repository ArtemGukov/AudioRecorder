//
//  RecorderViewController.swift
//  AudioRecorder
//
//  Created by Артем on 14.01.2020.
//  Copyright © 2020 Артем. All rights reserved.
//

import UIKit
import AVFoundation

class RecorderViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
//    MARK: - @IBOutlets
    
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var listRecordingsTableView: UITableView!

//    MARK: - Properties
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recordSession: AVAudioSession!

    var numberOfRecords = 0
    
    var meterTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkPermission()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        audioRecorder = nil
        audioPlayer = nil
    }
    
//    MARK: - Custom methods
    
    private func setupUI() {
        
        recordButton.layer.cornerRadius = recordButton.bounds.width / 2
        recordButton.backgroundColor = .systemRed
        
        stopButton.isEnabled = false
        stopButton.layer.cornerRadius = stopButton.bounds.width / 2
        stopButton.isHighlighted = true
    }
    
    private func checkPermission() {
        
        recordSession = AVAudioSession.sharedInstance()
        
        do {
            try recordSession.setCategory(.playAndRecord, mode: .default)
            try recordSession.setActive(true)
            recordSession.requestRecordPermission() { [unowned self] allowed in
                
                if allowed {
                    
                    if let number = UserDefaults.standard.object(forKey: "myNumber") as? Int {
                        
                        self.numberOfRecords = number
                    }
                    
                } else {
                    AlertController.alert(message: "Запись невозможна, так как доступ к микрофону запрещен", target: self)
                }
            }
            
            if AVAudioSession.sharedInstance().recordPermission == .denied {
                AlertController.alert(message: "Необходим доступ к микрофону", target: self)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getDirectoryUrl() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    private func setupRecorder() {

        let recordingName = getDirectoryUrl().appendingPathComponent("Record_\(numberOfRecords).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
                
        do {

            audioRecorder = try AVAudioRecorder(url: recordingName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()

        } catch {
            
            finishAudioRecording(success: false)
            print(#line, #function, error.localizedDescription)
        }
    }
    
    private func finishAudioRecording(success: Bool) {
        
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            print("Recording finished successfully.")
        } else {
            AlertController.alert(message: "Что-то пошло не так", target: self)
        }
        
        recordButton.isEnabled = true
        recordButton.isHighlighted = false
    }
    
//    MARK: - @IBActions
    
    @IBAction func recordPressed(_ sender: UIButton) {
        
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
        }
        
        if audioRecorder == nil {
            
            numberOfRecords += 1
            setupRecorder()
            
            recordButton.isEnabled = false
            recordButton.isHighlighted = true
            
            stopButton.isEnabled = true
            stopButton.isHighlighted = false
            
            startTimer()
            audioRecorder.record()
        }
    }
    
    @IBAction func stopPressed(_ sender: UIButton) {
        
        stopButton.isEnabled = false
        stopButton.isHighlighted = true

        recordButton.isEnabled = true
        recordButton.isHighlighted = false

        recordingTimeLabel.text = "00:00"
        meterTimer.invalidate()
        
        if audioRecorder != nil {
            finishAudioRecording(success: true)
            
            UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            listRecordingsTableView.reloadData()
        }
    }

    
//    MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

        if !flag {
            finishAudioRecording(success: false)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        if !flag {
        recordButton.isEnabled = true
        stopButton.isEnabled = false
        }
    }
}

