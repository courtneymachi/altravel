//
//  UserExtension.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 1/23/16.
//  Copyright (c) 2016 courtney machi. All rights reserved.
//

import Foundation
import Parse

extension PFUser {
    
    func fetchPropertiesInBacground(block: ((UserProperty?, NSError?) -> Void)?) {
        if let query = UserProperty.query() {
            query.whereKey("user", equalTo: self)
            query.includeKey("user")
            query.findObjectsInBackgroundWithBlock { (userProperties, error) -> Void in
                if let completionBlock = block {
                    if let properties = userProperties {
                        let property = properties[0] as! UserProperty
                        completionBlock(property, error)
                    }
                    
                }
            }
        }
    }
    
    func fetchTripsInBackground(block: ((NSArray?, NSError?) -> Void)?) {
        if let query = Trip.query() {
            query.whereKey("user", equalTo: self)
            query.whereKey("isArchived", equalTo: false)
            query.findObjectsInBackgroundWithBlock { (trips, error) -> Void in
                if let completionBlock = block {
                    completionBlock(trips, error)
                }
            }
        }
    }
    
    func fetchAllUsersExpectCurrentOne(user: PFUser?, block: ((NSArray?, NSError?) -> Void)?) {
        if let currentUser = user {
            if let query = PFUser.query() {
                query.whereKey("objectId", notEqualTo: currentUser.objectId!)
                query.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
                    if let completionBlock = block {
                        completionBlock(users, error)
                    }
                })
            }
        }
    }
    
    func fetchFriendsPropertiesInBacground(block: ((NSArray?, NSError?) -> Void)?) {
        if let query = UserProperty.query() {
            query.whereKey("user", notEqualTo: self)
            query.includeKey("user")
            query.findObjectsInBackgroundWithBlock { (userProperties, error) -> Void in
                if let completionBlock = block {
                    completionBlock(userProperties, error)
                }
            }
        }
    }
    
    func fetchFavoritesInBackground(block: ((NSArray?, NSError?) -> Void)?) {
        if let query = UserFavorite.query() {
            query.whereKey("user", equalTo: self)
            query.whereKey("isArchived", equalTo: false)
            query.includeKey("trip")
            query.findObjectsInBackgroundWithBlock { (favorites, error) -> Void in
                if let completionBlock = block {
                    completionBlock(favorites, error)
                }
            }
        }
    }
    
    
    func fetchFavoriteForTrip(trip: Trip, block: ((UserFavorite?, NSError?) -> Void)?) {
        if let query = UserFavorite.query() {
            query.whereKey("user", equalTo: self)
            query.includeKey("trip")
            query.whereKey("trip", equalTo: trip)
            query.findObjectsInBackgroundWithBlock { (favorites, error) -> Void in
                if let completionBlock = block {
                    if let favs = favorites {
                        let favorite = favs[0] as! UserFavorite
                        completionBlock(favorite, error)
                    }
                    
                }
            }
        }
    }
}
