//
//  Trip.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 2/7/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import Parse

class TripStep: PFObject, PFSubclassing {
    @NSManaged var trip: Trip
    @NSManaged var summary: String?
    @NSManaged var originPlace: String?
    @NSManaged var originPlaceId: String?
    @NSManaged var destinationPlace: String?
    @NSManaged var destinationPlaceId: String?
    @NSManaged var note: String?
    @NSManaged var starting: NSDate?
    @NSManaged var ending: NSDate?
    @NSManaged var completed: Bool
    @NSManaged var isArchived: Bool
    
    convenience init(trip: Trip) {
        self.init()
        self.trip = trip
        self.completed = false
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
        return "TripStep";
    }
}
