//
//  AudioPlayer.swift
//  Sleepyhead
//
//  Created by Jordan Hankins on 20/04/2017.
//  Copyright © 2017 Jordan Hankins. All rights reserved.
//

import MediaPlayer
import AudioKit

class AudioPlayer {
    // The path to the currentSong
    var currentSong : URL?
    // The AudioKit player instance
    var player : AKAudioPlayer?
    // The reverb instance
    var reverb : AKReverb2?
    // The low pass filter instance
    var lowPass : AKLowPassFilter?
    // The high pass filter instance
    var highPass : AKHighPassFilter?
    
    // The amount that the song is 'verbed out'
    var verbedOutLevel : Float {
        didSet (newValue) {
            reverb!.dryWetMix = Double(newValue) * 1.0
            lowPass!.cutoffFrequency = 22050 - (22050 * pow(newValue, 0.13))
            highPass!.cutoffFrequency = 5000 * pow(newValue, 2)
        }
    }
    
    init() {
        currentSong = nil
        // setup the audio chain -> player is nil
        highPass = AKHighPassFilter(player)
        lowPass = AKLowPassFilter(highPass)
        reverb = AKReverb2(lowPass)
        verbedOutLevel = 0.0
    }
    
    // Plays the current song from the URL
    func playCurrentSong() {
        playSong(songURL: currentSong!)
    }
    
    /**
     Plays the song from the URL to the m4a file.
     
     - parameters:
     - songURL: The URL to the MPMediaItem m4a file.
     */
    func playSong(songURL: URL) {
        print(songURL)
        do {
            let song = try AKAudioFile(forReading: songURL)
            player = try AKAudioPlayer(file: song)
            
            reverb!.decayTimeAt0Hz = 8.0
            reverb!.decayTimeAtNyquist = 4.0
            verbedOutLevel = 0.0
            
            AudioKit.output = reverb
            AudioKit.start()
            player!.play()
        } catch {
            print("Error reading the file")
        }
    }
    
    /**
     This method converts an MPMediaItem into a WAV that is stored on the device, to be able to process and play. It then
     provides an NSURL to the WAV on the device.
     
     - parameters:
     - selectedSong: The MPMediaItem that the user selected through the MPMediaPickerController.
     
     - returns: The NSURL of the converted and exported song on the device.
     */
    func convertSong(selectedSong: MPMediaItem) {
        // Set up the export
        let filename = "exported.m4a"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportedFileURL = documentsDirectory.appendingPathComponent(filename)
        
        // Delete existing exported song, i.e. from previous app boot
        let filemanager = FileManager.default
        do {
            try filemanager.removeItem(at: exportedFileURL)
            print("Existing file deleted")
        } catch {
            print("No file to delete")
        }
        
        // Set up the export
        let url = selectedSong.value(forProperty: MPMediaItemPropertyAssetURL) as! NSURL
        let songAsset = AVAsset(url: url as URL)
        
        // Export as a .m4a file preset
        let exporter = AVAssetExportSession(asset: songAsset, presetName: AVAssetExportPresetAppleM4A)!
        exporter.outputFileType = AVFileTypeAppleM4A
        exporter.outputURL = exportedFileURL
        
        // Set the length of the export to be the length of the song
        let duration = CMTimeGetSeconds(songAsset.duration)
        let endTime = Int64(duration)
        let startTime = CMTimeMake(0, 1)
        let stopTime = CMTimeMake(endTime, 1)
        let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
        exporter.timeRange = exportTimeRange
        
        exportSong(exporter: exporter)
    }
    
    // Do the export. If the export succeeds then set the current song
    func exportSong(exporter: AVAssetExportSession) {
        exporter.exportAsynchronously(completionHandler: {
            if exporter.status == AVAssetExportSessionStatus.failed {
                print("Export failed \(exporter.error)")
            } else if exporter.status == AVAssetExportSessionStatus.cancelled {
                print("Export cancelled \(exporter.error)")
            } else if exporter.status == AVAssetExportSessionStatus.unknown {
                print("Export unknown \(exporter.error)")
            } else {
                print("Export complete")
                self.currentSong = exporter.outputURL!
            }
        })
    }
}
