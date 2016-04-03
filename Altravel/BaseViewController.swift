//
//  BaseViewController.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 3/27/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import UIKit
import Parse

class BaseViewController : UIViewController {

    // This will validate whther the user has the permission to edit the current page object
    var isEditable: Bool = false
    
    
    func customKeyboard(textView textView: UITextView) {
        // generate new custom accessory view for uitextview
        let customToolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        customToolbar.barStyle = .Default
        customToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "onKeyboardDone")]
        customToolbar.sizeToFit()
        textView.inputAccessoryView = customToolbar
    }
    
    func customKeyboard(textField textField: UITextField) {
        // generate new custom accessory view for uitextview
        let customToolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        customToolbar.barStyle = .Default
        customToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "onKeyboardDone")]
        customToolbar.sizeToFit()
        textField.inputAccessoryView = customToolbar
    }
    
}
