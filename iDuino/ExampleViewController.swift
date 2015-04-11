//
//  ExampleViewController.swift
//  iDuino
//
//  Created by Leo Shimonaka on 4/11/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

class ExampleViewController: UIViewController {
    
    
    var timerTXDelay: NSTimer?
    var allowTX = true
    var currentInstruction: UInt8 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Watch Bluetooth connection
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"), name: BLEServiceChangedStatusNotification, object: nil)
        
        // Start the Bluetooth discovery process
        btDiscoverySharedInstance
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BLEServiceChangedStatusNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stopTimerTXDelay()
    }
    
    @IBAction func someButtonPressed(sender: UISlider) {
        // Call sendByteString with new instruction here!
    }
    
    func sendByteString(byteString: UInt8) {
        // Valid position range: 0 to 180
        
        if !self.allowTX {
            return
        }
        
        // Is the instruction already running?
        if byteString == currentInstruction {
            return
        }
        
        
        // Send position to BLE Shield (if service exists and is connected)
        if let bleService = btDiscoverySharedInstance.bleService {
            bleService.writePosition(byteString)
            currentInstruction = byteString;
            
            // Start delay timer
            self.allowTX = false
            if timerTXDelay == nil {
                timerTXDelay = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("timerTXDelayElapsed"), userInfo: nil, repeats: false)
            }
        }
    }
    
    func timerTXDelayElapsed() {
        self.allowTX = true
        self.stopTimerTXDelay()
        self.sendByteString(currentInstruction)
    }
    
    func stopTimerTXDelay() {
        if self.timerTXDelay == nil {
            return
        }
        
        timerTXDelay?.invalidate()
        self.timerTXDelay = nil
    }
    
}

