//
//  KSSummaryInfo.swift
//  ZeroShare
//
//  Created by saeipi on 2019/9/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit
import SwiftyJSON

class KSSummaryInfo: KSChartItem {
    
    var localPrice         = ""
    var percentage: String = ""
    var differencePrice    = ""
    var change: Double     = 0
    //var ch:String          = ""

    class func formatSummaryMessage(json: JSON) -> KSSummaryInfo {
        let info             = KSSummaryInfo()
        info.time            = json["b"]["ts"].intValue// 这根K线的起始时间
        info.open            = json["b"]["o"].stringValue// 这根K线期间第一笔成交价
        info.close           = json["b"]["c"].stringValue// 这根K线期间末一笔成交价
        info.high            = json["b"]["h"].stringValue// 这根K线期间最高成交价
        info.low             = json["b"]["l"].stringValue// 这根K线期间最低成交价
        info.volume          = json["b"]["v"].stringValue// 这根K线期间成交量
        info.localPrice      = json["b"]["u"].stringValue

        info.localPrice      = json["b"]["u"].stringValue//美元价
        info.differencePrice = json["b"]["d"].stringValue//价格差 = close - open
        info.change          = Double(info.differencePrice) ?? 0
        info.percentage      = json["b"]["p"].stringValue//价格振幅 = 价格差 / open
        //info.ch              = json["ch"].stringValue
        return info
    }
}
