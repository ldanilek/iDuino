//
//  BluetoothConstants.swift
//  iDuino
//
//  Created by Lee Danilek on 4/11/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import Foundation

func textForType(component: BluetoothRequest.Component) -> String
{
    switch component {
    case .LED:
        return "LED"
    case .Servo:
        return "Servo"
    case .Sound:
        return "Sound"
    default:
        return ""
    }
}

func imageNameForValue(val: BluetoothRequest.Value) -> String
{
    switch val {
    case .HighSound:
        return "music"
    case .LowSound:
        return "music-note"
    case .Off:
        return "lightbulb-off-7"
    case .On:
        return "lightbulb-7"
    case .TurnLeft:
        return "swipe-left"
    case .TurnRight:
        return "swipe-right"
    }
}