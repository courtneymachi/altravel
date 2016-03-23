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
    
    var trips: Array<Trip>?
    var currentTrip: Trip?
    
    @IBOutlet weak var tripTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchTrips()
    }
    
    func fetchTrips() {
        if let currentUser:PFUser = PFUser.currentUser() {
            currentUser.fetchTripsInBackground({ (trips, error) -> Void in
                if (error == nil) {
                    self.trips = trips as? Array<Trip>;
                    self.tripTableView.reloadData()
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
                let trip = trips[indexPath.row] ;
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
                self.currentTrip = trips[row]
                self.performSegueWithIdentifier("showTrip", sender: self)
            }
            else {
                self.performSegueWithIdentifier("addTripSegue", sender: self)
            }
        }
        else {
            self.performSegueWithIdentifier("addTripSegue", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if var trips = self.trips {
                let trip: Trip = trips[indexPath.row] 
                trip.isArchived = true
                trip.saveEventually({ (success, error) -> Void in
                    let alertController = UIAlertController(title: "Trip", message: "Trip archived correctly.", preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                        self.fetchTrips()
                    }
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    
    @IBAction func onAddTrip(sender: AnyObject) {
        self.performSegueWithIdentifier("addTripSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier!;
        switch identifier {
            case "addTripSegue":
                let destinationViewController = segue.destinationViewController as! SaveTripViewController
                destinationViewController.currentTrip = Trip.init(user: PFUser.currentUser()!)
                break
            case "showTrip":
                if let trip = self.currentTrip {
                    let destinationViewController = segue.destinationViewController as! TripViewController
                    destinationViewController.currentTrip = trip
                }
                break
            default:
                break;
        }
    }
    


}