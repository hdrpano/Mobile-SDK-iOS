//  VirtualSticksViewController.swift
//  Created by Dennis Baldwin on 3/18/20.
//  Copyright © 2020 DroneBlocks, LLC. All rights reserved.
//
//  Make sure you know what you're doing before running this code. This code makes use of the Virtual Sticks API.
//  This code has only been tested on DJI Spark, but should work on other DJI platforms. I recommend doing this outdoors to get familiar with the
//  functionality. It can certainly be run indoors since Virtual Sticks do not make use of GPS. Please make sure your flight mode switch is in
//  the default position. If any point you need to take control the switch can be toggled out of the default position so you have manual control
//  again. Virtual Sticks DOES NOT allow you to add any manual input to the flight controller when this mode is enabled. Good luck and I hope
//  to experiment with other flight paths soon.

import UIKit
import DJISDK

enum FLIGHT_MODE {
    case ROLL_LEFT_RIGHT
    case PITCH_FORWARD_BACK
    case THROTTLE_UP_DOWN
    case HORIZONTAL_ORBIT
    case VERTICAL_ORBIT
    case VERTICAL_SINE_WAVE
    case HORIZONTAL_SINE_WAVE
}

class VirtualSticksViewController: UIViewController {
    
    var flightController: DJIFlightController?
    var timer: Timer?
    
    var radians: Float = 0.0
    let velocity: Float = 0.1
    var x: Float = 0.0
    var y: Float = 0.0
    var z: Float = 0.0
    
    var flightMode: FLIGHT_MODE?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Grab a reference to the aircraft
        if let aircraft = DJISDKManager.product() as? DJIAircraft {
            
            // Grab a reference to the flight controller
            if let fc = aircraft.flightController {
                
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
    
    @IBAction func rollLeftRight(_ sender: Any) {
        setupFlightMode()
        flightMode = FLIGHT_MODE.ROLL_LEFT_RIGHT
        
        // Schedule the timer at 20Hz while the default specified for DJI is between 5 and 25Hz
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
    }
    
    @IBAction func pitchForwardBack(_ sender: Any) {
        setupFlightMode()
        flightMode = FLIGHT_MODE.PITCH_FORWARD_BACK
        
        // Schedule the timer at 20Hz while the default specified for DJI is between 5 and 25Hz
        // Note: changing the frequency will have an impact on the distance flown so BE CAREFUL
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
    }
    
    @IBAction func throttleUpDown(_ sender: Any) {
        setupFlightMode()
        flightMode = FLIGHT_MODE.THROTTLE_UP_DOWN
        
        // Schedule the timer at 20Hz while the default specified for DJI is between 5 and 25Hz
        // Note: changing the frequency will have an impact on the distance flown so BE CAREFUL
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
    }
    
    @IBAction func horizontalOrbit(_ sender: Any) {
        setupFlightMode()
        flightMode = FLIGHT_MODE.HORIZONTAL_ORBIT
        
        // Schedule the timer at 20Hz while the default specified for DJI is between 5 and 25Hz
        // Note: changing the frequency will have an impact on the distance flown so BE CAREFUL
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
    }
    
    @IBAction func verticalOrbit(_ sender: Any) {
        setupFlightMode()
        flightMode = FLIGHT_MODE.VERTICAL_ORBIT
        
        // Schedule the timer at 20Hz while the default specified for DJI is between 5 and 25Hz
        // Note: changing the frequency will have an impact on the distance flown so BE CAREFUL
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerLoop), userInfo: nil, repeats: true)
    }
    
    // Timer loop to send values to the flight controller
    @objc func timerLoop() {
        
        // Add velocity to radians before we do any calculation
        radians += velocity
        
        // Determine the flight mode so we can set the proper values
        switch flightMode {
        case .ROLL_LEFT_RIGHT:
            x = cos(radians)
            y = 0
            z = 0
        case .PITCH_FORWARD_BACK:
            x = 0
            y = sin(radians)
            z = 0
        case .THROTTLE_UP_DOWN:
            x = 0
            y = 0
            z = sin(radians)
        case .HORIZONTAL_ORBIT:
            x = cos(radians)
            y = sin(radians)
            z = 0
        case .VERTICAL_ORBIT:
            x = cos(radians)
            y = 0
            z = sin(radians)
        case .VERTICAL_SINE_WAVE:
            break
        case .HORIZONTAL_SINE_WAVE:
            break
        case .none:
            break
        }
        
        print("Sending x: \(x), y: \(y), z: \(z)")
        
        // Construct the flight control data object
        var controlData = DJIVirtualStickFlightControlData()
        controlData.verticalThrottle = z
        controlData.roll = x
        controlData.pitch = y
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
    
    // Called before any new flight mode is initiated
    private func setupFlightMode() {
        
        // Reset radians
        radians = 0.0
        
        // Invalidate timer if necessary
        // This allows switching between flight modes
        if timer != nil {
            print("invalidating")
            timer?.invalidate()
        }
    }
    
    

}
