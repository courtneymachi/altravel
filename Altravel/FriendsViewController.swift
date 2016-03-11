//
//  FriendsViewController.swift
//  Altravel
//
//  Created by courtney machi on 3/7/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import Parse
import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var friends: Array<PFUser>?
    
    @IBOutlet weak var friendTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchFriends()
    }
    
    func fetchFriends() {
        if let currentUser:PFUser = PFUser.currentUser() {
            currentUser.fetchAllUsersExpectCurrentOne(PFUser.currentUser(), block: { (users, error) -> Void in
                if (error == nil) {
                    self.friends = users as? Array<PFUser>;
                    self.friendTableView.reloadData()
                }
                else {
                    NSLog("Error retrieving friends \(error!)")
                }
            })
        }
    }
    
    // Table view delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let friends = self.friends {
            return friends.count
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let friendCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath)
        if let friends = self.friends {
            let friend = friends[indexPath.row] 
            friendCell.detailTextLabel!.text = friend.objectId
            friendCell.textLabel!.text = friend.username
        }
    
        return friendCell;
    }
        
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.currentTripStep = nil;
//        
//        if let steps = self.steps {
//            self.currentTripStep = steps[indexPath.row] as? TripStep
//            self.performSegueWithIdentifier("saveTripStepSegue", sender: self)
        }
    }
    
        
