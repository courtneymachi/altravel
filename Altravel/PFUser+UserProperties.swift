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
    func fetchPropertiesInBacground(block: ((NSArray?, NSError?) -> Void)?) {
        if let query = UserProperty.query() {
            query.whereKey("user", equalTo: self)
            query.findObjectsInBackgroundWithBlock { (userProperties, error) -> Void in
                if let completionBlock = block {
                    completionBlock(userProperties, error)
                }
            }
        }
    }
}
