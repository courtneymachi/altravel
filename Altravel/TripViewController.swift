//
//  TripViewController.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 2/28/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import UIKit

class TripViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var currentTrip: Trip?
    var steps: NSArray?
    var sectionOpenInfo: [String: Bool]?
    
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var tripTitle: UILabel!
    @IBOutlet weak var publicImageView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    func initUI() {
        if let trip = self.currentTrip {
            self.tripTitle.text = trip.title
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            self.datesLabel.text = "\(formatter.stringFromDate(trip.starting)) -> \(formatter.stringFromDate(trip.ending))"
            self.publicImageView.hidden = !trip.isPublic
            self.descriptionLabel.text = trip.note
        }
    }
    
    func fetchTrips() {
        if let trip = self.currentTrip {
            trip.fetchStepsInBacground({ (steps, error) -> Void in
                if (error != nil) {
                    self.steps = steps
                    if let tripSteps = self.steps {
                        if tripSteps.count > 0 {
                            self.sectionOpenInfo = Dictionary<String, Bool>()
                            
                            for step in tripSteps {
                                if let objectId = step.objectId {
                                    self.sectionOpenInfo!.updateValue(false, forKey: objectId!)
                                }
                            }
                        }
                    }
                    self.stepsTableView.reloadData()
                }
            })
        }
    }
    
    // Table view delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let steps = self.steps {
            return steps.count
        }
        else {
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tripSteps = self.steps {
            let step = tripSteps[section]
            if let sectionOpenInfo = self.sectionOpenInfo {
                if sectionOpenInfo[step.objectId!!] == true {
                    return 2
                }
            }
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let tripSteps = self.steps {
            let step = tripSteps[section] as! TripStep
            return "\(step.locationStart) -> \(step.locationDestination)"
        }
        return "STEP"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let stepInfoCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("stepInfoCell", forIndexPath: indexPath)
//        if let trips = self.trips {
//            let trip = trips[indexPath.row] ;
//            tripCell.detailTextLabel!.text = trip.note
//            tripCell.textLabel!.text = trip.title
//        }
        
        return stepInfoCell;
    }
    
    @IBAction func onBackToTrips(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier;
        if identifier == "editTripSegue" {
            let saveTripViewController = segue.destinationViewController as! SaveTripViewController
            if let trip = self.currentTrip {
                saveTripViewController.currentTrip = trip
            }
        }
    }
}
