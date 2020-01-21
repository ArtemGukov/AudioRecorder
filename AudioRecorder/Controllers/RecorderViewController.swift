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
    
    var recordings = [URL]()
    
    var meterTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        listRecordings()
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
    }
    
    private func checkPermission() {
        
        recordSession = AVAudioSession.sharedInstance()
        
        do {
            try recordSession.setCategory(.playAndRecord, mode: .default)
            try recordSession.setActive(true)
            recordSession.requestRecordPermission() { [unowned self] allowed in
                
                if allowed {
                    
                    print("Доступ получен")

                } else {
                    
                    DispatchQueue.main.async {
                        self.recordButton.isEnabled = false
                        self.recordButton.backgroundColor = .darkGray
                        
                        self.stopButton.isEnabled = false
                        
                        self.recordingTimeLabel.text = "Нет доступа"
                    }
                }
            }
            
            if AVAudioSession.sharedInstance().recordPermission == .denied {

                print("Нет доступа")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func getDirectoryUrl() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    func listRecordings() {
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(at:
                getDirectoryUrl(), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            self.recordings = urls.filter({ (name: URL) -> Bool in
                return name.pathExtension == "m4a"
            }).sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
                        
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setupRecorder() {

        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        
        let recordingName = getDirectoryUrl().appendingPathComponent("Recording_\(format.string(from: Date())).m4a")
                
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
            print("Успешная запись :)")
        } else {
            print("Что-то пошло не так :(")
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

            listRecordings()
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

