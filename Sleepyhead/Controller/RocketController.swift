//
//  ViewController.swift
//  Sleepyhead
//
//  Created by Jordan Hankins on 1/03/2017.
//  Copyright © 2017 Jordan Hankins. All rights reserved.
//

import UIKit
import AudioKit
import MediaPlayer
import AKPickerView
import Hero

class RocketController: UIViewController, MPMediaPickerControllerDelegate,
            AKPickerViewDelegate, AKPickerViewDataSource {

    @IBOutlet var pickerView: AKPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up pickerView
        initPickerView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transition" {
            if let moonController = segue.destination as? MoonController {
                // Pass the number of minutes to the moonController
                moonController.totalMinutes = self.pickerView.selectedItem
            }
        }
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
        
        //audioPlayer.convertSong(selectedSong: mediaItemCollection.items[0])
        //audioPlayer.playCurrentSong()
    }
    
    /*
     * An MPMediaPickerController method that is called when the user cancels.
     */
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion:nil)
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
        // print("You chose \(item) minutes.")
    }
}

