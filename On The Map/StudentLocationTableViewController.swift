//
//  StudentLocationTableViewController.swift
//  On The Map
//
//  Created by xingxiaoxiong on 12/10/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

class StudentLocationTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        RefreshData(refreshData)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshButtonTapped", name: dataRefreshNotificationKey, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addLocationButtonTapped", name: addLocationNotificationKey, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func addLocationButtonTapped() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("RequestLocationViewController") as! RequestLocationViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func refreshButtonTapped() {
        RefreshData(refreshData)
    }
    
    func refreshData(success: Bool, errorString: String?) {
        if success {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                if let errorString = errorString {
                    Alert(self, title: "Alert", message: errorString)
                }
            })
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "StudentLocationCell"
        let studentLocation = StudentLocation.studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        cell.textLabel!.text = studentLocation.firstName + studentLocation.lastName
        cell.imageView!.image = UIImage(named: "Pin")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocation.studentLocations.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let urlString = StudentLocation.studentLocations[indexPath.row].mediaURL else {
            Alert(self, title: "Alert", message: "No URL presented")
            return
        }
        UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
}
