//
//  RequestLocationViewController.swift
//  On The Map
//
//  Created by xingxiaoxiong on 12/11/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit
import CoreLocation

class RequestLocationViewController: UIViewController {
    
    let placeHolderText = "Input an location here!"
    
    var location = StudentLocation(latitude: 0.0, longitude: 0.0)

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = placeHolderText
        textView.textColor = UIColor.lightGrayColor()
        textView.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.hidden = true;
    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func findOnMapButtonTapped(sender: UIButton) {
        let geoCoder = CLGeocoder()
        let addressString = textView.text
        location.mapString = textView.text
        activityIndicator.hidden = false;
        activityIndicator.startAnimating()
        geoCoder.geocodeAddressString(addressString) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true;
            if error != nil {
                Alert(self, title: "Alert", message: "Geocode failed")
            } else {
                guard let placemarks = placemarks else {
                    Alert(self, title: "Alert", message: "Geocode failed")
                    return
                }
                if placemarks.count > 0 {
                    let placemark = placemarks[0] as CLPlacemark
                    let location = placemark.location
                    self.location.latitude = location!.coordinate.latitude
                    self.location.longitude = location!.coordinate.longitude
                    self.location.mapString = self.textView.text
                    self.location.uniqueKey = OTMClient.sharedInstance().userID!
                    
                    var controller: PostingLocationViewController
                    
                    controller = self.storyboard?.instantiateViewControllerWithIdentifier("PostingLocationViewController") as! PostingLocationViewController
                    
                    controller.studentLocation = self.location
                    
                    
                    
                    // Present the view Controller
                    self.presentViewController(controller, animated: true, completion: nil)
                    
                }
                
                
            }
        }
    }
}

extension RequestLocationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return self.textView.isFirstResponder()
    }
}

extension RequestLocationViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderText
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
}