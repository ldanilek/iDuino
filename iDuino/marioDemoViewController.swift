//
//  marioDemoViewController.swift
//  iDuino
//
//  Created by TAISHI on 4/12/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit


class marioDemoViewController: UITableViewController {
    var program: [InternalProgramElement] = []
    
    var state: ProgramState = .Stopped
    
    var currentInstruction: UInt8 = 0
    
    var programCounter: Int = 0
    
    var timer: NSTimer?
    
    var doesRepeat: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addButtonPressed")
        self.setPlayButtonForState()
        self.title = "Mario!"
        
        
        
        var reqMario = BluetoothRequest.bluetoothRequestWithType(BluetoothRequest.Component.Sound)
        reqMario.value = .LowSound
        reqMario.pin = BluetoothRequest.Pin.D12
        var objMario:InternalProgramElement = ("Mario DJ", 0.18, reqMario)
        program.append(objMario)
        
        let pinArray:[BluetoothRequest.Pin] = [.D0, .D0, .D3, .D0, .D3, .D1, .D0, .D3, .D0, .D3, .D3, .D3, .D2, .D3, .D3, .D3]
        for index in 0...15 {
            var req1 = BluetoothRequest.bluetoothRequestWithType(BluetoothRequest.Component.LED)
            req1.value = .On
            req1.pin = pinArray[index]
            var obj1:InternalProgramElement = ("\(index) On",0.04,req1)
            program.append(obj1)
            
            var req2 = BluetoothRequest.bluetoothRequestWithType(BluetoothRequest.Component.LED)
            req2.value = .Off
            req2.pin = pinArray[index]
            var obj2:InternalProgramElement = ("\(index) Off", 0.03, req2)
            program.append(obj2)
            
            if (index % 3) == 1 {
                var req3 = BluetoothRequest.bluetoothRequestWithType(BluetoothRequest.Component.Servo)
                if (index % 2) == 1 {
                    req3.value = .TurnRight
                }else {
                    req3.value = .TurnLeft
                }
                req3.pin = .D11
                var obj3:InternalProgramElement = ("\(index) Servo", 0.01, req3)
                program.append(obj3)
                
            }
        }
        
        var reqFin1 = BluetoothRequest.bluetoothRequestWithType(BluetoothRequest.Component.Servo)
        reqFin1.value = .TurnLeft
        reqFin1.pin = .D11
        var objFin1:InternalProgramElement = ("Servo", 1, reqFin1)
        program.append(objFin1)
        
        var reqFin2 = BluetoothRequest.bluetoothRequestWithType(BluetoothRequest.Component.Servo)
        reqFin2.value = .Off
        reqFin2.pin = .D11
        var objFin2:InternalProgramElement = ("Servo", 5, reqFin2)
        program.append(objFin2)
        
        var stopMusReq = BluetoothRequest.bluetoothRequestWithType(BluetoothRequest.Component.Sound)
        stopMusReq.value = .Off
        stopMusReq.pin = .D12
        var stopMusObj:InternalProgramElement = ("Stop Music", 5, stopMusReq)
        program.append(stopMusObj)
        
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
            var text = NSString(format: "%.3gs", self.program[indexPath.row].duration)
            durationLabel?.text = text as String
            durationLabel?.hidden = true
        
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
    }
    
    
}