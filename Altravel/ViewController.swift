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
        PFFacebookUtils.logInInBackgroundWithReadPermissions(nil, block: { (user, error) -> Void in
            if ((error == nil)) {
                if (user == nil) {
                    NSLog("User cancelled the facebook login");
                }
                else if ((user?.isNew) != nil) {
                    NSLog("User signed up and logged in through facebook");
                }
                else {
                    NSLog("User logged in through facebook");
                }
            }
            else {
                NSLog("%s", error!)
            }
        })
    }

}

