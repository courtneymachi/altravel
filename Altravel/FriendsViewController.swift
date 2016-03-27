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

class FriendsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var friendsUserProperties: Array<UserProperty>?
    var currentFriendUserProperty: UserProperty?
    
    @IBOutlet weak var friendTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        DataCollector.sharedInstance.anyView("Friends")
        super.viewWillAppear(animated)
        self.fetchFriends()
    }
    
    func fetchFriends() {
        if let currentUser:PFUser = PFUser.currentUser() {
            currentUser.fetchFriendsPropertiesInBacground({ (friendsUserProperties, error) -> Void in
                if (error == nil) {
                    self.friendsUserProperties = friendsUserProperties as? Array<UserProperty>;
                    self.friendTableView.reloadData()
                }
                else {
                    NSLog("Error retrieving friends \(error!)")
                }
            });
            
        }
    }
    
    // Table view delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let friendsUserProperties = self.friendsUserProperties {
            return friendsUserProperties.count
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let friendCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath)
        if let friendsUserProperties = self.friendsUserProperties {
            let friendUserProperty = friendsUserProperties[indexPath.row]
            friendCell.textLabel!.text = friendUserProperty.firstName
            friendCell.detailTextLabel!.text = friendUserProperty.place
        }
    
        return friendCell;
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.currentFriendUserProperty = nil
        if let friendsUserProperties = self.friendsUserProperties {
            self.currentFriendUserProperty = friendsUserProperties[indexPath.row]
            self.performSegueWithIdentifier("showProfileSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier!;
        switch identifier {
        case "showProfileSegue":
            let destinationViewController = segue.destinationViewController as! ProfileViewController
            destinationViewController.currentUserProperty = self.currentFriendUserProperty
            break
        default:
            break;
        }
    }
}

