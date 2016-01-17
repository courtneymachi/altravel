//
//  ViewController.swift
//  Altravel
//
//  Created by courtney machi on 10/31/15.
//  Copyright © 2015 courtney machi. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4;

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(sender: UIButton) {
        let permissions = ["public_profile"]
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            
                if (error == nil) {
                    if user != nil {
                        NSLog("User logged in through facebook");
                        //move to the next scene
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
}


