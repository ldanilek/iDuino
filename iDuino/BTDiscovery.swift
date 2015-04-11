//
//  BTDiscovery.swift
//  iDuino
//
//  Created by Leo Shimonaka on 4/11/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit


import Foundation
import CoreBluetooth

let btDiscoverySharedInstance = BTDiscovery();

class BTDiscovery: NSObject, CBCentralManagerDelegate {
  
  private var centralManager: CBCentralManager?
  private var peripheralBLE: CBPeripheral?
  
  override init() {
    self.centralManager = nil
    
    super.init()
    
    let centralQueue = dispatch_queue_create("com.raywenderlich", DISPATCH_QUEUE_SERIAL)
    centralManager = CBCentralManager(delegate: self, queue: centralQueue)
  }
  
  func startScanning() {
    if let central = centralManager {
      central.scanForPeripheralsWithServices([BLEServiceUUID], options: nil)
    }
  }
  
  var bleService: BTService? {
    didSet {
      if let service = self.bleService {
        service.startDiscoveringServices()
      }
    }
  }
  
  // MARK: - CBCentralManagerDelegate
  
  func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
    
    // validate
    if ((peripheral == nil) || (peripheral.name == nil) || (peripheral.name == "")) {
      return
    }
    
    if ((self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.Disconnected)) {
      self.peripheralBLE = peripheral
      
      // Reset service
      self.bleService = nil
      central.connectPeripheral(peripheral, options: nil)
    }
  }
  
  func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
    
    if (peripheral == nil) {
      return;
    }
    
    if (peripheral == self.peripheralBLE) {
      self.bleService = BTService(initWithPeripheral: peripheral)
    }
    
    central.stopScan()
  }
  
  func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
    
    if (peripheral == nil) {
      return;
    }
    
    if (peripheral == self.peripheralBLE) {
      self.bleService = nil;
      self.peripheralBLE = nil;
    }
    
    self.startScanning()
  }
  
  // MARK: - Private
  
  func clearDevices() {
    self.bleService = nil
    self.peripheralBLE = nil
  }
  
  func centralManagerDidUpdateState(central: CBCentralManager!) {
    switch (central.state) {
    case CBCentralManagerState.PoweredOff:
      self.clearDevices()
      
    case CBCentralManagerState.Unauthorized:
      // Todo: get bluetooth bru
      break
      
    case CBCentralManagerState.Unknown:
      //wait
      break
      
    case CBCentralManagerState.PoweredOn:
      self.startScanning()
      
    case CBCentralManagerState.Resetting:
      self.clearDevices()
      
    case CBCentralManagerState.Unsupported:
      break
      
    default:
      break
    }
  }
  
  
  
}

