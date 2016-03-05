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
    var currentTripStep: TripStep?
    
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var tripTitle: UILabel!
    @IBOutlet weak var publicImageView: UIImageView!
    
    @IBOutlet weak var tripLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tripLabel.layer.masksToBounds = true
        self.tripLabel.layer.cornerRadius = 5;
        
        self.stepsLabel.layer.masksToBounds = true
        self.stepsLabel.layer.cornerRadius = 5;

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchTrip()
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
    
    func fetchTrip() {
        if let trip = self.currentTrip {
            trip.fetchIfNeededInBackgroundWithBlock({ (trip, error) -> Void in
                if (error == nil) {
                    self.currentTrip = trip as? Trip
                    self.fetchTripSteps()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSelectorOnMainThread("initUI", withObject: nil, waitUntilDone: false)
                    })
                }
            })
        }
    }
    
    func fetchTripSteps() {
        if let trip = self.currentTrip {
            trip.fetchStepsInBacground({ (steps, error) -> Void in
                if (error == nil) {
                    self.steps = steps
                    self.stepsTableView.reloadData()
                }
            })
        }
    }
    
    // Table view delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let steps = self.steps {
            return steps.count
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let stepInfoCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("stepInfoCell", forIndexPath: indexPath)
        if let steps = self.steps {
            let step = steps[indexPath.row] as! TripStep;
            stepInfoCell.detailTextLabel!.text = step.note
            stepInfoCell.textLabel!.text = step.summary
        }
        return stepInfoCell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.currentTripStep = nil;
        
        if let steps = self.steps {
            self.currentTripStep = steps[indexPath.row] as? TripStep
            self.performSegueWithIdentifier("saveTripStepSegue", sender: self)
        }
    }
    
    
    @IBAction func onNewStep(sender: AnyObject) {
        self.currentTripStep = nil;
        self.performSegueWithIdentifier("saveTripStepSegue", sender: self)
    }
    
    @IBAction func onBackToTrips(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier;
        switch (identifier!) {
            case "editTripSegue":
                let saveTripViewController = segue.destinationViewController as! SaveTripViewController
                if let trip = self.currentTrip {
                    saveTripViewController.currentTrip = trip
                }
            break
            case "saveTripStepSegue":
                let tripStepViewController = segue.destinationViewController as! TripStepViewController
                if let currentTripStep = self.currentTripStep {
                    tripStepViewController.currentStep = currentTripStep
                }
                else {
                    tripStepViewController.currentStep = TripStep.init(trip: self.currentTrip!)
                }
                
                break
            default:
                break
        }
        
    }
}