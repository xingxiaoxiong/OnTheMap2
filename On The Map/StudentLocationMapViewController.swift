//
//  StudentLocationMapViewController.swift
//  On The Map
//
//  Created by xingxiaoxiong on 12/10/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        if OTMClient.sharedInstance().studentLocations.count == 0 {
            RefreshData(refreshData)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
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
            var annotations = [MKPointAnnotation]()
            
            for location in OTMClient.sharedInstance().studentLocations {
                
                let lat = CLLocationDegrees(location.latitude)
                let long = CLLocationDegrees(location.longitude)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let first = location.firstName
                let last = location.lastName
                let mediaURL = location.mediaURL!
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotations)
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                if let errorString = errorString {
                    Alert(self, title: "Alert", message: errorString)
                }
            })
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }


}
