//
//  MoonController.swift
//  Sleepyhead
//
//  Created by Jordan Hankins on 21/04/2017.
//  Copyright © 2017 Jordan Hankins. All rights reserved.
//

import UIKit

class MoonController: UIViewController {
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var rocketButton: UIButton!
    
    var audioPlayer : AudioPlayer = AudioPlayer()
    var timer : CountdownTimer = CountdownTimer()
    var totalMinutes : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        // Called when the timer hits 0
        timer.completionHandler = {self.timerComplete()}
        
        // Called everytime the timer ticks
        timer.tickHandler = {self.timerUpdate()}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start the timer once the animation is complete
        timer.start(seconds: totalMinutes * 60)
    }
    
    // Used to programatically setup the UI before the view is seen
    private func uiSetup() {
        // Set initial time labels
        let minutes = Int(totalMinutes)
        let seconds = "00"
        
        // Update the time labels
        secondsLabel.text = "\(seconds)"
        minutesLabel.text = "\(minutes)"
        
        // Rotate rocket
        rocketButton.transform = rocketButton.transform.rotated(by: CGFloat(M_PI_2))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer.reset()
    }
    
    // Handles the tap of the rocket
    @IBAction func rocketTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downArrowTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Timer Callback Functions
    // This function is called for everytime increment to update the time label, verb,
    func timerUpdate(){
        // Update the verbed out volume
        let percentage = Float(timer.currentSeconds!) / Float(timer.initialSeconds!)
        audioPlayer.verbedOutLevel = 1.0 - percentage
        
        let minutes = Int(timer.currentSeconds! / 60)
        let seconds = Int(timer.currentSeconds! % 60)
        
        // Update the time labels
        secondsLabel.text = "\(seconds)"
        minutesLabel.text = "\(minutes)"
        
        //print("Seconds: \(timer.currentSeconds!), Verb: \(audioPlayer.verbedOutLevel)")
    }
    
    // This function is called once the timer has finished
    func timerComplete(){
        //print("Timer complete!")
    }
}
