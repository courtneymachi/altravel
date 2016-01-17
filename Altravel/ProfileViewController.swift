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

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters:nil)
    
        request.startWithCompletionHandler { (connection, userInfo, error) -> Void in
            
            //TODO store the facebook id
            if ((error == nil)) {
                if let name = userInfo["name"] as? String {
                    self.userNameLabel.text = "\(name)"
                }

                if let fbID = userInfo["id"] as? String {
                    NSLog("captured facebook id")
                    NSLog("%s", fbID)
                }
            }
            
        }
        
    }
    
    
    
}