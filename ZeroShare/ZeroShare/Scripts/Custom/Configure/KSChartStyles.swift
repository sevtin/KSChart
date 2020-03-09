//
//  ChartStyles.swift
//  CHKLineChart
//
//  Created by Chance on 2017/6/12.
//  Copyright © 2017年 atall.io. All rights reserved.
//

import UIKit

class KSStyleParam: NSObject, Codable {
    
    var theme: String           = ""//风格名，Dark，Light

    var showYAxisLabel          = "right"

    var candleColors            = "Green/Red"

    var backgroundColor: UInt   = 0x232732

    var textColor: UInt         = 0xcccccc

    var selectedTextColor: UInt = 0xcccccc

    var lineColor: UInt         = 0x333333

    var upColor: UInt           = 0x00bd9a

    var downColor: UInt         = 0xff6960

    var lineColors: [UInt] = [
        0xDDDDDD,
        0xF9EE30,
        0xF600FF,
    ]
    
    var isInnerYAxis: Bool = false
    
    static var styleParams: KSStyleParam {
        let style               = KSStyleParam()
        style.theme             = "Light"//风格名，Dark，Light
        style.candleColors      = "Green/Red"
        style.showYAxisLabel    = "right"
        style.isInnerYAxis      = false
        style.backgroundColor   = 0xFFFFFF
        style.textColor         = 0x9AA2B3
        style.selectedTextColor = 0xFFFFFF
        style.lineColor         = 0xE8E8E8
        style.upColor           = 0x3BC086
        style.downColor         = 0xF5476A
        style.lineColors        = [
            0xF2D318,
            0xB620E0,
            0x32C5FF,
        ]
        style.isInnerYAxis      = false
        return style
    }
}
