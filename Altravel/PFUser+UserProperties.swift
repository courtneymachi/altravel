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
    func fetchPropertiesInBacground(block: ((PFObject?, NSError?) -> Void)?) {
        if let query = UserProperties.query() {
            query.whereKey("user", equalTo: self)
            query.getFirstObjectInBackgroundWithBlock { (userProperty, error) -> Void in
                if let completionBlock = block {
                    completionBlock(userProperty, error)
                }
            }
        }
    }
}
