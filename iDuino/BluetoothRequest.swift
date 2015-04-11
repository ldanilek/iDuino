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
  
  
  // Variables shared between instances to show pin avaiability
  static var availableLED: [Pin]?
  static var availableServo: [Pin]?
  static var availableSound: [Pin]?
  
  func getDescription() -> String {
    let byteString = String(self.generateByteString(), radix: 2)
    
    var pinValue: String
    switch self.pin as BluetoothRequest.Pin{
    case .D0:
      pinValue = "D0"
    case .D1:
      pinValue = "D1"
    case .D2:
      pinValue = "D2"
    case .D3:
      pinValue = "D3"
    case .D6:
      pinValue = "D6"
    case .D7:
      pinValue = "D7"
    case .D8:
      pinValue = "D8"
    case .D9:
      pinValue = "D9"
    case .D10:
      pinValue = "D10"
    case .D11:
      pinValue = "D11"
    case .D12:
      pinValue = "D12"
    default:
      fatalError("Should be here yo")
      
    }
    
    return "Type: \(self.componentType.rawValue), Value: \(self.value.rawValue), at Pin: \(pinValue), \(byteString)"
  }
  
  deinit {
    let componentType = self.componentType
    let pin = self.pin
    
    puts("Destroying \(self.getDescription())")
    
    switch componentType as BluetoothRequest.Component {
    case .LED:
      BluetoothRequest.availableLED?.append(pin)
    case .Servo:
      BluetoothRequest.availableServo?.append(pin)
    case .Sound:
      BluetoothRequest.availableSound?.append(pin)
    default:
      fatalError("Deallocating strange pin")
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
    
    println("Pre-assign: \(availableLED!.count)")
    
    if selectFrom.count > 0 {
      request.pin = selectFrom.first
      
      //messy but what the hell
      switch (componentType) {
      case .LED:
        puts("Creating LED Request")
        availableLED = selectFrom.filter { $0.rawValue != request.pin.rawValue }
      case .Servo:
        puts("Creating Servo Request")
        availableServo = selectFrom.filter { $0.rawValue != request.pin.rawValue }
      case .Sound:
        puts("Creating Sound Request")
        availableSound = selectFrom.filter { $0.rawValue != request.pin.rawValue }
      default:
        fatalError("Invalid component for bluetooth request")
      }
      
      println("Post-assign: \(availableLED!.count)")
      
    } else {
      request.componentType = .None
      request.pin = .None
    }
    
    puts("Created \(request.getDescription())")
    return request
  }
  
  private class func setupAvailability() {
    availableLED = [.D0, .D1, .D2, .D3, .D6, .D7, .D8, .D9]
    availableServo = [.D10, .D11]
    availableSound = [.D12]
  }
  
  func generateByteString() -> UInt8 {
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
    
    byte = byte | value
    
    return byte
  }
  
  
  
}
