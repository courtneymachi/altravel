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
    var currentTripStep: TripStep?
    
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var tripTitle: UILabel!
    @IBOutlet weak var publicImageView: UIImageView!
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tripTitle.layer.masksToBounds = true
        self.tripTitle.layer.cornerRadius = 5;
        
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
            self.datesLabel.text = "\(formatter.stringFromDate(trip.starting)) to \(formatter.stringFromDate(trip.ending))"
            self.publicImageView.hidden = !trip.isPublic
            self.descriptionLabel.text = trip.note
        }
    }
    
    func fetchTrip() {
        if let trip = self.currentTrip {
            trip.fetchIfNeededInBackgroundWithBlock({ (trip, error) -> Void in
                if (error == nil) {
                    self.fetchTripSteps()
                    self.initUI()
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let steps = self.steps {
                let step: TripStep = steps[indexPath.row] as! TripStep
                step.isArchived = true
                step.saveEventually({ (success, error) -> Void in
                    let message: String
                    let cancelAction: UIAlertAction
                    if (error == nil && success == true) {
                        message = "Step archived correctly."
                        cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                            self.fetchTripSteps()
                        }
                    }
                    else {
                        message = "Error while saving step."
                        cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                    }
                    let alertController = UIAlertController(title: "Trip", message: message, preferredStyle: .Alert)
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                })
            }
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
                let tripStepViewController = segue.destinationViewController as! SaveTripStepViewController
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
