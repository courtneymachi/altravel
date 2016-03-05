//
//  TripStepViewController.swift
//  Altravel
//
//  Created by courtney machi on 3/4/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import UIKit
import Parse

class TripStepViewController: UIViewController, NavigationListDelegate {
    
//IBOutlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var currentStep: TripStep?
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func pickEntity(entity: NSDictionary) {
        let location = Location(data: entity)
        // Update parse location
        self.locationTextField?.text = "\(location.city!)"
    }
    
    

    @IBAction func saveButtonTapped(sender: UIButton) {
        self.currentStep?.summary = self.titleTextField.text
        self.currentStep?.locationStart = self.locationTextField.text
        self.currentStep?.note = self.descriptionTextField.text
        
        if let step = self.currentStep {
            step.saveEventually { (success, error) -> Void in
                if (error != nil) {
                    NSLog("Error while saving the step \(error)")
                    let alertController = UIAlertController(title: "Error", message: "Error saving step.", preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                        // do something else
                    }
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true,  completion: { () -> Void in
                        
                    })
                }
                else {
                    if (success) {
                        let alertController = UIAlertController(title: "Success!", message: "Trip step saved successfully.", preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                            if let navigationController = self.navigationController {
                                navigationController.popToRootViewControllerAnimated(true)
                            }
                            else {
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        }
                        alertController.addAction(cancelAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            }

        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indetifier = segue.identifier {
            switch indetifier {
            case "locationPickSegue":
                let destinationViewController = segue.destinationViewController as! CitySearchViewControoler
                destinationViewController.delegate = self;
                break
            default:
                // do nothing
                break
            }
        }
        
    }
    
  
    
}






