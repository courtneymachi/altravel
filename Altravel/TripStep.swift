//
//  Trip.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 2/7/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import Parse
import MapKit

class TripStep: PFObject, PFSubclassing, MKAnnotation {
    @NSManaged var trip: Trip
    @NSManaged var summary: String
    @NSManaged var originPlace: String?
    @NSManaged var originPlaceId: String?
    @NSManaged var destinationPlace: String?
    @NSManaged var destinationPlaceId: String?
    @NSManaged var note: String?
    @NSManaged var starting: NSDate?
    @NSManaged var ending: NSDate?
    @NSManaged var completed: Bool
    @NSManaged var isArchived: Bool
    
    // MKAnnotation protocol
    @NSManaged var coordinates: PFGeoPoint?
    
    // Title and subtitle for use by selection UI.
    var title: String? {
        get {
            return self.summary
        }
    }
    var subtitle: String? {
        get {
            return self.originPlace
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            if let coordinates = self.coordinates {
                return CLLocationCoordinate2D.init(latitude: coordinates.latitude, longitude: coordinates.longitude)
            }
            else {
                return CLLocationCoordinate2D.init()
            }
        }
    }
    
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
        tripStepACL.publicReadAccess = self.trip.ACL!.publicReadAccess
        tripStepACL.publicWriteAccess = false
        tripStepACL.setWriteAccess(true, forUser: PFUser.currentUser()!)
        self.ACL = tripStepACL;
        
        super.saveEventually(callback)
    }
    
    class func parseClassName() -> String {
        return "TripStep";
    }
}
