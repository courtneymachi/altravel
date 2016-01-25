//
//  User.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 1/23/16.
//  Copyright (c) 2016 courtney machi. All rights reserved.
//

import Foundation
import Parse

class UserProperty: PFObject, PFSubclassing {
    @NSManaged var user: PFUser
    @NSManaged var profile: String?
    @NSManaged var city: String?
    @NSManaged var cityId: NSNumber?
    @NSManaged var country: String?
    @NSManaged var countryId: String?
    
    convenience init(user: PFUser) {
        self.init()
        self.user = user
    }
    
    override class func initialize() {
        struct Static {
            static var onceToken: dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "UserProperty"
    }
}
