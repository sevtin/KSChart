//
//  KSChartTai.swift
//  ZeroShare
//
//  Created by saeipi on 2019/9/24.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSChartTai: NSObject {
    var masterTai:String = ""
    var assistTai:String = ""
    lazy var chartTai: [String: KSIndexAlgorithm] = {
        //kdj:9,3,3
        let chartTai: [String: KSIndexAlgorithm] = [KSSeriesKey.candle: .none,
                                                    KSSeriesKey.timeline: .timeline,
                                                    KSSeriesKey.volume: .none,
                                                    KSSeriesKey.ma: .ma(5, 10, 30),
                                                    KSSeriesKey.ema: .ema(7, 25, 99),
                                                    KSSeriesKey.kdj: .kdj,
                                                    KSSeriesKey.macd: .macd(12, 26, 9),
                                                    KSSeriesKey.boll: .boll(20, 2),
                                                    KSSeriesKey.rsi: .rsi(6, 12, 24),
                                                    KSSeriesKey.avg: .avg(5)]
        return chartTai
    }()
    
    lazy var indicators:[String] = {
        let indicators:[String] = [KSSeriesKey.volume,
                                   KSSeriesKey.ma,
                                   KSSeriesKey.ema,
                                   KSSeriesKey.kdj,
                                   KSSeriesKey.macd,
                                   KSSeriesKey.boll,
                                   KSSeriesKey.rsi,
                                   KSSeriesKey.avg]
        return indicators
    }()
    
    var index:Int = 0
    
    var masterAlgorithm: KSIndexAlgorithm? {
        get{
            return chartTai[masterTai]
        }
    }
    
    var assistAlgorithm: KSIndexAlgorithm? {
        get{
            return chartTai[assistTai]
        }
    }
    
    func nextAlgorithm() -> KSIndexAlgorithm {
        index += 1
        if index >= indicators.count {
            index = 0
        }
        return chartTai[indicators[index]] ?? .none
    }
}
