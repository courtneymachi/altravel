//
//  TripsViewController.swift
//  Altravel
//
//  Created by courtney machi on 1/24/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import UIKit
import Parse

class TripsViewController: UIViewController {
    
    var trips:NSArray?
    
    @IBOutlet weak var tripTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser:PFUser = PFUser.currentUser() {
            currentUser.fetchTripsInBacground({ (trips, error) -> Void in
                if (error == nil) {
                    self.trips = trips;
                    if (trips?.count > 0) {
                        self.tripTableView.hidden = false
                        self.tripTableView.reloadData()
                    }

                }
                else {
                    NSLog("Error retrieving user trips \(error!)")
                }
            })
            
        }

    }
    
    // Table view delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let trips = self.trips {
            return trips.count + 1
        }
        else {
            return 1;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tripCell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("tripCell", forIndexPath: indexPath)
        if let trips = self.trips {
            let trip = trips[indexPath.row] as! Trip;
            tripCell.detailTextLabel!.text = trip.note
            tripCell.textLabel!.text = trip.title
        }
        
        return tripCell;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Trips";
    }

}