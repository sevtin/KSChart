//
//  KSChartItem+Extensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/9.
//  Copyright © 2019 saeipi. All rights reserved.
//


import UIKit
import SwiftyJSON

extension KSChartItem {
    
    /// 格式化数据
    ///
    /// - Parameter array:
    /// - Returns:
    class func formatDatas(array: Array<CGFloat>) -> KSChartItem {
        let info        = KSChartItem()
        info.time       = Int(array[0])
        info.highPrice  = array[2]
        info.lowPrice   = array[1]
        info.openPrice  = array[3]
        info.closePrice = array[4]
        info.vol        = array[5]
        return info
    }
    
    class func formatMessage(message: Any?) -> KSChartItem? {
        if let _message = message as? String {
            if let jsonData = _message.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                let json        = try! JSON(data: jsonData)
                let info        = KSChartItem()
                info.time       = json["k"]["t"].intValue/1000// 这根K线的起始时间
                //json["k"]["T"]// 这根K线的结束时间
                info.openPrice  = CGFloat(json["k"]["o"].floatValue)// 这根K线期间第一笔成交价
                info.closePrice = CGFloat(json["k"]["c"].floatValue)// 这根K线期间末一笔成交价
                info.highPrice  = CGFloat(json["k"]["h"].floatValue)// 这根K线期间最高成交价
                info.lowPrice   = CGFloat(json["k"]["l"].floatValue)// 这根K线期间最低成交价
                info.vol        = CGFloat(json["k"]["v"].floatValue)// 这根K线期间成交量
                return info
            }
        }
        return nil
    }
    
    class func formatBinanceMessage(json: JSON) -> KSChartItem {
        let info    = KSChartItem()
        info.time   = json["k"]["t"].intValue/1000// 这根K线的起始时间
        info.open   = json["k"]["o"].stringValue// 这根K线期间第一笔成交价
        info.close  = json["k"]["c"].stringValue// 这根K线期间末一笔成交价
        info.high   = json["k"]["h"].stringValue// 这根K线期间最高成交价
        info.low    = json["k"]["l"].stringValue// 这根K线期间最低成交价
        info.volume = json["k"]["v"].stringValue// 这根K线期间成交量
        return info
    }
    
    class func formatKlineMessage(json: JSON) -> KSChartItem {
        let info    = KSChartItem()
        info.time   = json["b"]["ts"].intValue// 这根K线的起始时间
        info.open   = json["b"]["o"].stringValue// 这根K线期间第一笔成交价
        info.close  = json["b"]["c"].stringValue// 这根K线期间末一笔成交价
        info.high   = json["b"]["h"].stringValue// 这根K线期间最高成交价
        info.low    = json["b"]["l"].stringValue// 这根K线期间最低成交价
        info.volume = json["b"]["v"].stringValue// 这根K线期间成交量
        //let outerArray = json["ch"].stringValue.components(separatedBy:",")
        //let market     = outerArray[0].components(separatedBy:":")[1]
        //let kline      = outerArray[1].components(separatedBy:":")[1]
        return info
        
    }
    /*
    class func formatDepthMessage(message: Any?) -> (String, String, KSChartItem)? {
        if let _message = message as? String {
            if let jsonData = _message.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                let json       = try! JSON(data: jsonData)
                let info       = KSChartItem()
                info.time      = json["k"]["t"].intValue/1000// 这根K线的起始时间
                info.open      = json["k"]["o"].stringValue// 这根K线期间第一笔成交价
                info.close     = json["k"]["c"].stringValue// 这根K线期间末一笔成交价
                info.high      = json["k"]["h"].stringValue// 这根K线期间最高成交价
                info.low       = json["k"]["l"].stringValue// 这根K线期间最低成交价
                info.volume    = json["k"]["v"].stringValue// 这根K线期间成交量

                let outerArray = json["ch"].stringValue.components(separatedBy:",")
                let market     = outerArray[0].components(separatedBy:":")[1]
                let side       = outerArray[1].components(separatedBy:":")[1]

                return (String: market, String: side, KSChartItem: info)
            }
        }
        return nil
    }
    */
    
    func displayColor(current: CGFloat, yester: CGFloat) -> UIColor {
        if current == yester {
            return KS_Const_Color_Chart_Ink
        }
        else if current > yester {
            return KS_Const_Color_Chart_Up
        }
        else{
            return KS_Const_Color_Chart_Down
        }
    }
    
    func setOpenValue(textLabel: UILabel, extra: String?) {
        combination(textLabel: textLabel, extra: extra, value: open)
        textLabel.textColor = displayColor(current: openPrice, yester: yesterPrice)
    }
    
    func setCloseValue(textLabel: UILabel, extra: String?) {
        combination(textLabel: textLabel, extra: extra, value: close)
        textLabel.textColor = displayColor(current: closePrice, yester: yesterPrice)
    }
    
    func setHighValue(textLabel: UILabel, extra: String?) {
        combination(textLabel: textLabel, extra: extra, value: high)
        textLabel.textColor = displayColor(current: highPrice, yester: yesterPrice)
    }
    
    func setLowValue(textLabel: UILabel, extra: String?) {
        combination(textLabel: textLabel, extra: extra, value: low)
        textLabel.textColor = displayColor(current: lowPrice, yester: yesterPrice)
    }
    
    func setVolValue(textLabel: UILabel, extra: String?) {
        combination(textLabel: textLabel, extra: extra, value: volumeDisplay)
        textLabel.textColor = displayColor(current: closePrice, yester: yesterPrice)
    }
    
    func setPriceChangeValue(textLabel: UILabel, extra: String?) {
        combination(textLabel: textLabel, extra: extra, value: priceChange)
        textLabel.textColor = displayColor(current: closePrice, yester: yesterPrice)
    }
    
    func setChangePercentValue(textLabel: UILabel, extra: String?) {
        combination(textLabel: textLabel, extra: extra, value: changePercent)
        if closePrice >= yesterPrice {
            textLabel.textColor = KS_Const_Color_Chart_Up
        }
        else{
            textLabel.textColor = KS_Const_Color_Chart_Down
        }
    }
    
    func combination(textLabel: UILabel, extra: String?, value: String) {
        if let _extra = extra {
            textLabel.text = _extra + value
        }
        else{
            textLabel.text = value
        }
    }
}
