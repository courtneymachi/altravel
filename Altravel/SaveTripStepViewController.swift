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

class SaveTripStepViewController: UIViewController, GMSAutocompleteViewControllerDelegate {
    
//IBOutlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var currentStep: TripStep?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    func initUI() {
        if let tripStep = self.currentStep {
            if tripStep.objectId != nil {
                self.titleTextField.text = tripStep.summary
                self.descriptionTextField.text = tripStep.note
                self.locationTextField.text = tripStep.originPlace
            }
        }
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
        print("Place attributions: ", place.attributions)
        
        if let locationTextField = self.locationTextField {
            locationTextField.text = "\(place.name)"
            if let currentStep = self.currentStep {
                currentStep.originPlace = place.name
                currentStep.originPlaceId = place.placeID
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
            currentStep.summary = self.titleTextField.text
            currentStep.note = self.descriptionTextField.text
            
            if (currentStep.originPlace == nil) {
                if let locationTextField = self.locationTextField {
                    currentStep.originPlace = locationTextField.text
                    currentStep.originPlaceId = NSUUID().UUIDString
                }
            }
            
            currentStep.saveEventually { (success, error) -> Void in
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
  
    
}






