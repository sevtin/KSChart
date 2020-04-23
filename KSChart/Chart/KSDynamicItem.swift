//
//  KSDynamicItem.swift
//  KSChart
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSDynamicItem: NSObject, UIDynamicItem {
    
    var center: CGPoint              = KS_Chart_Point_Zero
    var bounds: CGRect               = CGRect(x: 0, y: 0, width: 1, height: 1)
    var transform: CGAffineTransform = CGAffineTransform.identity
    
}
