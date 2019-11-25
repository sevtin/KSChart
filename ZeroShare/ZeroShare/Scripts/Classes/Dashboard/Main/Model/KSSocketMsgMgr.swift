//
//  KSSocketMsgMgr.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/30.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSSocketMsgMgr: NSObject {
    var isProcessing           = true//是否处理消息
    var isSubscription         = false//是否订阅消息
    
    var messages: [KSChartItem] = [KSChartItem]()//记录socket消息

    func messageAppend(klineDatas: inout [KSChartItem], chartItem: KSChartItem) {
        if klineDatas.count == 0 {
            self.arrayAppend(sourceArray: &self.messages, item: chartItem)
        }
        else if klineDatas.last?.time == chartItem.time {
            self.arrayAppend(sourceArray: &klineDatas, item: chartItem)
        }
        else if (klineDatas.last?.time ?? 0) < chartItem.time {
            if self.messages.count > 0 {
                self.messages.append(chartItem)
                if let lastItem = klineDatas.last {
                    for i in 0..<self.messages.count {
                        if self.messages[i].time >= lastItem.time {
                            self.arrayAppend(sourceArray: &klineDatas, item: self.messages[i])
                        }
                    }
                    self.messages.removeAll()
                }
            }
            else{
                self.arrayAppend(sourceArray: &klineDatas, item: chartItem)
            }
        }
    }
    
    func recordMessage(chartItem: KSChartItem) {
        self.arrayAppend(sourceArray: &self.messages, item: chartItem)
    }
    
    func arrayAppend(sourceArray: inout [KSChartItem], item: KSChartItem) {
        if let lastItem = sourceArray.last {
            if lastItem.time == item.time {
                sourceArray.removeLast()
                sourceArray.append(item)
            }
            else if lastItem.time < item.time {
                sourceArray.append(item)
            }
        }
    }
    
    /// 订阅所有
    func subscriptionAll(symbol: String, configure: KSDashboardConfigure, socket: KSWebSocket?) {
        configure.symbol    = symbol
        configure.klineCh   = "m:\(configure.symbol),k:\(configure.kline),v:\(configure.socketVersion)"
        configure.depthCh   = "m:\(configure.symbol),d:\(configure.depth),v:\(configure.socketVersion)"
        configure.summaryCh = "m:\(configure.symbol),tk:1d,v:\(configure.socketVersion)"
        configure.detailCh  = "m:\(configure.symbol),t:0,v:\(configure.socketVersion)"
        
        let allCh           = configure.klineCh + "#" + configure.depthCh + "#" + configure.summaryCh + "#" + configure.detailCh
        socket?.sendMessage(["t":"sub","ch":allCh])

    }
    
    /// 取消订阅所有
    func unSubscriptionAll(configure: KSDashboardConfigure, socket: KSWebSocket?) {
        configure.klineCh   = "m:\(configure.symbol),k:\(configure.kline),v:\(configure.socketVersion)"
        configure.depthCh   = "m:\(configure.symbol),d:\(configure.depth),v:\(configure.socketVersion)"
        configure.summaryCh = "m:\(configure.symbol),tk:1d,v:\(configure.socketVersion)"
        configure.detailCh  = "m:\(configure.symbol),t:0,v:\(configure.socketVersion)"

        let allCh           = configure.klineCh + "#" + configure.depthCh + "#" + configure.summaryCh + "#" + configure.detailCh
        socket?.sendMessage(["t": "un-sub", "ch": allCh])
    }

    ///k线
    func subscriptionKline(configure: KSDashboardConfigure, socket: KSWebSocket?) {
        configure.symbol  = configure.newConfigure.symbol
        configure.kline   = configure.newConfigure.kline
        //订阅K线
        configure.klineCh = "m:\(configure.symbol),k:\(configure.kline),v:\(configure.socketVersion)"
        socket?.sendMessage(["t":"sub","ch":configure.klineCh])
    }
    
    func unSubscriptionKline(symbol: String, kline: String, configure: KSDashboardConfigure, socket: KSWebSocket?) {
        configure.klineCh = "m:\(configure.symbol),k:\(configure.kline),v:\(configure.socketVersion)"
        socket?.sendMessage(["t": "un-sub", "ch": configure.klineCh])
        
        configure.newConfigure.symbol = symbol
        configure.newConfigure.kline  = kline
    }
    
    func integrityVerification(lastTime: Int, currentTime: Int) -> Bool {
        let tup = KSSingleton.shared.indexConfigure.timeDict[KSSingleton.shared.indexConfigure.timeID]
        if (currentTime - lastTime) <= (tup?.2 ?? 0) {
            return true
        }
        return false
    }
}
