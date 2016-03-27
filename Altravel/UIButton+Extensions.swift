//
//  UIButton+Extensions.swift
//  Altravel
//
//  Created by Giuseppe Macrì on 3/26/16.
//  Copyright © 2016 courtney machi. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setTitleForAllStates(title: String?) {
        self.setTitle(title, forState: .Normal)
        self.setTitle(title, forState: .Highlighted)
        self.setTitle(title, forState: .Selected)
        self.setTitle(title, forState: .Application)
        self.setTitle(title, forState: .Focused)
    }
}
