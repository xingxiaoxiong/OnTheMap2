

import UIKit
import Foundation

extension OTMClient {
    
    func loginUdacity(email: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        createUdacitySession(email, password: password) { (success, errorString) -> Void in
            if success {
                self.taskForGETUserData(completionHandler)
            } else {
                completionHandler(success: false, errorString: errorString)
            }
        }
    }

}