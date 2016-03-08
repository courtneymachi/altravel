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
    
    static func copyStepInTrip(trip: Trip, step: TripStep) -> TripStep {
        let newStep = TripStep.init(trip: trip)
        newStep.summary = step.summary
        newStep.originPlace = step.originPlace
        newStep.originPlaceId = step.originPlaceId
        newStep.destinationPlace = step.destinationPlace
        newStep.destinationPlaceId = step.destinationPlaceId
        newStep.note = step.note
        newStep.starting = step.starting
        newStep.ending = step.ending
        newStep.completed = step.completed
        newStep.isArchived = step.isArchived
        return newStep;
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
        let tripStepACL = PFACL.init()
        tripStepACL.publicReadAccess = true
        tripStepACL.publicWriteAccess = false
        PFACL.setDefaultACL(tripStepACL, withAccessForCurrentUser: true)
        super.saveEventually(callback)
    }
    
    class func parseClassName() -> String {
        return "TripStep";
    }
}
