//
//  TripViewController.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 2/28/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import UIKit
import Parse
import Crashlytics

class TripViewController : BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var currentTrip: Trip?
    var steps: NSArray?
    var currentTripStep: TripStep?
    var userFavorite: UserFavorite?
    
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var tripTitle: UILabel!
    @IBOutlet weak var publicImageView: UIImageView!
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var newStepButton: UIButton!

    @IBOutlet weak var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        self.tripTitle.layer.masksToBounds = true
        self.tripTitle.layer.cornerRadius = 5;
        
        self.stepsLabel.layer.masksToBounds = true
        self.stepsLabel.layer.cornerRadius = 5;
        
        if let currentTrip = self.currentTrip {
            self.isEditable = ACLValidator.sharedInstance.isEditable(currentTrip)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        DataCollector.sharedInstance.anyView("Trip")
        super.viewWillAppear(animated)
        self.fetchTrip()
        self.fetchFavoriteTrip()
    }
    
    func initUI() {
        if let trip = self.currentTrip {
            if self.isEditable {
                self.newStepButton.hidden = true
                self.editButton.hidden = true
            }
            else {
                self.newStepButton.hidden = false
                self.editButton.hidden = false
            }
            
            self.tripTitle.text = trip.title
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            if let startDate = trip.starting {
            
                if let endDate = trip.ending {
                        self.datesLabel.text = "\(formatter.stringFromDate(startDate)) to \(formatter.stringFromDate(endDate))"
                }
            }
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
    
    func fetchFavoriteTrip() {
        if let user = PFUser.currentUser() {
            if let trip = self.currentTrip {
                user.fetchFavoriteForTrip(trip, block: { (userFavorite, error) -> Void in
                    if let favorite = userFavorite {
                        self.userFavorite = favorite
                        if favorite.isArchived == false {
                            let favoriteButton = self.favoriteButton
                            favoriteButton.setImage(UIImage(named: "favorite_on"), forState: .Normal)
                        }
                    }
                })
            }
            
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

    @IBAction func onFavoriteTrip(sender: AnyObject) {
        if let currentTrip = self.currentTrip {
            if let user = PFUser.currentUser() {
                if let userFavorite = self.userFavorite {
                    userFavorite.isArchived = !userFavorite.isArchived
                    userFavorite.saveEventually({ (success, error) -> Void in
                        var message: String
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                        if (error == nil && success == true) {
                            let favoriteButton = self.favoriteButton
                            if userFavorite.isArchived == false {
                                message = "Trip added to your favorites."
                                favoriteButton.setImage(UIImage(named: "favorite_on"), forState: .Normal)
                                DataCollector.sharedInstance.favoriteTrip(true, friendTrip: !self.isEditable)
                            }
                            else {
                                message = "Trip removed from your favorites."
                                favoriteButton.setImage(UIImage(named: "favorite"), forState: .Normal)
                                DataCollector.sharedInstance.unfavoriteTrip(true, friendTrip: !self.isEditable)
                            }
                        }
                        else {
                            message = "Error while updating your profile."
                            if userFavorite.isArchived {
                                DataCollector.sharedInstance.unfavoriteTrip(false, friendTrip: !self.isEditable)
                            }
                            else {
                                DataCollector.sharedInstance.favoriteTrip(false, friendTrip: !self.isEditable)
                            }
                        }
                        let alertController = UIAlertController(title: "Trip", message: message, preferredStyle: .Alert)
                        alertController.addAction(cancelAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })

                }
                else {
                    let userFavorite = UserFavorite.init(user: user, trip: currentTrip)
                    userFavorite.saveEventually({ (success, error) -> Void in
                        let message: String
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
                        if (error == nil && success == true) {
                            message = "Trip added to your favorites."
                            
                            let favoriteButton = self.favoriteButton
                            favoriteButton.setImage(UIImage(named: "favorite_on"), forState: .Normal)
                            DataCollector.sharedInstance.favoriteTrip(true, friendTrip: !self.isEditable)
                        }
                        else {
                            message = "Error while adding trip to your favorites."
                            DataCollector.sharedInstance.favoriteTrip(false, friendTrip: !self.isEditable)
                            
                        }
                        let alertController = UIAlertController(title: "Trip", message: message, preferredStyle: .Alert)
                        alertController.addAction(cancelAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                }
            }
            
        }
        
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
                    if let trip = self.currentTrip {
                        tripStepViewController.currentStep = TripStep.init(trip: trip)
                    }
                }
                break
            case "showMapSegue":
                let mapViewController = segue.destinationViewController as! MapViewController
                mapViewController.steps = self.steps
            default:
                break
        }
        
    }
}
