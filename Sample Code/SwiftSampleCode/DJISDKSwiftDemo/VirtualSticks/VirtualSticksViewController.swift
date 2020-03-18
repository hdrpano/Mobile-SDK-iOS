//
//  VirtualSticksViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Dennis Baldwin on 3/18/20.
//  Copyright © 2020 DroneBlocks, LLC. All rights reserved.
//

import UIKit
import DJISDK

class VirtualSticksViewController: UIViewController {
    
    var flightController: DJIFlightController?
    var timer: Timer?
    
    var radians: Float = 0.0
    let velocity: Float = 0.1
    var x: Float = 0.0
    var y: Float = 0.0
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Grab a reference to the aircraft
        if let aircraft = DJISDKManager.product() as? DJIAircraft {
            
            // Grab a reference to the flight controller
            if let fc = aircraft.flightController {
                
                //fc.rollPitchControlMode = DJIVirtualStickRollPitchControlMode.velocity
                
                // Store the flightController
                self.flightController = fc
                
                print("We have a reference to the FC")
            }
            
        }
    }
    
    // User clicks the enter virtual sticks button
    @IBAction func enableVirtualSticks(_ sender: Any) {
        toggleVirtualSticks(enabled: true)
        
    }
    
    // User clicks the exit virtual sticks button
    @IBAction func disableVirtualSticks(_ sender: Any) {
        toggleVirtualSticks(enabled: false)
    }
    
    // Handles enabling/disabling the virtual sticks
    private func toggleVirtualSticks(enabled: Bool) {
            
        // Let's set the VS mode
        self.flightController?.setVirtualStickModeEnabled(enabled, withCompletion: { (error: Error?) in
            
            // If there's an error let's stop
            guard error == nil else { return }
            
            // Set control modes
            self.flightController?.rollPitchControlMode = DJIVirtualStickRollPitchControlMode.velocity
            self.flightController?.rollPitchCoordinateSystem = DJIVirtualStickFlightCoordinateSystem.ground
            self.flightController?.yawControlMode = DJIVirtualStickYawControlMode.angularVelocity
            
            print("Are virtual sticks enabled? \(enabled)")
            
        })
        
    }
    
    
    // Trigger the roll timer
    @IBAction func rollLeftRight(_ sender: Any) {
        x = 0.0
        radians = 0.0
        
        if timer != nil {
            print("invalidating")
            timer?.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(rollTimer), userInfo: nil, repeats: true)
    }
    
    // Begin the roll timer
    // Positive value rolls right, negative value rolls left
    @objc func rollTimer() {
        radians += velocity
        x = cos(radians)
        
        print(radians, ":", x)
        
        // Construct the flight control data object
        var controlData = DJIVirtualStickFlightControlData()
        controlData.verticalThrottle = 0
        controlData.pitch = 0
        controlData.roll = x // Roll only
        controlData.yaw = 0
        
        // Send the control data to the FC
        self.flightController?.send(controlData, withCompletion: { (error: Error?) in
            
            // There's an error so let's stop
            if error != nil {
                print("Error sending data")
                
                // Disable the timer
                self.timer?.invalidate()
            }
            
        })
    }
    
    @IBAction func pitchForwardBack(_ sender: Any) {
        radians = 0.0
        y = 0.0
        
        if timer != nil {
            print("invalidating")
            timer?.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(pitchTimer), userInfo: nil, repeats: true)
    }
    
    // Begin the pitch timer
    // Positive value rolls forward, negative value rolls backward
    @objc func pitchTimer() {
        radians += velocity
        y = sin(radians)
        
        print(radians, ":", y)
        
        // Construct the flight control data object
        var controlData = DJIVirtualStickFlightControlData()
        controlData.verticalThrottle = 0
        controlData.pitch = y // Pitch only
        controlData.roll = 0
        controlData.yaw = 0
        
        // Send the control data to the FC
        self.flightController?.send(controlData, withCompletion: { (error: Error?) in
            
            // There's an error so let's stop
            if error != nil {
                print("Error sending data")
                
                // Disable the timer
                self.timer?.invalidate()
            }
            
        })
    }
    
    
    

}
