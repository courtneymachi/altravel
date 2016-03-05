//
//  ProfileViewController.swift
//  Altravel
//
//  Created by courtney machi on 1/17/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4;
import AlamofireImage

class ProfileViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, NavigationListDelegate {
    
    var property:UserProperty?
    var trips:NSArray?
    var currentTrip: Trip?
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfileView: UIImageView!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var tripTableView: UITableView!
    @IBOutlet weak var profileTextArea: UITextView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.userNameLabel.layer.masksToBounds = true
        self.userNameLabel.layer.cornerRadius = 5;
        
        self.profileTextArea.layer.masksToBounds = true
        self.profileTextArea.layer.cornerRadius = 5;
        
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters:["fields": "id, first_name"])
    
        request.startWithCompletionHandler { (connection, userInfo, error) -> Void in
            if ((error == nil)) {
                if let name = userInfo["first_name"] as? String {
                    self.userNameLabel.text = "Hi, I'm \(name)"
                }

                if let fbID = userInfo["id"] as? String {
                    let profileImageURL = NSURL(string: "https://graph.facebook.com/\(fbID)/picture?type=large&return_ssl_resources=1")!
                    
                    let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
                        size: self.userProfileView.frame.size,
                        radius: self.userProfileView.frame.size.width / 2
                    )
                    self.userProfileView.af_setImageWithURL(
                        profileImageURL,
                        filter: filter
                    )
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchUserInfo()
        self.fetchTrips()
    }
    
    func fetchUserInfo() {
        if let currentUser:PFUser = PFUser.currentUser() {
            
            currentUser.fetchPropertiesInBacground({(userProperties, error) -> Void in
                if (error != nil) {
                    NSLog("Error retrieving user properties \(error!)")
                }
                else {
                    if let properties = userProperties {
                        if (properties.count > 0) {
                            // User property already exists
                            self.property = properties[0] as? UserProperty
                            if let property = self.property {
                                if let profile = property.profile {
                                    self.profileTextArea.text = profile
                                }
                                if let city = property.city {
                                    if let cityButton: UIButton = self.cityButton {
                                        cityButton.setTitle(city, forState: .Normal)
                                        cityButton.setTitle(city, forState: .Highlighted)
                                        cityButton.setTitle(city, forState: .Selected)
                                    }
                                }
                            }
                        }
                        else {
                            // we need to generate a new user property and store it
                            self.property = UserProperty(user: currentUser)
                            self.property?.saveEventually({ (result, error) -> Void in
                                if error != nil {
                                    NSLog("Error saving description: \(error)")
                                }
                                else {
                                    if result == false {
                                        NSLog("Saving description: no errors but not able to update value");
                                    }
                                }
                            })
                        }
                    }
                }
            })
            
            
        }
    }
    
    func fetchTrips() {
        if let currentUser:PFUser = PFUser.currentUser() {
            currentUser.fetchTripsInBackground({ (trips, error) -> Void in
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
    
    func textViewDidEndEditing(textView: UITextView) {
        if let property = self.property {
            if let description = self.profileTextArea.text {
                property.profile = description
                self.property?.saveEventually()
                self.property?.saveEventually({ (success, error) -> Void in
                    if (error != nil) {
                        let alertController = UIAlertController(title: "Profile", message: "Error saving profile.", preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                        alertController.addAction(cancelAction)
                    }
                    
                })
            }
        }
    }
    
    
    // NavigationListDelegate delegate
    func pickEntity(entity: NSDictionary) {
        let location = Location(data: entity)
        // Update parse location
        self.property?.city = location.city
        self.property?.cityId = NSNumber(double: location.cityId!)
        self.property?.country = location.country
        self.property?.countryId = location.countryId
        self.property?.saveEventually()
        self.property?.saveEventually({ (success, error) -> Void in
            if (error != nil) {
                let alertController = UIAlertController(title: "Profile", message: "Error saving profile.", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
            }
            else {
                if (success) {
                    if let city = location.city {
                        if let cityButton: UIButton = self.cityButton {
                            cityButton.setTitle(city, forState: UIControlState.Normal)
                            cityButton.setTitle(city, forState: UIControlState.Highlighted)
                            cityButton.setTitle(city, forState: UIControlState.Selected)
                        }
                    }
                }
            }
        })
        
    }
    
    // Table view delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let trips = self.trips {
            return trips.count
        }
        else {
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tripCell = tableView.dequeueReusableCellWithIdentifier("tripCell", forIndexPath: indexPath)
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        self.currentTrip = nil;
        if let trips = self.trips {
            if row < trips.count {
                self.currentTrip = trips[row] as? Trip
                self.performSegueWithIdentifier("showTrip", sender: self)
            }   
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indetifier = segue.identifier {
            switch indetifier {
            case "pickCitySegue":
                let destinationViewController = segue.destinationViewController as! CitySearchViewControoler
                destinationViewController.delegate = self;
                break
            case "showTrip":
                if let trip = self.currentTrip {
                    let destinationViewController = segue.destinationViewController as! TripViewController
                    destinationViewController.currentTrip = trip
                }
                break
            default:
                // do nothing
                break
            }
        }
        
    }
}