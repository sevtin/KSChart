//
//  KSDashboardRequest.swift
//  WonWallet
//
//  Created by saeipi on 2019/9/6.
//  Copyright © 2019 worldopennetwork. All rights reserved.
//

import UIKit
import SwiftyJSON

class KSDashboardRequest: NSObject {
    class func requestKline(market: String, limit: Int, period: String, success: @escaping ((_ result: ([KSChartItem], String, String, String, Int, Bool)) -> Void), failure: @escaping ((_ error: ASRequestError?) -> Void)) {
        var parameters                = [String: Any]()
        parameters["target_currency"] = "usd"
        parameters["limit"]           = limit
        parameters["period"]          = period
        parameters["market"]          = market
        let url                       = KSSingleton.shared.server.httpServer + KSApi_Global_Get_Kline
        
        ASNetManager.request(url: url, method: .get, parameters: parameters, success: { (result: Any?) in
            var candles: [KSChartItem] = [KSChartItem]()
            var market: String = ""
            var period: String = ""
            var precision: Int = 4
            var followed: Bool = false
            var name: String = ""
            if let _result = result {
                let jsonData = JSON(_result)["data"]
                market       = jsonData["market"].stringValue
                period       = jsonData["period"].stringValue
                precision    = jsonData["precision"].intValue
                followed     = jsonData["followed"].boolValue
                name         = jsonData["name"].stringValue
                for json in jsonData["list"].arrayValue {
                    let info    = KSChartItem()
                    info.time   = json["time"].intValue// 开盘时间
                    info.open   = json["open"].stringValue// 开盘价
                    info.high   = json["high"].stringValue// 最高价
                    info.low    = json["low"].stringValue// 最低价
                    info.close  = json["close"].stringValue// 收盘价(当前K线未结束的即为最新价)
                    info.volume = json["volume"].stringValue// 成交量
                    candles.append(info)
                }
            }
            success((candles, market, period, name, precision, followed))
            
        }) { (error: ASRequestError?) in
            failure(error)
        }
    }
}
