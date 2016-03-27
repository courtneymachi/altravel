//
//  DataCollector .swift
//  Altravel
//
//  Created by courtney machi on 3/26/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import Crashlytics

// Use this to collect analytics events across the app.

class DataCollector {
    static let sharedInstance = DataCollector()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    //implemented in SaveTripVC
    func addTrip(outcome: Bool) {
        Answers.logCustomEventWithName("Trip", customAttributes: ["action": "creation", "outcome": outcome])
    }
    
    //implemented in SaveTripVC
    func cancelTrip() {
        Answers.logCustomEventWithName("Trip", customAttributes: ["action": "cancel"])
    }
}



