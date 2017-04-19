//
//  ViewController.swift
//  Sleepyhead
//
//  Created by Jordan Hankins on 1/03/2017.
//  Copyright © 2017 Jordan Hankins. All rights reserved.
//

//  https://groups.google.com/forum/#!topic/audiokit/vYmmn9aU8Vo


import UIKit
import AudioKit
import MediaPlayer

class ViewController: UIViewController, MPMediaPickerControllerDelegate {
    @IBOutlet weak var reverbLabel: UILabel!
    
    var reverb : AKReverb2?
    var player : AKAudioPlayer?
    var lowPass : AKLowPassFilter?
    var highPass : AKHighPassFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Used to display the music selection through the MPMediaPickerControllerDelegate.
     
     - parameters:
        - sender: The UIButton that executed the action.
    */
    @IBAction func songSelect(_ sender: Any) {
        let picker = MPMediaPickerController.self(mediaTypes: MPMediaType.music)
        picker.allowsPickingMultipleItems = false
        picker.delegate = self
        picker.showsCloudItems = false
        self.present(picker, animated: true, completion: nil)
    }
    
    /**
     An MPMediaPickerController delegate method that is called once a user has selected an item.
    */
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        // remove the media picker screen
        self.dismiss(animated: true, completion:nil)
        
        convertSong(selectedSong: mediaItemCollection.items[0])
        //playSong(songURL: convertedSongURL!)
    }
    
    /*
     * An MPMediaPickerController method that is called when the user cancels.
     */
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion:nil)
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
        print("saving to \(exportedFileURL.absoluteString)")
        
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
        
        // Do the export. If the export succeeds then play the song
        exporter.exportAsynchronously(completionHandler: {
            if exporter.status == AVAssetExportSessionStatus.failed {
                print("Export failed \(exporter.error)")
            } else if exporter.status == AVAssetExportSessionStatus.cancelled {
                print("Export cancelled \(exporter.error)")
            } else if exporter.status == AVAssetExportSessionStatus.unknown {
                print("Export unknown \(exporter.error)")
            } else {
                print("Export complete")
                self.playSong(songURL: exportedFileURL as NSURL)
            }
        })
    }
    
    /**
     Plays the song from the URL to the m4a file.
     
     - parameters:
        - songURL: The URL to the MPMediaItem m4a file.
    */
    func playSong(songURL: NSURL) {
        print(songURL)
        do {
            let song = try AKAudioFile(forReading: songURL as URL)
            player = try AKAudioPlayer(file: song)
            
            highPass = AKHighPassFilter(player!)
            highPass!.cutoffFrequency = 0
            
            lowPass = AKLowPassFilter(highPass!)
            lowPass!.cutoffFrequency = 22050

            reverb = AKReverb2(lowPass!)
            reverb!.dryWetMix = 0.0
            reverb!.decayTimeAt0Hz = 8.0
            reverb!.decayTimeAtNyquist = 4.0
            
            AudioKit.output = reverb
            AudioKit.start()
            player!.play()
        } catch {
            print("Error reading the file")
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        reverb?.dryWetMix = Double(sender.value) * 1.0
        lowPass!.cutoffFrequency = 22050 - (22050 * pow(sender.value, 0.13))
        highPass!.cutoffFrequency = 5000 * pow(sender.value, 2)
        //player?.volume = 1.0 - Double(sender.value)
        reverbLabel.text = "Reverb: \(currentValue)"
    }
}

