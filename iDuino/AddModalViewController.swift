//
//  AddModalViewController.swift
//  iDuino
//
//  Created by Lee Danilek on 4/11/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

protocol AddModalProtocol {
    func cancelAdd()
    func addElement(program: ProgramElement?, remote: RemoteElement?)
}

enum AddType {
    case ProgramElement
    case RemoteElement
}

class AddModalViewController: UIViewController {
    
    var delegate: AddModalProtocol?
    
    var type: AddType = .RemoteElement
    var actionType: BluetoothRequest.Component = .LED
    
    
    var duration: Double = 1

    @IBOutlet var stepper: UIStepper?
    @IBOutlet var durationLabel: UILabel?
    @IBOutlet var nameTextField: UITextField?
    @IBOutlet var valueSegmentedControl: UISegmentedControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Action"
        durationLabel?.text = NSString(format: "Duration: %gs", self.duration) as String
        stepper?.hidden = type == .RemoteElement
        durationLabel?.hidden = type == .RemoteElement
        valueSegmentedControl?.hidden = type == .RemoteElement
        nameTextField?.becomeFirstResponder()
        

        // Do any additional setup after loading the view.
    }

    @IBAction func stepperChanged(sender: UIStepper) {
        self.duration = self.stepper!.value as Double
        durationLabel?.text = NSString(format: "Duration: %gs", self.duration) as String
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segmentedControllerChanged(sender: UISegmentedControl) {
        let type: BluetoothRequest.Component
        switch sender.selectedSegmentIndex {
        case 0:
            type = .LED
        case 1:
            type = .Servo
        case 2:
            type = .Sound
        default:
            type = .LED
        }
        self.actionType = type
        self.setSegments()
    }
    
    func setSegments() {
        var segments = ["Off", "On"]
        if self.actionType == .Sound {
            segments = ["High", "Low", "Off"]
        } else if self.actionType == .Servo {
            segments = ["Left", "Right"]
        }
        while self.valueSegmentedControl!.numberOfSegments > segments.count {
            self.valueSegmentedControl?.removeSegmentAtIndex(self.valueSegmentedControl!.numberOfSegments-1, animated: true)
        }
        for i in 0..<self.valueSegmentedControl!.numberOfSegments {
            self.valueSegmentedControl?.setTitle(segments[i], forSegmentAtIndex: i)
        }
        while self.valueSegmentedControl!.numberOfSegments < segments.count {
            self.valueSegmentedControl?.insertSegmentWithTitle(segments[self.valueSegmentedControl!.numberOfSegments], atIndex: self.valueSegmentedControl!.numberOfSegments, animated: true)
        }
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        self.nameTextField?.resignFirstResponder()
        self.delegate?.cancelAdd()
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        nameTextField?.resignFirstResponder()
        if nameTextField?.text == "" {
            var noNameAlert = UIAlertController(title: "No Name", message: "Please add the name of the action", preferredStyle: UIAlertControllerStyle.Alert)
            noNameAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(noNameAlert, animated: true, completion: nil)
        } else {
            if type == .RemoteElement {
                self.delegate?.addElement(nil, remote: (nameTextField!.text, self.actionType))
            } else {
                var title = self.valueSegmentedControl!.titleForSegmentAtIndex(self.valueSegmentedControl!.selectedSegmentIndex)!
                let value: BluetoothRequest.Value
                switch title {
                case "On":
                    value = .On
                case "Off":
                    value = .Off
                case "Left":
                    value = .TurnLeft
                case "Right":
                    value = .TurnRight
                case "High":
                    value = .HighSound
                case "Low":
                    value = .LowSound
                default:
                    value = .On
                }
                self.delegate?.addElement((nameTextField!.text, self.actionType, self.duration, value), remote: nil)
            }
        }
    }
    
    

    
    func textFieldShouldReturn (textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
