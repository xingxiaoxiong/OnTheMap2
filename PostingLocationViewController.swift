//
//  PostingLocationViewController.swift
//  On The Map
//
//  Created by xingxiaoxiong on 12/12/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit
import MapKit

class PostingLocationViewController: UIViewController {
    
    let placeHolderText = "Input a url here!"
    
    var studentLocation = StudentLocation(latitude: 0.0, longitude: 0.0)

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTextField.text = placeHolderText
        urlTextField.textColor = UIColor.lightGrayColor()
        urlTextField.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let coordinate = CLLocationCoordinate2D(latitude: studentLocation.latitude, longitude: studentLocation.longitude)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.setRegion(MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.02, 0.01)), animated: false)
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButtonTapped(sender: UIButton) {
        studentLocation.mediaURL = urlTextField.text
        studentLocation.firstName = OTMClient.sharedInstance().firstName!
        studentLocation.lastName = OTMClient.sharedInstance().lastName!
        
        OTMClient.sharedInstance().postLocationToParse(studentLocation) { (success, errorString) -> Void in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                })
                
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    if let errorString = errorString {
                        Alert(self, title: "Alert", message: errorString)
                    }
                })
            }
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

}

extension PostingLocationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return self.urlTextField.isFirstResponder()
    }
}

extension PostingLocationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if urlTextField.textColor == UIColor.lightGrayColor() {
            urlTextField.text = nil
            urlTextField.textColor = UIColor.blackColor()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if urlTextField.text!.isEmpty {
            urlTextField.text = placeHolderText
            urlTextField.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
}
