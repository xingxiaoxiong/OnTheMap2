//
//  OTMLocation.swift
//  On The Map
//
//  Created by xingxiaoxiong on 12/10/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

struct StudentLocation {
    
    // MARK: Properties
    
    var objectId = ""
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mapString = ""
    var mediaURL: String? = ""
    var latitude: Double
    var longitude: Double

    // MARK: Initializers
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /* Construct a StudentInformation from a dictionary */
    init(dictionary: [String : AnyObject]) {
        objectId = dictionary[OTMClient.JSONResponseKeys.ObjectId] as! String
        uniqueKey = dictionary[OTMClient.JSONResponseKeys.UniqueKey] as! String
        firstName = dictionary[OTMClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[OTMClient.JSONResponseKeys.LastName] as! String
        mapString = dictionary[OTMClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[OTMClient.JSONResponseKeys.MediaURL] as? String
        latitude = dictionary[OTMClient.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[OTMClient.JSONResponseKeys.Longitude] as! Double
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of StudentLocation objects */
    static func StudentLocationFromResults(results: [[String : AnyObject]]) -> [StudentLocation] {
        var studentLocations = [StudentLocation]()
        
        for result in results {
            studentLocations.append(StudentLocation(dictionary: result))
        }
        
        return studentLocations
    }
}
