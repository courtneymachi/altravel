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
    
    var trips: NSArray?
    var currentTrip: Trip?
    var currentUserProperty: UserProperty?
    
    var firstName: String?
    var lastName: String?
    
    var isAFriend: Bool = false
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfileView: UIImageView!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var tripTableView: UITableView!
    @IBOutlet weak var profileTextArea: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.userNameLabel.layer.masksToBounds = true
        self.userNameLabel.layer.cornerRadius = 5;
        
        self.profileTextArea.layer.masksToBounds = true
        self.profileTextArea.layer.cornerRadius = 5;
        
        if let property = self.currentUserProperty {
            
            if let propertyACL = property.ACL {
                if let currentUser = PFUser.currentUser() {
                    if propertyACL.getWriteAccessForUser(currentUser) {
                        self.isAFriend = false;
                    }
                    else {
                        self.isAFriend = true;
                    }
                }
            }
        }
        
        self.diplayUserInfo()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchFavoriteTrips()
    }
    
    func fetchUserInfo() {
        if let property = self.currentUserProperty {
            property.fetchInBackgroundWithBlock({ (userProperty, error) -> Void in
                self.diplayUserInfo()
            })
        }
    }
    
    func diplayUserInfo() {
        if let property = self.currentUserProperty {
            
            if self.isAFriend {
                self.closeButton.hidden = false;
                if let cityButton: UIButton = self.cityButton {
                    cityButton.enabled = false;
                }
                self.profileTextArea.editable = false;
            }
            else {
                self.closeButton.hidden = true;
                if let cityButton: UIButton = self.cityButton {
                    cityButton.enabled = true;
                }
                self.profileTextArea.editable = true;
            }
            
            if let profile = property.profile {
                self.profileTextArea.text = profile
            }
            if let city = property.place {
                if let cityButton: UIButton = self.cityButton {
                    cityButton.setTitleForAllStates(city)
                }
            }
            if let firstName = property.firstName {
                self.userNameLabel.text = "Hello, I'm \(firstName)"
            }
            
            
            if let fbID = property.facebookId {
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

    func fetchFavoriteTrips() {
        if let userProperty = self.currentUserProperty {
            if let currentUser:PFUser = userProperty.user {
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
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if let property = self.currentUserProperty {
            if let description = self.profileTextArea.text {
                property.profile = description
                property.saveEventually()
                property.saveEventually({ (success, error) -> Void in
                    if (error != nil) {
                        let alertController = UIAlertController(title: "Profile", message: "Error saving profile.", preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.presentViewController(alertController, animated: true,  completion: nil)
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
        
        if let property = self.currentUserProperty {
            property.place = place.name
            property.placeId = place.placeID
            
            property.saveEventually({ (success, error) -> Void in
                if (error != nil) {
                    let alertController = UIAlertController(title: "Profile", message: "Error saving profile.", preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true,  completion: nil)
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
            let tripObject:NSObject? = trips[indexPath.row] as? NSObject
            if tripObject != nil {
                let trip = trips[indexPath.row] as! Trip;
                tripCell.detailTextLabel!.text = trip.note
                tripCell.textLabel!.text = trip.title
            }
            else {
                tripCell.detailTextLabel!.text = "UNKNOWN"
                tripCell.textLabel!.text = "UNKNOWN"
            }
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
    
    func isModal() -> Bool {
        if self.presentingViewController != nil {
            return true
        }
        
        if self.presentingViewController?.presentedViewController == self {
            return true
        }
        
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        }
        
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }

    @IBAction func onCloseButton(sender: AnyObject) {
        if self.isModal() {
            self.dismissViewControllerAnimated(true, completion: nil)
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