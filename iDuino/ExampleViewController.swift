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
    
    // Start the Bluetooth discovery process
    btDiscoverySharedInstance
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  @IBAction func onButtonPressed(sender: AnyObject) {
    
    var request = BluetoothRequest.bluetoothRequestWithType(.Servo)
    
    //said component does not exist
    if request.componentType == .None {
      // out of assignable pins, act accordingly
    }
    
    
    request.value = .On
    
    sendByteString(request.generateByteString())
    
  }

  @IBAction func offButtonPressed(sender: AnyObject) {
    
    var request = BluetoothRequest.bluetoothRequestWithType(.Servo)
    
    //said component does not exist
    if request.componentType == .None {
      // out of assignable pins, act accordingly
    }
    
    
    request.value = .Off
    
    sendByteString(request.generateByteString())
    
    
  }
  
  
  @IBAction func someButtonPressed(sender: UISlider) {
    // Call sendByteString with new instruction here!
    

    var request = BluetoothRequest.bluetoothRequestWithType(.Servo)
    
    //said component does not exist
    if request.componentType == .None {
      // out of assignable pins, act accordingly
    }
    
    
    // Give Request Appropriate Value
    // e.g. request.value = .On
    
    sendByteString(request.generateByteString())
  }
  
  func sendByteString(byteString: UInt8) {
    
    // Is the instruction already running?
    if byteString == currentInstruction {
      return
    }
    
    @IBAction func someButtonPressed(sender: UISlider) {
        // Call sendByteString with new instruction here!
    }
    
    // Send bytes5tring to BLE Shield (if service exists and is connected)
    if let bleService = btDiscoverySharedInstance.bleService {
      bleService.writePosition(byteString)
      currentInstruction = byteString;
      
    }
  }
  
}

