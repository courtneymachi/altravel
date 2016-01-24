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

  
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
//        let blurView = UIVisualEffectView(effect: blurEffect)
//        blurView.frame = backgroundImg.bounds
//        backgroundImg.addSubview(blurView)
//        backgroundImg.frame = CGRectMake(0, 0, 100, 100)
        
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


