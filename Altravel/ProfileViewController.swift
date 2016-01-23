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

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfileView: UIImageView!
    @IBOutlet weak var profileInputField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        if let currentUser:PFUser = PFUser.currentUser() {
//            NSLog("current user %@", currentUser);
//            currentUser.fetchPropertiesInBacground({ (UserProperty, error) -> Void in
//                
//            })
//        }
        
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
        }
        else {
            self.profileInputField.enabled = true;
        }
    }
    
}