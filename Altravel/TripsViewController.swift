//
//  TripsViewController.swift
//  Altravel
//
//  Created by courtney machi on 1/24/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import UIKit


class TripsViewController: UIViewController {
    
    @IBAction func addTripButton(sender: UIButton) {
        self.performSegueWithIdentifier("addTripSuccessSegue", sender: self)
    }

}