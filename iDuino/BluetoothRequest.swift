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
    case LED = 0b00000000
    case Servo = 0b00000001
    case Sound = 0b00000010
    case None = 0b00000011
  }
  
  enum Pin: UInt8 {
    case D0 = 0b00000000
    case D1 = 0b00000001
    case D2 = 0b00000010
    case D3 = 0b00000011
    case D6 = 0b00000100
    case D7 = 0b00000101
    case D8 = 0b00000110
    case D9 = 0b00000111
    case D10 = 0b00001000
    case D11 = 0b00001001
    case D12 = 0b00001010
    case None = 0b00001111
  }
  
  enum Value: UInt8 {
    case Off
    case On
    case TurnRight
    case TurnLeft
    case LowSound
    case HighSound
  }

  
  var componentType: Component = .None
  var value: Value = .Off
  var pin: Pin = .None
  
  
  // Variables shared between instances to show pin avaiability
  static var availableLED: [Pin]?
  static var availableServo: [Pin]?
  static var availableSound: [Pin]?
  static let allLED: [Pin] = [.D0, .D1, .D2, .D3, .D6, .D7, .D8, .D9]
  static let allServo: [Pin] = [.D10, .D11]
  static let allSound: [Pin] = [.D12]
  
  func getDescription() -> String {
    let byteString = String(self.generateByteString(), radix: 2)
    
    var pinValue: String
    switch self.pin as BluetoothRequest.Pin {
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
    case .None:
      pinValue = "Unassigned"
    default:
      fatalError("Should be here yo")
      
    }
    
    return "Type: \(self.componentType.rawValue), Value: \(self.value.rawValue), at Pin: \(pinValue), \(byteString)"
  }
  
  class func stringForPin(pin: Pin) -> String {
    var pinValue: String
    switch pin as BluetoothRequest.Pin {
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
    case .None:
      pinValue = "Unassigned"
    default:
      fatalError("Should be here yo")
    }
    
    return pinValue
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
    case .None:
      break;
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
    request.pin = .None
    
    
    var selectFrom: [Pin]
    //Assigns available pin, if possible
    switch (componentType) {
    case .LED:
      selectFrom = availableLED!
    case .Servo:
      selectFrom = availableServo!
    case .Sound:
      selectFrom = availableSound!
    default:
      fatalError("Invalid component for bluetooth request")
    }
    
    
    if selectFrom.count > 0 {
      request.pin = selectFrom.first!
      
      //messy but what the hell
      switch (componentType) {
      case .LED:
        availableLED = selectFrom.filter { $0.rawValue != request.pin.rawValue }
      case .Servo:
        availableServo = selectFrom.filter { $0.rawValue != request.pin.rawValue }
      case .Sound:
        availableSound = selectFrom.filter { $0.rawValue != request.pin.rawValue }
      default:
        fatalError("Invalid component for bluetooth request")
      }
      
    
      
    } else {
      request.pin = .None
    }
    
    puts("Created \(request.getDescription())")
    return request
  }
  
  private class func setupAvailability() {
    availableLED = BluetoothRequest.allLED
    availableServo = BluetoothRequest.allServo
    availableSound = BluetoothRequest.allSound
  }
  
  func generateByteString() -> UInt8 {
    var byte: UInt8 = 0b00000000
    
    // Assign Pin
    byte = (byte | self.pin.rawValue)
    
    // Assign Component
//    puts("After assign pin \(String(byte, radix: 2))")
    byte = ((byte << 2) | self.componentType.rawValue)
//    puts("After assign \(String(byte, radix: 2))")
    
    // Assign Value
    var value: UInt8!
    switch (self.value)  {
    case .Off:
      value = 0b00000000
    case .On:
      value = 0b00000001
    case .TurnRight:
      value = 0b00000010
    case .TurnLeft:
      value = 0b00000001
    case .LowSound:
      value = 0b00000001
    case .HighSound:
      value = 0b00000010
    default:
      fatalError("Invalid value")
    }
    
    byte = ((byte << 2) | value)
    
    return byte
  }
  
  
  
}
