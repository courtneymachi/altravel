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

import GoogleMaps

class ProfileViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    var property:UserProperty?
    var trips: NSArray?
    var currentTrip: Trip?
    var currentUser: PFUser?
    
    var firstName: String?
    var lastName: String?
    
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
        
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters:["fields": "id, first_name, last_name"])
    
        request.startWithCompletionHandler { (connection, userInfo, error) -> Void in
            if ((error == nil)) {
                if let firstName = userInfo["first_name"] as? String {
                    self.firstName = firstName;
                    self.userNameLabel.text = "Hi, I'm \(firstName)"
                }
                
                if let lastName = userInfo["last_name"] as? String {
                    self.lastName = lastName;
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
        self.fetchUserInfo()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchFavoriteTrips()
    }
    
    func fetchUserInfo() {
       // if let currentUser:PFUser = PFUser.currentUser() {
        if let currentUser:PFUser = self.currentUser {
            
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
                                if let city = property.place {
                                    if let cityButton: UIButton = self.cityButton {
                                        cityButton.setTitle(city, forState: .Normal)
                                        cityButton.setTitle(city, forState: .Highlighted)
                                        cityButton.setTitle(city, forState: .Selected)
                                    }
                                }
                                
                                if property.firstName != self.firstName {
                                    property.firstName = self.firstName
                                }
                                
                                if property.lastName != self.lastName {
                                    property.lastName = self.lastName
                                }
                                
                                if property.isDirtyForKey("lastName") || property.isDirtyForKey("firstName") {
                                   property.saveEventually({ (success, error) -> Void in
                                        if error != nil {
                                            NSLog("Error saving first or last name: \(error)")
                                        }
                                        else {
                                            if success == false {
                                                NSLog("Saving first or last name: no errors but not able to update value");
                                            }
                                        }
                                   })
                                }
                            }
                        }
                        else {
                            // we need to generate a new user property and store it
                            self.property = UserProperty(user: currentUser)
                            self.property?.saveEventually({ (success, error) -> Void in
                                if error != nil {
                                    NSLog("Error saving description: \(error)")
                                }
                                else {
                                    if success == false {
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
    

    func fetchFavoriteTrips() {
        if let currentUser:PFUser = PFUser.currentUser() {
            currentUser.fetchFavoritesInBackground({ (userFavorites, error) -> Void in
                if (error == nil) {
                    if let favorites = userFavorites {
                        let trips = favorites.map({ (favoriteObject) -> Trip in
                            let favorite = favoriteObject as! UserFavorite
                            return favorite.trip
                        })
                        self.trips = trips;
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
    
    
    @IBAction func onPickCityButton(sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
    }

    // Google Places delegate
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if let property = self.property {
            property.place = place.name
            property.placeId = place.placeID
            
            property.saveEventually({ (success, error) -> Void in
                if (error != nil) {
                    let alertController = UIAlertController(title: "Profile", message: "Error saving profile.", preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                }
                else {
                    if (success) {
                        let city = place.name
                        if let cityButton: UIButton = self.cityButton {
                            cityButton.setTitle(city, forState: UIControlState.Normal)
                            cityButton.setTitle(city, forState: UIControlState.Highlighted)
                            cityButton.setTitle(city, forState: UIControlState.Selected)
                        }
                        
                    }
                }
            })
        }
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
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
        return "Favorite Trips";
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        self.currentTrip = nil;
        if let trips = self.trips {
            if row < trips.count {
                self.currentTrip = trips[row] as? Trip
                self.performSegueWithIdentifier("showTripSegue", sender: self)
            }   
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indetifier = segue.identifier {
            switch indetifier {
            case "showTripSegue":
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