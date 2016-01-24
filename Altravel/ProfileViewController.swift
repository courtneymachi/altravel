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

class ProfileViewController: UIViewController, UISearchBarDelegate {
    
    var property:UserProperty?
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfileView: UIImageView!
    @IBOutlet weak var profileInputField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let currentUser:PFUser = PFUser.currentUser() {
            NSLog("current user %@", currentUser)
            currentUser.fetchPropertiesInBacground({(userProperties, error) -> Void in
                if (error != nil) {
                    NSLog("Error retrieving user properties %@", error!)
                }
                else {
                    if let properties = userProperties {
                        if (properties.count > 0) {
                            // User property already exist
                            self.property = properties[0] as? UserProperty
                            if let property = self.property {
                                if let profile = property.profile {
                                    self.profileInputField.text = profile
                                }
                            }
                        }
                        else {
                            // we need to generate a new user property and store it
                            self.property = UserProperty(user: currentUser)
                            self.property?.saveEventually()
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
    
}