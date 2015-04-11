//
//  BluetoothRequest.swift
//  iDuino
//
//  Created by Leo Shimonaka on 4/11/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

class BluetoothRequest {
  
  enum Component: UInt8 {
    case LED
    case Servo
    case Sound
    case None
  }
  
  enum Pin: UInt8 {
    case D0 = 0
    case D1
    case D2
    case D3
    case D6
    case D7
    case D8
    case D9
    case D10
    case D11
    case D12
    case None
  }
  
  enum Value: UInt8 {
    case Off
    case On
    case TurnRight
    case TurnLeft
    case LowSound
    case HighSound
  }
  
  
  var componentType: Component!
  var value: Value!
  var pin: Pin!
  var byteString: UInt8!
  
  
  // Variables shared between instances to show pin avaiability
  static var availableLED: [Pin]?
  static var availableServo: [Pin]?
  static var availableSound: [Pin]?
  
  var description: String {
    get {
      return "Type: \(self.componentType), Value: \(self.value), at Pin: \(self.pin), \(self.byteString)"
    }
  }
  
  
  class func bluetoothRequestWithType(componentType: Component) -> BluetoothRequest {
    // Firsttime setup
    if availableLED == nil && availableServo == nil && availableSound == nil {
      setupAvailability()
    }
    
    
    var request = BluetoothRequest()
    request.componentType = componentType
    request.value = .Off
    
    
    var selectFrom: [Pin]
    //Assigns available pin, if possible
    switch (componentType) {
    case .LED:
      puts("Creating LED Request")
      selectFrom = availableLED!
    case .Servo:
      puts("Creating Servo Request")
      selectFrom = availableServo!
    case .Sound:
      puts("Creating Sound Request")
      selectFrom = availableSound!
    default:
      fatalError("Invalid component for bluetooth request")
    }
    
    if selectFrom.count > 0 {
      request.pin = selectFrom.first
      request.byteString = request.generateByteString()
    } else {
      request.componentType = .None
      request.pin = .None
    }
    
    return request
  }
  
  private class func setupAvailability() {
    availableLED = [.D0, .D1, .D2, .D3, .D6, .D7, .D8, .D9]
    availableServo = [.D10, .D11]
    availableSound = [.D12]
  }
  
  private func generateByteString() -> UInt8 {
    var byte: UInt8 = 0b00000000
    
    // Assign Pin
    byte = (byte | self.pin.rawValue) << 4
    
    // Assign Component
    byte = (byte | self.pin.rawValue) << 2
    
    // Assign Value
    var value: UInt8!
    switch (self.value!)  {
    case .Off:
      value = 0b00000000
    case .On:
      value = 0b00000001
    case .TurnRight:
      value = 0b00000001
    case .TurnLeft:
      value = 0b00000010
    case .LowSound:
      value = 0b00000001
    case .HighSound:
      value = 0b00000010
    default:
      fatalError("Invalid value")
    }
    
    return byte
  }
  
  
  
}
