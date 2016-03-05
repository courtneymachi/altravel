//
//  Trip.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 2/7/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import Parse

class Trip: PFObject, PFSubclassing {
    @NSManaged var user: PFUser
    @NSManaged var title: String?
    @NSManaged var note: String?
    @NSManaged var starting: NSDate
    @NSManaged var ending: NSDate
    @NSManaged var isPublic: Bool
    @NSManaged var isArchived: Bool
    
    convenience init(user: PFUser) {
        self.init()
        self.user = user
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
    
    override func saveEventually(callback: PFBooleanResultBlock?) {
        if (self.isPublic) {
            // create new acl
            // set public read permission and write permission only for the current user
            let tripACL = PFACL.init()
            tripACL.publicReadAccess = true
            tripACL.publicWriteAccess = false
            PFACL.setDefaultACL(tripACL, withAccessForCurrentUser: true)
        }
        super.saveEventually(callback)
    }
    
    class func parseClassName() -> String {
        return "Trip";
    }
    
    func fetchStepsInBacground(block: ((NSArray?, NSError?) -> Void)?) {
        if let query = TripStep.query() {
            query.whereKey("trip", equalTo: self)
            query.whereKey("isArchived", equalTo: false)
            query.findObjectsInBackgroundWithBlock { (userProperties, error) -> Void in
                if let completionBlock = block {
                    completionBlock(userProperties, error)
                }
            }
        }
    }
}
