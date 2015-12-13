

import Foundation

// MARK: - OTMClient: NSObject

class OTMClient : NSObject {
    
    // MARK: Properties
    
    /* Shared session */
    var session: NSURLSession
    
    /* Authentication state */
    var userID : String? = nil
    
    var firstName: String? = nil
    var lastName: String? = nil
    
    var studentLocations = [StudentLocation]()
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    // MARK: GET
    
    func taskForGETUserData(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        var mutableMethod : String = Methods.GetUserData
        mutableMethod = OTMClient.subtituteKeyInMethod(mutableMethod, key: OTMClient.URLKeys.UserID, value: String(OTMClient.sharedInstance().userID!))!
        
        let urlString = mutableMethod
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)

        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil) else {
                completionHandler(success: false, errorString: "Network connection error.")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completionHandler(success: false, errorString: "Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    completionHandler(success: false, errorString: "Your request returned an invalid response! Response: \(response)!")
                } else {
                    completionHandler(success: false, errorString: "Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, errorString: "No data was returned by the request!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: { (result, error) -> Void in
                if error != nil {
                    completionHandler(success: false, errorString: "Data parse failed.")
                } else {
                    guard let user = result["user"] as! [String: AnyObject]? else {
                        completionHandler(success: false, errorString: "Data doesn't contain a user info")
                        return
                    }
                    
                    guard let firstName = user["first_name"] as! String? else {
                        completionHandler(success: false, errorString: "Data doesn't contain a first name")
                        return
                    }
                    
                    guard let lastName = user["last_name"] as! String? else {
                        completionHandler(success: false, errorString: "Data doesn't contain an lastname")
                        return
                    }
                    
                    OTMClient.sharedInstance().firstName = firstName
                    OTMClient.sharedInstance().lastName = lastName
                    completionHandler(success: true, errorString: nil)
                }
            })
            
        }
        task.resume()
    }
    
    func taskForGETStudentLocation(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        /* 1. Set the parameters */
        // There are none...
        var mutableParameters = [String: AnyObject]()
        mutableParameters[ParameterKeys.Limit] = Constants.Limit
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Methods.Parse + OTMClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.ParseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(success: false, errorString: "Network connection error.")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completionHandler(success: false, errorString: "Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    completionHandler(success: false, errorString: "Your request returned an invalid response! Response: \(response)!")
                } else {
                    completionHandler(success: false, errorString: "Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, errorString: "No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            //print(NSString(data: data, encoding: NSUTF8StringEncoding))
            OTMClient.parseJSONWithCompletionHandler(data, completionHandler: { (result, error) -> Void in
                if error != nil {
                    completionHandler(success: false, errorString: "Data parse failed.")
                } else {
                    OTMClient.sharedInstance().studentLocations = StudentLocation.StudentLocationFromResults(result["results"] as! [[String : AnyObject]])
                    completionHandler(success: true, errorString: nil)
                }
            })
        }
        
        /* 7. Start the request */
        task.resume()

    }

    // MARK: POST
    
    func createUdacitySession(email: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()

        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil) else {
                completionHandler(success: false, errorString: "Network connection error.")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completionHandler(success: false, errorString: "Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    completionHandler(success: false, errorString: "Your request returned an invalid response! Response: \(response)!")
                } else {
                    completionHandler(success: false, errorString: "Your request returned an invalid response!")
                }
                return
            }

            guard let data = data else {
                completionHandler(success: false, errorString: "No data was returned by the request!")
                return
            }

            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            
            OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: { (result, error) -> Void in
                if error != nil {
                    completionHandler(success: false, errorString: "Data parse failed.")
                } else {
                    guard let account = result["account"] else {
                        completionHandler(success: false, errorString: "Data doesn't contain a session")
                        return
                    }
                    
                    guard let userId = account!["key"] as? String else {
                        completionHandler(success: false, errorString: "Data doesn't contain an id")
                        return
                    }
                    
                    OTMClient.sharedInstance().userID = userId
                    completionHandler(success: true, errorString: nil)
                }
            })
            
            //completionHandler(success: true, errorString: nil)
        }
        task.resume()
    }
    
    func deleteUdacitySession(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in (sharedCookieStorage.cookies )! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard (error == nil) else {
                completionHandler(success: false, errorString: "Network connection error.")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completionHandler(success: false, errorString: "Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    completionHandler(success: false, errorString: "Your request returned an invalid response! Response: \(response)!")
                } else {
                    completionHandler(success: false, errorString: "Your request returned an invalid response!")
                }
                return
            }
            
            guard let _ = data else {
                completionHandler(success: false, errorString: "No data was returned by the request!")
                return
            }
            
            completionHandler(success: true, errorString: nil)
        }
        task.resume()
    }

    
    func postLocationToParse(studentLocation: StudentLocation, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        /* 1. Set the parameters */
        let jsonBody : [String:AnyObject] = [
            OTMClient.JSONResponseKeys.UniqueKey: studentLocation.uniqueKey,
            OTMClient.JSONResponseKeys.FirstName: studentLocation.firstName,
            OTMClient.JSONResponseKeys.LastName: studentLocation.lastName,
            OTMClient.JSONResponseKeys.MapString: studentLocation.mapString,
            OTMClient.JSONResponseKeys.MediaURL: studentLocation.mediaURL!,
            OTMClient.JSONResponseKeys.Latitude: studentLocation.latitude,
            OTMClient.JSONResponseKeys.Longitude: studentLocation.longitude
        ]
        
        /* 2/3. Build the URL and configure the request */
        let urlString = OTMClient.Methods.Parse
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(success: false, errorString: "Network connection error.")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    completionHandler(success: false, errorString: "Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    completionHandler(success: false, errorString: "Your request returned an invalid response! Response: \(response)!")
                } else {
                    completionHandler(success: false, errorString: "Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                completionHandler(success: false, errorString: "No data was returned by the request!")
                return
            }
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(data, completionHandler: { (result, error) -> Void in
                if error != nil {
                    completionHandler(success: false, errorString: "Data parse failed.")
                } else {
                    guard let _ = result["objectId"] else {
                        completionHandler(success: false, errorString: "Data doesn't contain an objectId")
                        return
                    }
                    
                    completionHandler(success: true, errorString: nil)
                }
            })
            
        }
        
        /* 7. Start the request */
        task.resume()
        
    }
    
    // MARK: Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
}