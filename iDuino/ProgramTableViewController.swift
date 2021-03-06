//
//  ProgramTableViewController.swift
//  iDuino
//
//  Created by Lee Danilek on 4/11/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

typealias ProgramElement = (name: String, type: BluetoothRequest.Component, duration: Double, action: BluetoothRequest.Value)
typealias InternalProgramElement = (name: String, duration: Double, request: BluetoothRequest)

enum ProgramState {
    case Playing
    case Stopped
}

func pad(string : String, toSize: Int) -> String {
    var padded = string
    for i in 0..<toSize - count(string) {
        padded = "0" + padded
    }
    return padded
}

class ProgramTableViewController: UITableViewController, AddModalProtocol {
    
    var program: [InternalProgramElement] = []
    var state: ProgramState = .Stopped
    
    var currentInstruction: UInt8 = 0
    
    var programCounter: Int = 0
    
    var timer: NSTimer?
    
    var doesRepeat: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addButtonPressed")
        self.setPlayButtonForState()
        self.title = "Program"
      
        self.tableView.rowHeight = 100
        btDiscoverySharedInstance
    }
    
    func play(button: UIBarButtonItem)
    {
        switch state {
        case .Stopped:
            self.state = .Playing
            self.programCounter = 0
            self.playNext()
        case .Playing:
            self.state = .Stopped
            self.stop()
        default:
            self.state = .Playing
        }
        self.setPlayButtonForState()
    }
    
    func excecuteAction(action: BluetoothRequest) {
        sendByteString(action.generateByteString())
    }
    
    func updateCell(path:Int){
        if path < 0 || path >= self.program.count {
            return
        }
        let indexPath = NSIndexPath(forRow: path, inSection: 0)
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic) //try other animations
        tableView.endUpdates()
    }
    
    func sendByteString(byteString: UInt8) {
        println("Sending byte string: \(pad(String(byteString, radix: 2), 8))")
        
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
    
    func playNext() {
        updateCell(self.programCounter-1);
        updateCell(self.programCounter);
        if self.programCounter >= self.program.count {
            if self.doesRepeat {
                self.programCounter = 0
                self.state = .Playing
                playNext()
                return
            }else {
                self.programCounter = 0
                self.state = .Stopped
                self.setPlayButtonForState()
                return
            }
        }
        var programElement = self.program[self.programCounter]
        self.programCounter++
        self.excecuteAction(programElement.request)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(programElement.duration, target: self, selector:"playNext", userInfo:nil, repeats: false)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func stop() {
        self.timer?.invalidate()
        var selected = self.programCounter
        self.programCounter = -1
        updateCell(selected-1)
        updateCell(selected)
        updateCell(selected+1)
        self.programCounter = 0
        
    }
    
    func setPlayButtonForState() {
        var image: UIImage?
        var word: String
        switch state {
        case .Stopped:
            image = UIImage(named: "button-play-7")
            word = "Play"
        case .Playing:
            image = UIImage(named: "button-stop-7")
            word = "Stop"
        default:
            image = UIImage(named: "button-play-7")
            word = "Play"
        }
        let button: UIBarButtonItem
        if let img = image {
            button = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action: "play:")
        } else {
            button = UIBarButtonItem(title: word, style: UIBarButtonItemStyle.Plain, target: self, action: "play:")
        }
        self.navigationItem.leftBarButtonItem = button
    }
    
    func cancelAdd() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addElement(program: ProgramElement?, remote: RemoteElement?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let theProgram = program {
            var request = BluetoothRequest.bluetoothRequestWithType(theProgram.type)
            //      if request.componentType == .None {
            //        var noPin = UIAlertController(title: "All Available Pins Used", message: "Please free up a pin for \(textForType(theProgram.type))", preferredStyle: UIAlertControllerStyle.Alert)
            //        noPin.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            //        self.presentViewController(noPin, animated: true, completion: nil)
            //      } else {
            request.value = theProgram.action
            
            var newProgram: InternalProgramElement = (theProgram.name, theProgram.duration, request)
            self.program.append(newProgram)
            self.tableView.reloadData()
            //      }
        }
    }
    
    func addButtonPressed() {
        self.performSegueWithIdentifier("Add", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row < self.program.count {
            self.showReassignablePins(indexPath)
            
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if self.program.count == 0 {
            return 0
        } else {
            return self.program.count + 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == self.program.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("RepeatCell", forIndexPath: indexPath) as! UITableViewCell
            var repeatLabel: UILabel? = cell.contentView.viewWithTag(200) as? UILabel
            if self.doesRepeat {
                cell.backgroundColor = UIColor(red: 1.0, green: 0.94, blue: 0.56, alpha: 0.75)
            } else {
                cell.backgroundColor = UIColor.whiteColor()
            }
            
            return cell
            
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ProgramCell", forIndexPath: indexPath) as! UITableViewCell
            
            var request: BluetoothRequest = self.program[indexPath.row].request
            var nameLabel: UILabel? = cell.contentView.viewWithTag(100) as? UILabel
            nameLabel?.text = self.program[indexPath.row].name
            // cell.textLabel?.text = self.program[indexPath.row].name
            
            var typeLabel: UILabel? = cell.contentView.viewWithTag(101) as? UILabel
            typeLabel?.text = textForType(request.componentType)
            
            var durationLabel: UILabel? = cell.contentView.viewWithTag(102) as? UILabel
            var text = NSString(format: "%.1gs", self.program[indexPath.row].duration)
            durationLabel?.text = text as String
        
            var pinLabel: UILabel? = cell.contentView.viewWithTag(104) as? UILabel
            pinLabel?.text = "Pin: \(BluetoothRequest.stringForPin(request.pin))"
            
            var imageView: UIImageView? = cell.contentView.viewWithTag(103) as? UIImageView
            imageView?.contentMode = UIViewContentMode.Center
            imageView?.image = UIImage(named: imageNameForValue(request.value, request.componentType))
          
          switch request.componentType {
          case .LED:
            imageView?.backgroundColor = UIColor(red: 0.08, green: 0.73, blue: 0.55, alpha: 1)
          case .Servo:
            imageView?.backgroundColor = UIColor(red: 1, green: 0.28, blue:  0.28, alpha: 1)
          case .Sound:
            imageView?.backgroundColor = UIColor(red: 0.31, green: 0.05, blue: 0.73, alpha: 1)
          case .None:
            imageView?.backgroundColor = UIColor.clearColor()
          }
            
            // Configure the cell...
            if indexPath.row == self.programCounter && self.state == .Playing {
                cell.backgroundColor = UIColor(red: 0.47, green: 0.92, blue: 0.6, alpha: 0.8)
            } else {
                cell.backgroundColor = UIColor.whiteColor()
            }
            return cell
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            program.removeAtIndex(indexPath.row)
            tableView.reloadData()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    @IBAction func repeatButtonPressed(sender: UIButton) {
        if self.doesRepeat {
            self.doesRepeat = false
        } else {
            self.doesRepeat = true
        }
        self.tableView.reloadData()
    }
    
    func showReassignablePins(index: NSIndexPath) {
        let alertController = UIAlertController(title: nil, message: nil,
            preferredStyle: .ActionSheet)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.width / 2.0, self.view.bounds.height / 2.0, 1.0, 1.0)
        
        var request = self.program[index.row].request
        var pins: [BluetoothRequest.Pin] = []
        switch request.componentType {
        case .LED:
            pins = BluetoothRequest.allLED
        case .Servo:
            pins = BluetoothRequest.allServo
        case .Sound:
            pins = BluetoothRequest.allSound
        case .None:
            break;
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        for pin in pins {
            var pinAction = UIAlertAction(title: BluetoothRequest.stringForPin(pin), style: .Default, handler: { _ in
                
                self.program[index.row].request.pin = pin
                self.tableView.reloadData()
                
                
            })
            alertController.addAction(pinAction)
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        var addModal: AddModalViewController? = (segue.destinationViewController as? UINavigationController)?.viewControllers.last as? AddModalViewController
        addModal?.delegate = self
        addModal?.type = AddType.ProgramElement
    }
    
    
}
