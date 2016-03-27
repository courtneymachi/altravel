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
    @NSManaged var title: String
    @NSManaged var note: String?
    @NSManaged var starting: NSDate?
    @NSManaged var ending: NSDate?
    @NSManaged var isPublic: Bool
    @NSManaged var isArchived: Bool
    @NSManaged var isCompleted: Bool
    @NSManaged var place: String?
    @NSManaged var placeId: String?
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    convenience init(user: PFUser) {
        self.init()
        self.user = user
        self.isArchived = false
        self.isCompleted = false
        self.isPublic = true
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
        let tripACL = PFACL.init()
        tripACL.publicReadAccess = self.isPublic
        tripACL.publicWriteAccess = false
        tripACL.setWriteAccess(true, forUser: PFUser.currentUser()!)
        self.ACL = tripACL
        super.saveEventually(callback)
    }
    
    class func parseClassName() -> String {
        return "Trip";
    }
    
    func fetchStepsInBacground(block: ((NSArray?, NSError?) -> Void)?) {
        if let query = TripStep.query() {
            query.whereKey("trip", equalTo: self)
            query.whereKey("isArchived", equalTo: false)
            query.includeKey("trip")
            query.findObjectsInBackgroundWithBlock { (userProperties, error) -> Void in
                if let completionBlock = block {
                    completionBlock(userProperties, error)
                }
            }
        }
    }
}
