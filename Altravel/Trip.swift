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
        return "Trip";
    }
    
    func fetchStepsInBacground(block: ((NSArray?, NSError?) -> Void)?) {
        if let query = TripStep.query() {
            query.whereKey("trip", equalTo: self)
            query.findObjectsInBackgroundWithBlock { (userProperties, error) -> Void in
                if let completionBlock = block {
                    completionBlock(userProperties, error)
                }
            }
        }
    }
}
