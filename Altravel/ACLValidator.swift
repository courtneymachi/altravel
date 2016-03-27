//
//  ACLValidator.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 3/26/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import Parse
class ACLValidator {
    static let sharedInstance = ACLValidator()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    func isEditable(object: PFObject) -> Bool {
        if let objectACL = object.ACL {
            if let currentUser = PFUser.currentUser() {
                if objectACL.getWriteAccessForUser(currentUser) {
                    return false;
                }
                else {
                    return true
                }
            }
        }
        return false;
    }
}


