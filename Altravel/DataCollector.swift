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
    
    //TODO: implement in LoginVc
    func loginAttempt(outcome: Bool) {
        Answers.logCustomEventWithName("Login", customAttributes: ["action": "login", "outcome": outcome])
    }
    
    //TODO: implement in TripVC
    func favoriteOwnTrip() {
        Answers.logCustomEventWithName("Favorite", customAttributes: ["action": "own_trip"])
    }
    
    func favoriteFriendTrip() {
        Answers.logCustomEventWithName("Favorite", customAttributes: ["action": "friend_trip"])
    }
    
    //implemented in SaveTripVC
    func addTrip(outcome: Bool) {
        Answers.logCustomEventWithName("Trip", customAttributes: ["action": "creation", "outcome": outcome])
    }
    
    //implemented in SaveTripVC
    func cancelTrip() {
        Answers.logCustomEventWithName("Trip", customAttributes: ["action": "cancel"])
    }
    
    //TODO: implement in SaveTrip VC
    func editTrip() {
        Answers.logCustomEventWithName("Trip", customAttributes: ["action": "edit"])
    }
    
    //TODO: implement in SaveTripStepVC
    func addStep(outcome: Bool) {
        Answers.logCustomEventWithName("Step", customAttributes: ["action": "creation", "outcome": outcome])
    }
    
    func cancelStep() {
        Answers.logCustomEventWithName("Step", customAttributes: ["action": "cancel"])
    }
    
    func copyStep(outcome: Bool) {
        Answers.logCustomEventWithName("Step", customAttributes: ["action": "copy", "outcome": outcome])
    }
    
    func editStep() {
        Answers.logCustomEventWithName("Step", customAttributes: ["action": "edit"])
    }
    
    //TODO: implement in FriendsVC
    func viewFriend() {
        Answers.logCustomEventWithName("Friend", customAttributes: ["action": "view"])
    }
    
    func anyView(viewName: String) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: viewName)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        Answers.logContentViewWithName(viewName, contentType: nil, contentId: nil, customAttributes: nil)

    }
    
    
}



