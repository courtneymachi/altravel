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

class ProfileViewController: UIViewController, UISearchBarDelegate, NavigationListDelegate {
    
    var property:UserProperty?
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfileView: UIImageView!
    @IBOutlet weak var profileInputField: UITextField!
    @IBOutlet weak var cityButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let currentUser:PFUser = PFUser.currentUser() {
            currentUser.fetchPropertiesInBacground({(userProperties, error) -> Void in
                if (error != nil) {
                    NSLog("Error retrieving user properties %@", error!)
                }
                else {
                    if let properties = userProperties {
                        if (properties.count > 0) {
                            // User property already exists
                            self.property = properties[0] as? UserProperty
                            if let property = self.property {
                                if let profile = property.profile {
                                    self.profileInputField.text = profile
                                }
                                if let city = property.city {
                                    self.cityButton.titleLabel?.text = city
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
        
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters:nil)
    
        request.startWithCompletionHandler { (connection, userInfo, error) -> Void in
            
            if ((error == nil)) {
                if let name = userInfo["name"] as? String {
                    self.userNameLabel.text = "\(name)"
                }

                if let fbID = userInfo["id"] as? String {
                    NSLog("captured facebook id")
                    NSLog("%@", fbID)
                    
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
    
    @IBAction func onEdit(sender: AnyObject) {
        if self.profileInputField.enabled {
            self.profileInputField.enabled = false;
            // validate if something changed and save user property
            if let property = self.property {
                if let description = self.profileInputField.text {
                    property.profile = description
                    self.property?.saveEventually()
                }
            }
        }
        else {
            self.profileInputField.enabled = true;
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indetifier = segue.identifier {
            switch indetifier {
            case "pickCitySegue":
                let destinationViewController = segue.destinationViewController as! CitySearchViewControoler
                destinationViewController.delegate = self;
                break
            default:
                // do nothing
                break
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
        self.cityButton.titleLabel?.text = "\(location.city!)"
    }
    
}