//
//  NSObject+KSExtensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit
extension NSObject {
    
    func ks_screenWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }

    func ks_screenHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    class func ks_screenWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    class func ks_screenHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
}
