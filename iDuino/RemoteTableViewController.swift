//
//  RemoteTableViewController.swift
//  iDuino
//
//  Created by Lee Danilek on 4/11/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

typealias RemoteElement =  (String, BluetoothRequest.Component)
class RemoteTableViewController: UITableViewController, AddModalProtocol {
    
    var remote: [RemoteElement] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Remote"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem (barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addButtonPressed")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return remote.count
    }
    
    func cancelAdd() {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func addElement(program: ProgramElement?, remote: RemoteElement?) {
        if let theRemote = remote {
            self.remote.append(theRemote)
            self.tableView.reloadData()
        }
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func switchLEDChanged(sender: UISwitch) {
        var cell: UITableViewCell = sender.superview?.superview as! UITableViewCell
        var indexPath = self.tableView.indexPathForCell(cell)
        var shouldBeOn:Bool = sender.on
        //do change the LED
    }
    @IBAction func prevButtonPressed(sender: UIButton) {
        println("prev")
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        println("next")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RemoteCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        
        // Name of the action
        (cell.contentView.viewWithTag(100) as! UILabel).text = self.remote[indexPath.row].0 as String
        
        // Type of the action
        var typeText: String
        var switchLED = cell.contentView.viewWithTag(102) as! UISwitch
        var prevButton = cell.contentView.viewWithTag(103) as! UIButton
        var nextButton =  cell.contentView.viewWithTag(104) as! UIButton
        
        switch self.remote[indexPath.row].1 {
        case .LED:
            typeText = "LED"
            switchLED.hidden = false
            prevButton.hidden = true
            nextButton.hidden = true
            
        case .Servo:
            typeText = "Servo"
            switchLED.hidden = true
            prevButton.hidden = false
            nextButton.hidden = false
            prevButton.setBackgroundImage(UIImage(named: "swipe-left"), forState: UIControlState.Normal)
            nextButton.setBackgroundImage(UIImage(named: "swipe-right"), forState: UIControlState.Normal)
            
        case .Sound:
            typeText = "Sound"
            switchLED.hidden = true
            prevButton.hidden = false
            nextButton.hidden = false
            prevButton.setBackgroundImage(UIImage(named: "music-note"), forState: UIControlState.Normal)
            nextButton.setBackgroundImage(UIImage(named: "music"), forState: UIControlState.Normal)
        default:
            typeText = "ERROR: NONE"
        
        }
        (cell.contentView.viewWithTag(101) as! UILabel).text = typeText
        
        
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
    }


}
