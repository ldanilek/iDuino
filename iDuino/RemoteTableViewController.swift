//
//  RemoteTableViewController.swift
//  iDuino
//
//  Created by Lee Danilek on 4/11/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

typealias RemoteElement =  (String, BluetoothRequest.Component)
typealias InternalRemoteElt = (name: String, request: BluetoothRequest)

class RemoteTableViewController: UITableViewController, AddModalProtocol {
    
    var remote: [InternalRemoteElt] = []
    
    var currentInstruction: UInt8 = 0
    
    var request: BluetoothRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Remote"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem (barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addButtonPressed")

        // Start the Bluetooth discovery process
        btDiscoverySharedInstance
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.remote.count
    }
    
    func cancelAdd() {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func addElement(program: ProgramElement?, remote: RemoteElement?) {
        if let theRemote = remote {
            var request = BluetoothRequest.bluetoothRequestWithType(theRemote.1)
            if request.componentType == .None {
                var noPin = UIAlertController(title: "All Available Pins Used", message: "Please free up a pin for \(textForType(theRemote.1))", preferredStyle: UIAlertControllerStyle.Alert)
                noPin.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(noPin, animated: true, completion: nil)
            }else {
                var newRemote: InternalRemoteElt = (theRemote.0, request)
                self.remote.append(newRemote)
                self.tableView.reloadData()
            }
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func switchLEDChanged(sender: UISwitch) {
        var cell: UITableViewCell = sender.superview?.superview as! UITableViewCell
        var indexPath = self.tableView.indexPathForCell(cell)!.row
        var shouldBeOn:Bool = sender.on
        var remoteElt = self.remote[indexPath]
        //do change the LED
        if shouldBeOn {
            remoteElt.request.value = .On
        } else {
            remoteElt.request.value = .Off
        }
        
        //said component does not exist
        if remoteElt.request.componentType == .None {
            // out of assignable pins, act accordingly
            var nopinAlert = UIAlertController(title: "No More Pin Available", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            nopinAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        }
        sendByteString(remoteElt.request.generateByteString())
    }
    @IBAction func prevButtonPressed(sender: UIButton) {
        var cell: UITableViewCell = sender.superview?.superview as! UITableViewCell
        var indexPath = self.tableView.indexPathForCell(cell)!.row
        var remoteElt = self.remote[indexPath]
        if remoteElt.request.componentType == .Servo {
            remoteElt.request.value = .TurnLeft
        } else {
            remoteElt.request.value = .LowSound
        }
        //said component does not exist
        if remoteElt.request.componentType == .None {
            // out of assignable pins, act accordingly
            var nopinAlert = UIAlertController(title: "No More Pin Available", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            nopinAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        }
        
        sendByteString(remoteElt.request.generateByteString())
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        var cell: UITableViewCell = sender.superview?.superview as! UITableViewCell
        var indexPath = self.tableView.indexPathForCell(cell)!.row
        var remoteElt = self.remote[indexPath]
        if remoteElt.request.componentType == .Servo {
            remoteElt.request.value = .TurnRight
        } else {
            remoteElt.request.value = .HighSound
        }
        //said component does not exist
        if remoteElt.request.componentType == .None {
            // out of assignable pins, act accordingly
            var nopinAlert = UIAlertController(title: "No More Pin Available", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            nopinAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        }
        
        sendByteString(remoteElt.request.generateByteString())
    }
    
    func sendByteString(byteString: UInt8) {
        println("Sending byte string: \(pad(String(byteString, radix: 2), 8))")
        // Is the instructino already running?
        if byteString == currentInstruction {
           return
        }
        
        // Send bytes5tring to BLE Shield (if service exists and is connected)
        if let bleService = btDiscoverySharedInstance.bleService {
            bleService.writePosition(byteString)
            currentInstruction = byteString;
            
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RemoteCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        
        // Name of the action
        (cell.contentView.viewWithTag(100) as! UILabel).text = self.remote[indexPath.row].0 as String
        
        // Type of the action
        var switchLED = cell.contentView.viewWithTag(102) as! UISwitch
        var prevButton = cell.contentView.viewWithTag(103) as! UIButton
        var nextButton =  cell.contentView.viewWithTag(104) as! UIButton
        
        var pinLabel = cell.contentView.viewWithTag(110) as! UILabel
        pinLabel.text = "Pin: \(BluetoothRequest.stringForPin(self.remote[indexPath.row].request.pin))"
        
        switch self.remote[indexPath.row].request.componentType {
        case .LED:
            switchLED.hidden = false
            prevButton.hidden = true
            nextButton.hidden = true
            
        case .Servo:
            switchLED.hidden = true
            prevButton.hidden = false
            nextButton.hidden = false
            prevButton.setBackgroundImage(UIImage(named: "swipe-left"), forState: UIControlState.Normal)
            nextButton.setBackgroundImage(UIImage(named: "swipe-right"), forState: UIControlState.Normal)
            
        case .Sound:
            switchLED.hidden = true
            prevButton.hidden = false
            nextButton.hidden = false
            prevButton.setBackgroundImage(UIImage(named: "music-note"), forState: UIControlState.Normal)
            nextButton.setBackgroundImage(UIImage(named: "music"), forState: UIControlState.Normal)
        default:
            switchLED.hidden = true
            prevButton.hidden = true
            nextButton.hidden = true
        }
        (cell.contentView.viewWithTag(101) as! UILabel).text = textForType(self.remote[indexPath.row].request.componentType)
        
        
        
        return cell
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
            self.remote.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
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
        let nextNavigationController:AddModalViewController? = ((segue.destinationViewController as? UINavigationController)?.viewControllers.last as? AddModalViewController)
        nextNavigationController?.delegate = self
        nextNavigationController?.type = AddType.RemoteElement
    }


}
