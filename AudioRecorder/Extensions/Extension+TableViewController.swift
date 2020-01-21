//
//  Extension+TableViewController.swift
//  AudioRecorder
//
//  Created by Артем on 18.01.2020.
//  Copyright © 2020 Артем. All rights reserved.
//

import UIKit
import AVFoundation

extension RecorderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let path = recordings[indexPath.row]
        
        audioPlayer = try? AVAudioPlayer(contentsOf: path)
        
        let duration = audioPlayer.duration
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]

        let fileDuration = formatter.string(from: duration)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = recordings[indexPath.row].lastPathComponent
        cell.detailTextLabel!.text = fileDuration

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let path = recordings[indexPath.row]
                
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 5
            audioPlayer.play()
        } catch {
            self.audioPlayer = nil
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let path = recordings[indexPath.row]
        
        if editingStyle == .delete {

            do {
                try? FileManager.default.removeItem(at: path)
                listRecordings()
                listRecordingsTableView.reloadData()
            }
        }
    }
}

