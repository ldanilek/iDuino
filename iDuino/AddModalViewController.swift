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
    
    
    var duration: Double = 3

    @IBOutlet var stepper: UIStepper?
    @IBOutlet var durationLabel: UILabel?
    @IBOutlet var nameTextField: UITextField?
    @IBOutlet var valueSegmentedControl: UISegmentedControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Action"
        durationLabel?.text = NSString(format: "Duration: %gs", self.duration) as String
        if type == .RemoteElement {
            stepper?.hidden = true
            durationLabel?.hidden = true
        }
        

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
        if sender == self.valueSegmentedControl! {
            let value: BluetoothRequest.Value
            switch sender.selectedSegmentIndex {
            case 0:
                value = .On
            case 1:
                value = .Off
            default:
                value = .Off
            }
            return
        }
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
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        self.delegate?.cancelAdd()
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        if nameTextField?.text == "" {
            var noNameAlert = UIAlertController(title: "No Name", message: "Please add the name of the action", preferredStyle: UIAlertControllerStyle.Alert)
            noNameAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(noNameAlert, animated: true, completion: nil)
        } else {
            if type == .RemoteElement {
                self.delegate?.addElement(nil, remote: (nameTextField!.text, self.actionType))
            } else {
                self.delegate?.addElement((nameTextField!.text, self.actionType, self.duration, 0), remote: nil)
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
