//
//  ViewController.swift
//  Altravel
//
//  Created by courtney machi on 10/31/15.
//  Copyright © 2015 courtney machi. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton:FBSDKLoginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        self.view .addSubview(loginButton)
        
        
        
//        let userProfile = PFObject(className:"UserProfile")
//        userProfile["name"] = "Courtney"
//        
//        userProfile.saveInBackground()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

