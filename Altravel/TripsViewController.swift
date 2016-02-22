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

class TripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var trips: NSArray?
    var currentTrip: Trip?
    
    @IBOutlet weak var tripTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser:PFUser = PFUser.currentUser() {
            currentUser.fetchTripsInBacground({ (trips, error) -> Void in
                if (error == nil) {
                    self.trips = trips;
                    if (trips?.count > 0) {
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
        
        var tripCell: UITableViewCell
        
        if indexPath.row >= self.trips?.count {
            tripCell = tableView.dequeueReusableCellWithIdentifier("newTripCell", forIndexPath: indexPath)
        }
        else {
            tripCell = tableView.dequeueReusableCellWithIdentifier("tripCell", forIndexPath: indexPath)
            if let trips = self.trips {
                let trip = trips[indexPath.row] as! Trip;
                tripCell.detailTextLabel!.text = trip.note
                tripCell.textLabel!.text = trip.title
            }
        }
        
        return tripCell;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Trips";
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        self.currentTrip = nil;
        if let trips = self.trips {
            if row < trips.count {
                self.currentTrip = trips[row] as? Trip
            }
        }
        self.performSegueWithIdentifier("addTripSuccessSegue", sender: self);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier;
        if identifier == "addTripSuccessSegue" {
            let saveTripViewController = segue.destinationViewController as! SaveTripViewController
            if let trip = self.currentTrip {
                saveTripViewController.currentTrip = trip
            }
            else {
                saveTripViewController.currentTrip = Trip.init(user: PFUser.currentUser()!)
            }
        }
    }
    


}