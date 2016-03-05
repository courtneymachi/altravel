//
//  CitySeachViewController.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 1/23/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import UIKit
import Alamofire


protocol NavigationListDelegate {
    func pickEntity(entity: NSDictionary);
}

class CitySearchViewControoler: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: NavigationListDelegate?
    
    @IBOutlet weak var cityTableView: UITableView!
    var resultSet:NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.fetchCities(searchText)
    }
    
    // Table view delegates
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let citites = self.resultSet {
            return citites.count
        }
        else {
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cityCell = tableView.dequeueReusableCellWithIdentifier("searchCityCell", forIndexPath: indexPath)

        // retrieve json city object
        if let cities = self.resultSet {
            let city = cities[indexPath.row]
            cityCell.detailTextLabel?.text = city["countryName"] as? String
            cityCell.textLabel?.text = city["name"] as? String
        }
        else {
            cityCell.detailTextLabel?.text = "Counrty"
            cityCell.textLabel?.text = "Name"
        }
        
        return cityCell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cities = self.resultSet {
            let city = cities[indexPath.row]
            if (delegate != nil) {
                delegate?.pickEntity(city as! NSDictionary)
                if (self.parentViewController != nil) {
                    let navigationController:UINavigationController = self.parentViewController as! UINavigationController
                    navigationController.popViewControllerAnimated(true)
                }
                else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }

            }
        }
    }
    
    
    // helpers to fetch city names
    func fetchCities(query: String) {
        if query.isEmpty == false {
            let geonamesURLSearchURL:String = "http://api.geonames.org/searchJSON"
            Alamofire.request(.GET, geonamesURLSearchURL, parameters: ["q": query, "maxRows": 10, "username": "altravel"])
                .responseJSON { response in
                    if let JSON = response.result.value {
                        if let geonames = JSON["geonames"] as! NSArray? {
                            self.resultSet = geonames
                            dispatch_async(dispatch_get_main_queue(), {
                                self.cityTableView.reloadData()
                            })
                        }
                    }
            }
        }
    }
}
