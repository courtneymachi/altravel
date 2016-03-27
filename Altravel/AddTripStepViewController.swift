//
//  AddTripViewController.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 3/7/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import UIKit
import Parse

class AddTripStepToTripViewController: BaseViewController {
    
    var trips: Array<Trip>?
    var currentTripStep: TripStep?
    
    @IBOutlet weak var tripTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        DataCollector.sharedInstance.anyView("Copy Step")
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
            return trips.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tripCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("tripCell", forIndexPath: indexPath)
        if let trips = self.trips {
            let trip = trips[indexPath.row] ;
            tripCell.detailTextLabel!.text = trip.note
            tripCell.textLabel!.text = trip.title
        }
        
        return tripCell;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Trips";
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        if let trips = self.trips {
            let currentTrip: Trip = trips[row]
            
            if let currentStep = self.currentTripStep {
                let newStep = TripStep.copyStepInTrip(currentTrip, step: currentStep)
                newStep.saveEventually({ (success, error) -> Void in
                    let message: String
                    let cancelAction: UIAlertAction
                    if (error == nil && success == true) {
                        message = "Step added to your trip correctly."
                    }
                    else {
                        message = "Error while saving step."
                    }
                    cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    let alertController = UIAlertController(title: "Trip", message: message, preferredStyle: .Alert)
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true,  completion: nil)
                })
            }
        }
    }
    
    
    @IBAction func onCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
