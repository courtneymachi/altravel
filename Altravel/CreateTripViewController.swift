//
//  CreateTripViewController.swift
//  Altravel
//
//  Created by courtney machi on 2/13/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import UIKit

class CreateTripViewController: UIViewController, UITextFieldDelegate {
    
    var date: NSDate!
    var currentDateField: UITextField?
    // IBOutlets
    
    
    @IBOutlet weak var tripNameField: UITextField!
    @IBOutlet weak var tripDetailsField: UITextField!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tripNameField.delegate = self
        self.tripDetailsField.delegate = self
        self.startDateField.delegate = self
        self.endDateField.delegate = self
        self.date = NSDate()
        
        self.currentDateField = startDateField
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        startDateField.inputView = datePicker
        endDateField.inputView = datePicker
        datePicker.addTarget(self, action: "datePickerChanged:", forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.currentDateField = startDateField
        self.date = NSDate()
        displayDate(self.date)
    }

    
    // IBActions
    
    @IBAction func saveButtonTapped(sender: UIButton) {
        // TODO: save the trip by creating a new trip page
        dismissViewControllerAnimated(true, completion: nil)
        
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