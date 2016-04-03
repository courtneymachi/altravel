//
//  CreateTripViewController.swift
//  Altravel
//
//  Created by courtney machi on 2/13/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Crashlytics

class SaveTripViewController: BaseViewController, UITextFieldDelegate {
    
    var date: NSDate!
    var currentDateField: UITextField?
    var currentTrip: Trip?
    
    var isNewTrip: Bool = true
    
    @IBOutlet weak var tripNameField: UITextField!
    @IBOutlet weak var tripDetailsField: UITextField!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    @IBOutlet weak var isPublicSwitch: UISwitch!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.startDateField.delegate = self
        self.endDateField.delegate = self
        
        self.date = NSDate()
        self.currentDateField = startDateField
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        startDateField.inputView = datePicker
        endDateField.inputView = datePicker
        datePicker.addTarget(self, action: "datePickerChanged:", forControlEvents: .ValueChanged)
        
        self.initUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        DataCollector.sharedInstance.anyView("Save Trip")
        super.viewWillAppear(animated)
    }
    
    func initUI() {
        
        self.customKeyboard(textField: self.tripNameField)
        self.customKeyboard(textField: self.tripDetailsField)
        self.customKeyboard(textField: self.startDateField)
        self.customKeyboard(textField: self.endDateField)
        
        if let trip = self.currentTrip {
            if trip.objectId != nil { // the object was previously saved
                self.isNewTrip = false
                // fetch details in UI
                self.tripNameField.text = trip.title
                self.tripDetailsField.text = trip.note
                
                let formatter = NSDateFormatter()
                formatter.dateStyle = .MediumStyle
                
                if let startDate = trip.starting {
                    self.startDateField.text = formatter.stringFromDate(startDate)
                }
                
                if let endDate = trip.ending {
                    self.endDateField.text = formatter.stringFromDate(endDate)
                }
                
                self.isPublicSwitch.setOn(trip.isPublic, animated: true)
            }
            else {
                self.isNewTrip = true
            }
        }
    }
    
    func onKeyboardDone() {
        self.tripNameField.resignFirstResponder()
        self.tripDetailsField.resignFirstResponder()
        self.startDateField.resignFirstResponder()
        self.endDateField.resignFirstResponder()
    }

    
    // IBActions
    @IBAction func saveButtonTapped(sender: UIButton) {
        if let trip = self.currentTrip {
            
            var validTrip = true
            var errors = Dictionary<String, String>()
            
            if self.tripNameField.text == nil ||  self.tripNameField.text == "" {
                validTrip = false;
                errors["name"] = "Trip name is required"
            }
            else {
                trip.title = self.tripNameField.text!
            }
            
            trip.note = self.tripDetailsField.text
            trip.isPublic = self.isPublicSwitch.on
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            
            if let startDate = self.startDateField.text {
                trip.starting = formatter.dateFromString(startDate)
            }
            
            if let endDate = self.endDateField.text {
                trip.ending = formatter.dateFromString(endDate)
            }

            
            if let startDate = trip.starting {
                if let endDate = trip.ending {
                    if startDate.compare(endDate) == .OrderedDescending {
                        validTrip = false
                        errors["name"] = "Are you traveling back in time? Please fix dates and try again"
                    }
                }
            }
            
            if (validTrip) {
                
                let requiresStepsUpdate = trip.isDirtyForKey("isPublic");
                
                trip.saveEventually { (success, error) -> Void in
                    if (error != nil) {
                        self.isNewTrip ? DataCollector.sharedInstance.addTrip(false) : DataCollector.sharedInstance.editTrip(false)
                        // TODO need to update all the step ACLs to switch to public/private
                        if requiresStepsUpdate == true {
                            // retrieve all the steps
                            // update ACL for each and every steo
                        }
                        
                        NSLog("Error while saving the trip \(error)")
                        let alertController = UIAlertController(title: "Error", message: "Error saving trip.", preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                            // do something else
                        }
                        alertController.addAction(cancelAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    else {
                        if (success) {
                            let alertController = UIAlertController(title: "Success!", message: "Trip saved successfully.", preferredStyle: .Alert)
                            self.isNewTrip ? DataCollector.sharedInstance.addTrip(true) : DataCollector.sharedInstance.editTrip(true)

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
        DataCollector.sharedInstance.cancelTrip()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // functions
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.isFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing( textField: UITextField) {
        self.currentDateField = textField;
    } 
    
    func datePickerChanged(sender:UIDatePicker) {
        self.displayDate(sender.date)
    }
    
    func displayDate(date: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        self.currentDateField!.text = formatter.stringFromDate(date)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // dispose of any resources that can be recreated.
    }
    


    
}