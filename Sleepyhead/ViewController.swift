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
import AKPickerView

class ViewController: UIViewController, MPMediaPickerControllerDelegate,
            AKPickerViewDelegate, AKPickerViewDataSource {
    //
    @IBOutlet weak var reverbLabel: UILabel!
    @IBOutlet weak var reverbSlider: UISlider!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet var pickerView: AKPickerView!
    
    var audioPlayer : AudioPlayer = AudioPlayer()
    var timer : CountdownTimer = CountdownTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up pickerView
        initPickerView()
        
        // Called when the timer hits 0
        timer.completionHandler = {self.complete()}
        
        // Called everytime the timer ticks
        timer.tickHandler = {self.update()}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     Performs setup of the picker view
    */
    private func initPickerView() {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pickerView.font = UIFont(name: "helsinki", size: 70)!
        self.pickerView.highlightedFont = UIFont(name: "helsinki", size: 70)!
        self.pickerView.textColor = UIColor(white: 1.0, alpha: 0.3)
        self.pickerView.highlightedTextColor = .white
        self.pickerView.interitemSpacing = 20.0
        self.pickerView.pickerViewStyle = .wheel
        self.pickerView.maskDisabled = false
        self.pickerView.reloadData()
    }
    
    @IBAction func start(_ sender: Any) {
        // Start the timer for the number of seconds
        timer.start(seconds: self.pickerView.selectedItem * 60)
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
    
    // This function is called for everytime increment to update the time label, verb,
    func update(){
        // Update the verbed out volume
        let percentage = Float(timer.currentSeconds!) / Float(timer.initialSeconds!)
        audioPlayer.verbedOutLevel = 1.0 - percentage
        
        let minutes = Int(timer.currentSeconds!/60)
        let seconds = Int(timer.currentSeconds! % 60)
        // Update the time label
        secondsLabel.text = "m: \(minutes) s: \(seconds)"
        
        // Update Reverb Label
        reverbLabel.text = "Reverb: \(audioPlayer.verbedOutLevel)"
        
        // Update the reverb slider
        reverbSlider.value = audioPlayer.verbedOutLevel
        
        print("Seconds: \(timer.currentSeconds!), Verb: \(audioPlayer.verbedOutLevel)")
    }
    
    // This function is called once the timer has finished
    func complete(){
        
        print("Timer complete!")
    }
    
    // MARK: - AKPickerViewDataSource
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return 60
    }
    
    // Returns the item for each
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        return "\(item)"
    }
    
    // MARK: - AKPickerViewDelegate
    // Returns the selected item
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
        print("You chose \(item) minutes.")
    }
}

