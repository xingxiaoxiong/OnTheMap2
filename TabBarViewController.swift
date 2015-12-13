//
//  TabBarViewController.swift
//  On The Map
//
//  Created by xingxiaoxiong on 12/10/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

let dataRefreshNotificationKey = "dataRefreshNotificationKey"
let addLocationNotificationKey = "addLocationNotificationKey"

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func RefreshButtonTapped(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().postNotificationName(dataRefreshNotificationKey, object: self)
    }

    
    @IBAction func LogoutButtonTapped(sender: UIBarButtonItem) {
        OTMClient.sharedInstance().deleteUdacitySession { (success, errorString) -> Void in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    Alert(self, title: "Alert", message: errorString)
                })
            }
        }
    }
    
    @IBAction func AddNewLocationButtonTapped(sender: UIBarButtonItem) {
        NSNotificationCenter.defaultCenter().postNotificationName(addLocationNotificationKey, object: self)
    }

}
