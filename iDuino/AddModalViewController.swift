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
    
    var actionType: Type = .LED
    
    var name: String = ""
    
    var duration: Double = 10

    @IBOutlet var stepper: UIStepper?
    @IBOutlet var durationLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if type == .RemoteElement {
            stepper?.hidden = true
            durationLabel?.hidden = true
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segmentedControllerChanged(sender: UISegmentedControl) {
        let type: Type
        switch sender.selectedSegmentIndex {
        case 0:
            type = .LED
        case 1:
            type = .DCMotor
        default:
            type = .LED
        }
        self.actionType = type
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        if type == .RemoteElement {
            self.delegate?.addElement(nil, remote: (name, self.actionType))
        } else {
            self.delegate?.addElement((name, self.actionType, self.duration, 0), remote: nil)
        }
    }

    @IBOutlet var nameTextField: UITextField?
    
    func textFieldShouldReturn (textField: UITextField) -> Bool {
        name = textField.text
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
