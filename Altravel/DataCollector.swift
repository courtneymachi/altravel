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
    let tracker = GAI.sharedInstance().defaultTracker
    
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    //implemented in LoginVC
    func loginAttempt(success: Bool) {
        Answers.logLoginWithMethod("Facebook", success: success, customAttributes: nil)
    }
    
    //implemented in TripVC
    func favoriteTrip(success: Bool, friendTrip: Bool) {
        var source = "own"
        if (friendTrip) {
            source = "friend"
        }
        Answers.logCustomEventWithName("Favorite", customAttributes: ["action": "add", "source": source, "success": success])
    }
    
    //implemented in TripVC
    func unfavoriteTrip(success: Bool, friendTrip: Bool) {
        var source = "own"
        if (friendTrip) {
            source = "friend"
        }
        Answers.logCustomEventWithName("Favorite", customAttributes: ["action": "remove", "source": source, "success": success])
    }
    
    //implemented in SaveTripVC
    func addTrip(success: Bool) {
        Answers.logCustomEventWithName("Trip", customAttributes: ["action": "creation", "success": success])
    }
    
    //implemented in SaveTripVC
    func cancelTrip() {
        Answers.logCustomEventWithName("Trip", customAttributes: ["action": "cancel"])
    }
    
    //implemented in SaveTripStepVC
    func editTrip(success: Bool) {
        Answers.logCustomEventWithName("Trip", customAttributes: ["action": "edit", "success": success])
    }
    
    //implemented in SaveTripStepVC
    func addStep(success: Bool) {
        Answers.logCustomEventWithName("Step", customAttributes: ["action": "creation", "success": success])
    }
    
     //implemented in SaveTripStepVC
    func cancelStep() {
        Answers.logCustomEventWithName("Step", customAttributes: ["action": "cancel"])
    }
    
    //implemented in AddTripStepVC
    func copyStep(success: Bool) {
        Answers.logCustomEventWithName("Step", customAttributes: ["action": "copy", "success": success])
    }
    
    //implemented in AddTripStepVC
    func cancelStepCopy() {
        Answers.logCustomEventWithName("Step", customAttributes: ["action": "cancel_copy"])
    }
    
    //implemented in SaveTripStepVC
    func editStep(success: Bool) {
        Answers.logCustomEventWithName("Step", customAttributes: ["action": "edit", "success": success])
    }
    
    //TODO: implement in FriendsVC
    func viewFriend() {
        Answers.logCustomEventWithName("Friend", customAttributes: ["action": "view"])
    }
    
    func anyView(viewName: String) {
        tracker.set(kGAIScreenName, value: viewName)
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        Answers.logContentViewWithName(viewName, contentType: nil, contentId: nil, customAttributes: nil)
    }
    
    
}



