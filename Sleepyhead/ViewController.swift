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
    var audioPlayer : AudioPlayer = AudioPlayer()
    var timer : CountdownTimer = CountdownTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Called when the timer hits 0
        timer.completionHandler = {
            () -> Void in
            print("Timer complete!")
        }
        
        // Called everytime the timer ticks
        timer.tickHandler = {
            () -> Void in
            // Update the time label
            
            // Update the verbed out volume
            let percentage : Float = Float(self.timer.currentSeconds!) / Float(self.timer.initialSeconds!)
            self.audioPlayer.verbedOutLevel = 1.0 - percentage
            
            print("Seconds: \(self.timer.currentSeconds!), Verb: \(percentage)")
        }
        
        timer.start(seconds: 20)
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
        audioPlayer.convertSong(selectedSong: mediaItemCollection.items[0])
        audioPlayer.playCurrentSong()
    }
    
    /*
     * An MPMediaPickerController method that is called when the user cancels.
     */
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion:nil)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        audioPlayer.verbedOutLevel = sender.value
        reverbLabel.text = "Reverb: \(sender.value)"
    }
}

