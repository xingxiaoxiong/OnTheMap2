//
//  Common.swift
//  On The Map
//
//  Created by xingxiaoxiong on 11/30/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit

func Alert(controller: UIViewController, title: String?, message: String?) {
    let alert = UIAlertController(title: title!, message: message!, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
    controller.presentViewController(alert, animated: true, completion: nil)
}

func RefreshData(completionHandler: (success: Bool, errorString: String?) -> Void) {
    OTMClient.sharedInstance().taskForGETStudentLocation(completionHandler)
}