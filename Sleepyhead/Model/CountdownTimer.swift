//
//  Timer.swift
//  Sleepyhead
//
//  Created by Jordan Hankins on 20/04/2017.
//  Copyright © 2017 Jordan Hankins. All rights reserved.
//

import Foundation

class CountdownTimer {
    // The initial amount of seconds set
    var initialSeconds : Int?
    
    // The current point of seconds
    var currentSeconds : Int?
    
    // The paused
    var isPaused = false
    
    // The callback once the counter has reached 0
    var completionHandler : (() -> Void)?
    // The callback when the
    var tickHandler : (() -> Void)?
    
    // Timer variable
    var timer : Timer
    
    init() {
        timer = Timer()
    }
    
    // Starts the timer at an amount of seconds
    func start(seconds: Int){
        initialSeconds = seconds
        currentSeconds = seconds
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.tick), userInfo: nil, repeats: true)
    }
    
    // Pause for
    func pause() {
        isPaused = !isPaused
    }
    
    // Reset the timer
    func reset() {
        timer.invalidate()
        currentSeconds = initialSeconds
    }
    
    @objc func tick() {
        currentSeconds! -= 1
        if (currentSeconds! <= 0) {
            // Callback the completion function
            if let completionCallback = self.completionHandler {
                completionCallback()
            }
            timer.invalidate()
        } else {
            // Callback the tick function
            if let tickCallback = self.tickHandler {
                tickCallback()
            }
        }
    }
}
