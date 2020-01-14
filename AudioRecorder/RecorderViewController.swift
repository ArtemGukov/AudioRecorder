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
    
    @IBOutlet var recordingTimeLabel: UILabel!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var playButton: UIButton!


    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

