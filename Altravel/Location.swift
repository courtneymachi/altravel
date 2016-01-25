//
//  City.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 1/24/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation

class Location: NSObject {
    var city:String?
    var country:String?
    
    convenience init(data:NSDictionary) {
        self.init()
        if let city = data["name"] as? String {
            self.city = city
        }
        if let country = data["countryName"] as? String {
            self.country = country
        }
    }
}
