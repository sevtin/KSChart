//
//  UILabel+KSExtensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

extension UILabel {
    
    convenience init(textFont: UIFont, alignment: NSTextAlignment) {
        self.init()
        ks_update(textFont: textFont, alignment: alignment)
    }
    
    convenience init(textColor: UIColor, textFont: UIFont, alignment: NSTextAlignment) {
        self.init()
        ks_update(textColor: textColor, textFont: textFont, alignment: alignment)
    }

    func ks_update(textColor: UIColor, textFont: UIFont, alignment: NSTextAlignment) {
        ks_update(textFont: textFont, alignment: alignment)
        self.textColor = textColor
    }
    
    func ks_update(textFont: UIFont, alignment: NSTextAlignment) {
        self.font                      = textFont
        self.textAlignment             = alignment
        self.adjustsFontSizeToFitWidth = true
        self.numberOfLines             = 0
    }
}
