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
  }
  
  @IBAction func someButtonPressed(sender: UISlider) {
    // Call sendByteString with new instruction here!
  }
  
  func sendByteString(byteString: UInt8) {
    
    // Is the instruction already running?
    if byteString == currentInstruction {
      return
    }
    
    
    // Send bytes5tring to BLE Shield (if service exists and is connected)
    if let bleService = btDiscoverySharedInstance.bleService {
      bleService.writePosition(byteString)
      currentInstruction = byteString;
      
    }
  }
  
}

