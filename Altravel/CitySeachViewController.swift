//
//  CitySeachViewController.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 1/23/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4;

class CitySearchViewControoler: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var cityTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        NSLog("%@", searchText)
        // update table view
    }
    
    // Tbale view delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell();
    }
}
