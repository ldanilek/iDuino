//
//  ProgramTableViewController.swift
//  iDuino
//
//  Created by Lee Danilek on 4/11/15.
//  Copyright (c) 2015 ShipShape. All rights reserved.
//

import UIKit

typealias ProgramElement = (name: String, type: Type, duration: Double, action: Double)

enum ProgramState {
    case Playing
    case Stopped
}

class ProgramTableViewController: UITableViewController, AddModalProtocol {
    
    var program: [ProgramElement] = []
    var state: ProgramState = .Stopped
    
    var programCounter: Int = 0
    
    var timer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addButtonPressed")
        self.setPlayButtonForState()
        self.title = "Program"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func play(button: UIBarButtonItem)
    {
        switch state {
        case .Stopped:
            self.state = .Playing
            self.programCounter = 0
            self.play()
        case .Playing:
            self.state = .Stopped
            self.stop()
        default:
            self.state = .Playing
        }
        self.setPlayButtonForState()
    }
    
    func excecuteAction(actionType: Type, action: Double) {
        
    }
    
    func play(timer: NSTimer? = nil) {
        if self.programCounter >= self.program.count {
            self.programCounter = 0
            self.state = .Stopped
            return
        }
        var programElement = self.program[self.programCounter]
        self.excecuteAction(programElement.type, action: programElement.action)
        self.timer = NSTimer(timeInterval: programElement.duration, target: self, selector: "play", userInfo: nil, repeats: false)
    }
    
    func stop() {
        
    }
    
    func setPlayButtonForState() {
        var image: UIImage?
        var word: String
        switch state {
        case .Stopped:
            image = nil
            word = "Play"
        case .Playing:
            image = nil
            word = "Pause"
        default:
            word = "Play"
            image = nil
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
        if let theProgram = program {
            self.program.append(theProgram)
            self.tableView.reloadData()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
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
        return self.program.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProgramCell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = self.program[indexPath.row].name
        // Configure the cell...

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
        var addModal: AddModalViewController? = (segue.destinationViewController as? UINavigationController)?.viewControllers.last as? AddModalViewController
        addModal?.delegate = self
        addModal?.type = AddType.ProgramElement
    }
    

}
