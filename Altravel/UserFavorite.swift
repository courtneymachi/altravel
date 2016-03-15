//
//  UserFavorite.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 3/12/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation

import Parse

class UserFavorite: PFObject, PFSubclassing {
    @NSManaged var user: PFUser
    @NSManaged var trip: Trip
    @NSManaged var isArchived: Bool
    
    convenience init(user: PFUser, trip: Trip) {
        self.init()
        self.user = user
        self.trip = trip
        self.isArchived = false
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
        return "UserFavorite"
    }
}
