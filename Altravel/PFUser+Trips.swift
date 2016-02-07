//
//  PFUser+Trips.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 2/7/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import Parse

extension PFUser {
    func fetchTripsInBacground(block: ((NSArray?, NSError?) -> Void)?) {
        if let query = Trip.query() {
            query.whereKey("user", equalTo: self)
            query.findObjectsInBackgroundWithBlock { (userProperties, error) -> Void in
                if let completionBlock = block {
                    completionBlock(userProperties, error)
                }
            }
        }
    }
}

