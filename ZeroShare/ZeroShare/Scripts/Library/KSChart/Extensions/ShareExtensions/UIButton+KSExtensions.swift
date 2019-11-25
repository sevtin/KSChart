//
//  UIButton+KSExtensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit
extension UIButton {
    
    func ks_addTarget(_ target: Any?, action: Selector) {
        addTarget(target, action: action, for: UIControl.Event.touchUpInside)
    }
    
    convenience init(normalImage: String, selectedImage: String) {
        self.init()
        
        setImage(UIImage.init(named: normalImage), for: UIControl.State.normal)
        setImage(UIImage.init(named: selectedImage), for: UIControl.State.selected)
    }
    
    convenience init(title: String, font: UIFont, normalColor: UIColor?, highlightedColor: UIColor, bgNormalColor: UIColor, bgHighlightedColor: UIColor) {
        self.init()
        
        setTitle(String.ks_localizde(title), for: UIControl.State.normal)
        titleLabel?.font = font
        setTitleColor(normalColor, for: UIControl.State.normal)
        setTitleColor(highlightedColor, for: UIControl.State.highlighted)
        setBackgroundImage(UIImage.color(bgNormalColor), for: UIControl.State.normal)
        setBackgroundImage(UIImage.color(bgHighlightedColor), for: UIControl.State.highlighted)
    }
    
    convenience init(title: String, font: UIFont, normalColor: UIColor?, selectedColor: UIColor?) {
        self.init()
        
        setTitle(String.ks_localizde(title), for: UIControl.State.normal)
        titleLabel?.font = font
        setTitleColor(normalColor, for: UIControl.State.normal)
        setTitleColor(selectedColor, for: UIControl.State.selected)
        
    }

    convenience init(title: String, titleColor:UIColor, font: UIFont, backgroundColor: UIColor, borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat) {
        self.init()

        self.backgroundColor = backgroundColor
        setTitle(title, for: UIControl.State.normal)
        setTitleColor(titleColor, for: UIControl.State.normal)
        layer.borderColor    = borderColor.cgColor
        layer.borderWidth    = borderWidth
        layer.cornerRadius   = cornerRadius
        titleLabel?.font     = font
    }
}
