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

class ViewController: UIViewController {

    var firstName: String?
    var lastName: String?
    var id: String?
  
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
        super.viewWillAppear(animated);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.currentUser() != nil {
            if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
                self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
            }
        }
    }
    

    @IBAction func onLogin(sender: UIButton) {
        let permissions = ["public_profile"]
            
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            
            if (error == nil) {
                if user != nil {
                    
                    NSLog("User logged in through facebook");
                    //move to the next scene
                    
                    let request = FBSDKGraphRequest.init(graphPath: "me", parameters:["fields": "id, first_name, last_name"])
                    
                    request.startWithCompletionHandler { (connection, userInfo, error) -> Void in
                        if ((error == nil)) {
                            if let firstName = userInfo["first_name"] as? String {
                                self.firstName = firstName;
                            }
                            
                            if let lastName = userInfo["last_name"] as? String {
                                self.lastName = lastName;
                            }
                            
                            if let fbID = userInfo["id"] as? String {
                                self.id = fbID;
                            }
                            
                        }
                    }

                    
                    self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
                }
                else {
                    NSLog("User cancelled");
                    if PFUser.currentUser() != nil {
                        self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
                    }
                }   
            }
            else {
                NSLog("%s", error!)
            }
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
                profileViewController.currentUser = PFUser.currentUser()
                
            }
            
            
//            destinationViewController.currentUser = PFUser.currentUser()
            break
        default:
            break;
        }
    }
}


