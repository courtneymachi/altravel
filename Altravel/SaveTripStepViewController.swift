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

import GoogleMaps

class SaveTripStepViewController: BaseViewController, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var currentStep: TripStep?
    
    var isNewStep: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentStep = self.currentStep {
            self.isEditable = ACLValidator.sharedInstance.isEditable(currentStep)
        }
        
        self.initUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func initUI() {
        self.customKeyboard(textField: self.titleTextField)
        self.customKeyboard(textField: self.descriptionTextField)
        
        if let tripStep = self.currentStep {
            if tripStep.objectId != nil { // step exists
                self.isNewStep = false
                self.titleTextField.text = tripStep.summary
                self.descriptionTextField.text = tripStep.note
                self.locationButton.setTitleForAllStates(tripStep.originPlace)
                
                if (self.isEditable) {
                    self.titleTextField.enabled = true
                    self.descriptionTextField.enabled = true
                    self.locationButton.enabled = true
                    self.saveButton.hidden = false
                    self.cancelButton.setTitleForAllStates("Cancel")
                }
                else {
                    self.titleTextField.enabled = false
                    self.descriptionTextField.enabled = false
                    self.locationButton.enabled = false
                    self.saveButton.hidden = true
                    self.cancelButton.setTitleForAllStates("Close")
                }
            }
            else {
                self.isNewStep = true
            }
        }
    }
    
    func onKeyboardDone() {
        self.descriptionTextField.resignFirstResponder()
        self.titleTextField.resignFirstResponder()
    }

    
    @IBAction func onLocationClickButton(sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
    }
    
    // Google Places delegate
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place location: ", place.coordinate)
        print("Place attributions: ", place.attributions)
        
        
        if let locationButton = self.locationButton {
            locationButton.setTitleForAllStates("\(place.name)")
            if let currentStep = self.currentStep {
                currentStep.originPlace = place.name
                currentStep.originPlaceId = place.placeID
                currentStep.coordinates = PFGeoPoint.init(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

    @IBAction func saveButtonTapped(sender: UIButton) {
        if let currentStep = self.currentStep {
            
            var validTrip = true
            var errors = Dictionary<String, String>()
            
            
            if self.titleTextField.text == nil || self.titleTextField.text! == "" {
                validTrip = false;
                errors["name"] = "Step name is required"
            }
            else {
                currentStep.summary = self.titleTextField.text!
            }
            
            currentStep.note = self.descriptionTextField.text
            
            
            if (currentStep.originPlace == nil) {
                if let locationButton = self.locationButton {
                    currentStep.originPlace = locationButton.titleLabel?.text
                    currentStep.originPlaceId = NSUUID().UUIDString
                }
            }
            
            if (validTrip) {
                currentStep.saveEventually { (success, error) -> Void in
                    if (error != nil) {
                        self.isNewStep ? DataCollector.sharedInstance.addStep(false) : DataCollector.sharedInstance.editStep(false)
                        NSLog("Error while saving the step \(error)")
                        let alertController = UIAlertController(title: "Error", message: "Error saving step.", preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                            // do something else
                        }
                        alertController.addAction(cancelAction)
                        self.presentViewController(alertController, animated: true,  completion: nil)
                    }
                    else {
                        if (success) {
                            let alertController = UIAlertController(title: "Success!", message: "Trip step saved successfully.", preferredStyle: .Alert)
                            self.isNewStep ? DataCollector.sharedInstance.addStep(true) : DataCollector.sharedInstance.editStep(true)
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
            else {
                // TODO: extract error messages
                var feedback: String = "Errors: "
                for (_, message) in errors {
                    feedback += "\(message) "
                }
                
                let alertController = UIAlertController(title: "Trip", message: feedback, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                    // do something else
                }
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
            
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        DataCollector.sharedInstance.cancelStep()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier;
        switch (identifier!) {
        case "addTripStepToTripSegue":
            let addTripStepToTripViewController = segue.destinationViewController as! CopyTripStepViewController
            if let currentStep = self.currentStep {
                addTripStepToTripViewController.currentTripStep = currentStep
            }
            break
        default:
            break
        }
        
    }
  
    
}






