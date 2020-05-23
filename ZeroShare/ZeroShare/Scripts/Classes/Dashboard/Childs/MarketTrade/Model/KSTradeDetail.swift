//
//  KSTradeDetail.swift
//  ZeroShare
//
//  Created by saeipi on 2019/9/9.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit
import SwiftyJSON

class KSTradeDetail: NSObject {
    var timestamp:Int  = 0
    var price: String  = ""
    var amount: String = ""
    var isBuy: Bool    = false
    var displayTexts   = [NSMutableAttributedString]()
    var textColor      = KS_Const_Color_Chart_Up
    var side:Int = 0 {
        didSet{
            var type = String.ks_localizde("ks_app_global_text_buy_up")
            isBuy = (oldValue == 0) ? true : false
            if isBuy == false {
                textColor = KS_Const_Color_Chart_Down
                type = String.ks_localizde("ks_app_global_text_sell_up")
            }
            let space:CGFloat = -0.8
            var font          = KS_Const_Font_Normal_14
            if let _font      = KS_Const_Font_HelveticaNeue_14 {
                font = _font
            }
            let timeAtt       = String.ks_changeSpace(text: Date.ks_formatTimeStamp(timeStamp: timestamp), space: space, font: font, color: KS_Const_Color_Chart_Ink)
            let typeAtt       = String.ks_changeSpace(text: type, space: space, font: font, color: textColor)
            let priceAtt      = String.ks_changeSpace(text: price, space: space, font: font, color: textColor)
            let volumeAtt     = String.ks_changeSpace(text: amount.ks_volume(), space: space, font: font, color: KS_Const_Color_Chart_Ink)
            displayTexts      = [timeAtt,typeAtt,priceAtt,volumeAtt]
            //displayTexts      = [Date.ks_formatTimeStamp(timeStamp: timestamp),type,price,amount.ks_volume()]
        }
    }
    
    class func formatTradeMessage(json: JSON) -> [KSTradeDetail] {
        Date.ks_update(format: "HH:mm:ss")
        var details = [KSTradeDetail]()
        for item in json["b"]["d"].arrayValue {
            let detail       = KSTradeDetail.init()
            detail.timestamp = item["ts"].intValue
            detail.price     = item["p"].stringValue
            detail.amount    = item["a"].stringValue
            detail.side      = item["s"].intValue
            details.append(detail)
        }
        return details
    }
}
