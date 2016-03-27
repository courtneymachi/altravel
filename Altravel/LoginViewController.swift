//
//  ViewController.swift
//  Altravel
//
//  Created by courtney machi on 10/31/15.
//  Copyright © 2015 courtney machi. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import QuartzCore;

class LoginViewController: BaseViewController {

    var userProperty: UserProperty?
  
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.layer.masksToBounds = true
        self.titleLabel.layer.cornerRadius = self.titleLabel.frame.size.height / 2;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        DataCollector.sharedInstance.anyView("Login")
        super.viewWillAppear(animated);
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.currentUser() != nil {
            if let user = PFUser.currentUser() {
                if PFFacebookUtils.isLinkedWithUser(user) {
                    self.fetchUserInfo()
                }
            }
            
        }
    }
    

    @IBAction func onLogin(sender: UIButton) {
        let permissions = ["public_profile"]
            
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            
            if (error == nil) {
                if user != nil {
                    DataCollector.sharedInstance.loginAttempt(true)
                    NSLog("User logged in through facebook");
                    //move to the next scene
                    
                    self.fetchUserInfo()
                    
                }
                else {
                    NSLog("User cancelled");
                    DataCollector.sharedInstance.loginAttempt(false)
                    if PFUser.currentUser() != nil {
                        self.fetchUserInfo()
                    }
                }   
            }
            else {
                DataCollector.sharedInstance.loginAttempt(false)
                NSLog("%s", error!)
            }
        }

    }
    
    func fetchUserInfo() {
        if let currentUser:PFUser = PFUser.currentUser() {
            
            currentUser.fetchPropertiesInBacground({(userProperty, error) -> Void in
                if (error != nil) {
                    NSLog("Error retrieving user properties \(error!)")
                }
                else {
                    let request = FBSDKGraphRequest.init(graphPath: "me", parameters:["fields": "id, first_name, last_name"])
                    
                    request.startWithCompletionHandler { (connection, userInfo, error) -> Void in
                        if ((error == nil)) {
                            
                            if let property = userProperty {
                            
                                if let firstName = userInfo["first_name"] as? String {
                                    if property.firstName != firstName {
                                        property.firstName = firstName
                                    }
                                }
                                
                                if let lastName = userInfo["last_name"] as? String {
                                    if property.lastName != lastName {
                                        property.lastName = lastName
                                    }
                                }
                                
                                if let fbId = userInfo["id"] as? String {
                                    if property.facebookId != fbId {
                                        property.facebookId = fbId
                                    }
                                }
                                
                                if property.dirty {
                                    property.saveEventually({ (success, error) -> Void in
                                        if error != nil {
                                            NSLog("Error saving first or last name: \(error)")
                                        }
                                        else {
                                            if success == false {
                                                NSLog("Saving first or last name: no errors but not able to update value");
                                                self.userProperty = property;
                                                self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
                                            }
                                        }
                                    })
                                }
                                else {
                                    self.userProperty = property;
                                    self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
                                }
                            }
                            else {
                                // we need to generate a new user property and store it
                                let property = UserProperty(user: currentUser)
                                
                                if let firstName = userInfo["first_name"] as? String {
                                    property.firstName = firstName
                                }
                                
                                if let lastName = userInfo["last_name"] as? String {
                                    property.lastName = lastName
                                }
                                
                                if let fbId = userInfo["id"] as? String {
                                    property.facebookId = fbId
                                }
                                
                                property.saveEventually({ (success, error) -> Void in
                                    if error != nil {
                                        NSLog("Error saving description: \(error)")
                                    }
                                    else {
                                        if success == false {
                                            self.userProperty = property;
                                            self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
                                            NSLog("Saving description: no errors but not able to update value");
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier!;
        switch identifier {
        case "loginSuccessSegue":
            let destinationViewController = segue.destinationViewController as! UITabBarController
            if let tabControllers = destinationViewController.viewControllers {
                let navigationController: UINavigationController = tabControllers[0] as! UINavigationController
                
                let navigationControllerChildren = navigationController.viewControllers
                let profileViewController: ProfileViewController = navigationControllerChildren[0] as! ProfileViewController
                profileViewController.currentUserProperty = self.userProperty
                NSLog("\(profileViewController)");
                
            }
            break
        default:
            break;
        }
    }
}


