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

class SaveTripViewController: UIViewController, UITextFieldDelegate {
    
    var date: NSDate!
    var currentDateField: UITextField?
    var currentTrip: Trip?
    
    
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
        super.viewWillAppear(animated)
        self.currentDateField = startDateField
        self.date = NSDate()
        displayDate(self.date)
    }
    
    func initUI() {
        if let trip = self.currentTrip {
            if trip.objectId != nil { // the object was previsouly saved
                // fetch details in UI
                self.tripNameField.text = trip.title
                self.tripDetailsField.text = trip.note
                
                let formatter = NSDateFormatter()
                formatter.dateStyle = .MediumStyle
                
                self.startDateField.text = formatter.stringFromDate(trip.starting)
                self.endDateField.text = formatter.stringFromDate(trip.ending)
                
                self.isPublicSwitch.setOn(trip.isPublic, animated: true)
            }
        }
    }

    
    // IBActions
    @IBAction func saveButtonTapped(sender: UIButton) {
        if let trip = self.currentTrip {
            trip.title = tripNameField.text
            trip.note = tripDetailsField.text
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            trip.starting = formatter.dateFromString(startDateField.text!)!
            trip.ending = formatter.dateFromString(endDateField.text!)!
            trip.isPublic = self.isPublicSwitch.on
            trip.saveEventually { (success, error) -> Void in
                if (error != nil) {
                    NSLog("Error while saving the trip \(error)")
                    let alertController = UIAlertController(title: "Trip", message: "Error saving trip.", preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                        // do something else
                    }
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true, completion: { () -> Void in
                        
                    })
                }
                else {
                    if (success) {
                        let alertController = UIAlertController(title: "Trip", message: "Trip saved correctly.", preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { (action) in
                            if let navigationController = self.navigationController {
                                navigationController.popToRootViewControllerAnimated(true)
                            }
                        }
                        alertController.addAction(cancelAction)
                        self.presentViewController(alertController, animated: true, completion: { () -> Void in
                            
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
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
        displayDate(sender.date)
    }
    
    func displayDate(date: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        self.currentDateField!.text = formatter.stringFromDate(date)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // dispose of any resources that can be recreated.
    }
    


    
}