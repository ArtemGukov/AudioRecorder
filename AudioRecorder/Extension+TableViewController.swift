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
        
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let path = getDirectoryUrl().appendingPathComponent("Record_\(indexPath.row + 1).m4a")
        
        audioPlayer = try? AVAudioPlayer(contentsOf: path)
        
        let fileName = URL(fileURLWithPath: path.absoluteString).deletingPathExtension().lastPathComponent
        
        let duration = audioPlayer.duration
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]

        let fileDuration = formatter.string(from: duration)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = fileName
        cell.detailTextLabel!.text = fileDuration

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let path = getDirectoryUrl().appendingPathComponent("Record_\(indexPath.row + 1).m4a")
        print(path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: path)
                audioPlayer.play()
        } catch {
            AlertController.alert(message: "Невозможно воспроизвести данный файл", target: self)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let path = getDirectoryUrl().appendingPathComponent("Recording_\(indexPath.row + 1).m4a")
        
        if editingStyle == .delete {

            do {
                try? FileManager.default.removeItem(at: path)
                numberOfRecords -= 1
                tableView.deleteRows(at: [indexPath], with: .automatic)
                UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
            } catch {
                AlertController.alert(message: "Невозможно удалить данный файл", target: self)
            }
        }
    }
}

