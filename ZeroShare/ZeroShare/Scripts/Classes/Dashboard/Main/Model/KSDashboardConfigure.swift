//
//  KSDashboardConfigure.swift
//  ZeroShare
//
//  Created by saeipi on 2019/9/4.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSDashboardConfigure: NSObject {
    var bid_currency:String   = ""//买
    var ask_currency:String   = ""//卖
    var headerHeight: CGFloat = 434
    var pagerIndex: Int       = 0

    var isSwitch:Bool         = true//切换指标
    var isCurrency:Bool       = false


    var socketVersion:String  = "2"

    var symbol: String        = ""

    //k线
    var kline: String         = "1d"
    var klineCh:String        = ""
    var limit: Int            = 500

    //深度
    var depth:String          = "0"
    var depthCh:String        = ""

    //概要
    var summaryCh             = ""

    //明细
    var detailCh              = ""

    var newConfigure: KSDashboardConfigure!
    
}

class KSDashboardChildConfigure: NSObject {
    var bid_currency:String   = "btc"//买
    var ask_currency:String   = "won"//卖
    
    convenience init(bid: String, ask: String) {
        self.init()
        bid_currency = bid
        ask_currency = ask
    }
    
}
