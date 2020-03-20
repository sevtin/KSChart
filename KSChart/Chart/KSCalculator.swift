//
//  KSCalculator.swift
//  ZeroShare
//
//  Created by saeipi on 2019/9/4.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

enum KSIndexAlgorithm {
    case none //无算法
    case timeline //时分
    case ma(Int, Int, Int) //简单移动平均数
    case ema(Int, Int, Int) //指数移动平均数
    case kdj(Int, Int, Int) //随机指标
    case macd(Int, Int, Int) //指数平滑异同平均线
    case boll(Int, Int) //布林线
    case rsi(Int, Int, Int) //RSI指标公式
    case avg(Int) //自定义均线
}

class KSCalculator: NSObject {

    class func ks_calculator(algorithm: KSIndexAlgorithm, index: Int = 0, datas: [KSChartItem]) -> [KSChartItem] {
        switch algorithm {
        case .none:
            return datas
        case .timeline:
            return datas
        case let .ma(small, middle, big):
            return ks_calculateMA(index: index, small: small, middle: middle, big: big, datas: datas)
        case let .ema(emaSmall, emaMiddle, emaBig):
            return ks_calculateEMA(index: index, emaSmall: emaSmall, emaMiddle: emaMiddle, emaBig: emaBig, datas: datas)
        case let .kdj(rsvArg, kArg, dArg):
            return ks_calculateKDJ(index: index, rsvArg: rsvArg, kArg: kArg, dArg: dArg, datas: datas)
        case let .macd(emaSmall, emaBig, dea):
            return ks_calculateMACD(from: index, emaSmall: emaSmall, emaBig: emaBig, dea: dea, datas: datas)
        case let .boll(num, arg):
            return ks_calculateBOLL(index: index, num: num, arg: arg, datas: datas)
        case let .rsi(avgSmall, avgMiddle, avgBig):
            return ks_calculateRSI(index: index, avgSmall: CGFloat(avgSmall), avgMiddle: CGFloat(avgMiddle), avgBig: CGFloat(avgBig), datas: datas)
        case let .avg(num):
            return ks_calculateAvgPrice(index: index, num: num, datas: datas)
        }
    }
}

// MARK: - 公共
extension KSCalculator {
    /// 计算均值
    ///
    /// - Parameters:
    ///   - count: 平均数的个数
    ///   - endIndex: 计算平均数结束的下标
    ///   - datas: 需要处理的数据
    /// - Returns:
    class func ks_calculateAveragePrice(count: Int, endIndex: Int, datas: [KSChartItem]) -> CGFloat {
        var result: CGFloat = 0.0
        
        if endIndex < (count - 1) {
            return result
        }
        
        var sum: CGFloat = 0.0
        var i = endIndex
        while i > (endIndex - count) {
            let tempModel = datas[i]
            sum           += tempModel.closePrice
            i             -= 1
        }
        
        result = sum / CGFloat(count)
        
        return result
    }
}

// MARK: - 均价
extension KSCalculator {
    class func ks_calculateAvgPrice(index: Int, num: Int, datas: [KSChartItem]) -> [KSChartItem] {
        var index = index
        if index >= (datas.count - 1) {
            index = datas.count - 1
        }
        if datas.count >= num {
            for i in index..<datas.count {
                let data = datas[i]
                if i >= (num - 1) {
                    data.avg_price = self.ks_calculateAveragePrice(count: num, endIndex: i, datas: datas)
                }
            }
        }
        return datas
    }
}

// MARK: - RSI 计算单个指标
extension KSCalculator {
    /// 计算RSI
    ///
    /// - Parameters:
    ///   - index: 开始的下标
    ///   - datas:
    class func ks_calculateRSI(index: Int = 0, avgSmall: CGFloat = 6, avgMiddle: CGFloat = 12, avgBig: CGFloat = 24, datas: [KSChartItem]) -> [KSChartItem] {
        var index = index
        // MA准备数据方法
        if index >= datas.count - 1 {
            index = datas.count - 1
        }
        if datas.count >= 5 {
            for i in index..<datas.count {
                let tempModel = datas[i]
                if i >= 1 {
                    // 计算RS
                    self.ks_calculateRS(index: i, avgSmall: avgSmall, avgMiddle: avgMiddle, avgBig: avgBig, datas: datas)
                    // 计算RSI
                    let dn_avg_6                              = (tempModel.dn_avg_6 == 0) ? 1 : tempModel.dn_avg_6
                    let dn_avg_12                             = (tempModel.dn_avg_12 == 0) ? 1 : tempModel.dn_avg_12
                    let dn_avg_24                             = (tempModel.dn_avg_24 == 0) ? 1 : tempModel.dn_avg_24

                    tempModel.rsi6                            = 100.0 - (100.0 / (1.0 + tempModel.up_avg_6 / dn_avg_6))
                    tempModel.rsi12                           = 100.0 - (100.0 / (1.0 + tempModel.up_avg_12 / dn_avg_12))
                    tempModel.rsi24                           = 100.0 - (100.0 / (1.0 + tempModel.up_avg_24 / dn_avg_24))

                    tempModel.extVal["RSI_\(Int(avgSmall))"]  = tempModel.rsi6//RSI_6
                    tempModel.extVal["RSI_\(Int(avgMiddle))"] = tempModel.rsi12//RSI_12
                    tempModel.extVal["RSI_\(Int(avgBig))"]    = tempModel.rsi24//RSI_24
                }
            }
        }
        return datas
    }
    
    /// 根据传入的参数计算RS
    ///
    /// - Parameters:
    ///   - index: 需要计算的下标
    ///   - datas:
    class func ks_calculateRS(index: Int, avgSmall: CGFloat = 6, avgMiddle: CGFloat = 12, avgBig: CGFloat = 24, datas: [KSChartItem]) {
        
        let tempModel   = datas[index]
        let lastModel   = datas[index - 1]

        let diff        = tempModel.closePrice - lastModel.closePrice
        let up: CGFloat = fmax(0.0, diff)
        let dn: CGFloat = abs(fmin(0.0, diff))

        if index == 1 {
            tempModel.up_avg_6  = up / avgSmall
            tempModel.up_avg_12 = up / avgMiddle
            tempModel.up_avg_24 = up / avgBig

            tempModel.dn_avg_6  = dn / avgSmall
            tempModel.dn_avg_12 = dn / avgMiddle
            tempModel.dn_avg_24 = dn / avgBig
        } else {
            tempModel.up_avg_6  = (up / avgSmall) + ((lastModel.up_avg_6 * (avgSmall - 1)) / avgSmall)
            tempModel.up_avg_12 = (up / avgMiddle) + ((lastModel.up_avg_12 * (avgMiddle - 1)) / avgMiddle)
            tempModel.up_avg_24 = (up / avgBig) + ((lastModel.up_avg_24 * (avgBig - 1)) / avgBig)

            tempModel.dn_avg_6  = (dn / avgSmall) + ((lastModel.dn_avg_6 * (avgSmall - 1)) / avgSmall)
            tempModel.dn_avg_12 = (dn / avgMiddle) + ((lastModel.dn_avg_12 * (avgMiddle - 1)) / avgMiddle)
            tempModel.dn_avg_24 = (dn / avgBig) + ((lastModel.dn_avg_24 * (avgBig - 1)) / avgBig)
        }
    }
}

// MARK: - BOOL
extension KSCalculator {
    /// BOLL数据准备方法
    ///
    /// - Parameters:
    ///   - num: 天数
    ///   - arg: 参数默认为2
    ///   - index: 开始计算的下标
    ///   - datas: 需要处理的数据
    /// - Returns: 处理后的数据
    class func ks_calculateBOLL(index: Int = 0, num: Int = 20, arg: Int = 2, datas: [KSChartItem]) -> [KSChartItem] {
        var index = index
        // BOLL准备方法
        if index >= (datas.count - 1) {
            index = datas.count - 1
        }
        
        if datas.count >= num {
            for i in index..<datas.count {
                let data = datas[i]
                if i >= (num - 1) {
                    data.boll_ma             = self.ks_calculateAveragePrice(count: num, endIndex: i, datas: datas)
                    data.boll_up             = data.boll_ma + (self.calculateStd(num: num, arg: arg, index: i, datas: datas) * CGFloat(arg))
                    data.boll_low            = data.boll_ma - (self.calculateStd(num: num, arg: arg, index: i, datas: datas) * CGFloat(arg))

                    data.extVal["BOLL_BOLL"] = data.boll_ma
                    data.extVal["BOLL_UB"]   = data.boll_up
                    data.extVal["BOLL_LB"]   = data.boll_low
                }
            }
        }
        return datas
    }
    
    /// std(close , 20)
    ///
    /// - Parameters:
    ///   - num: 求和的个数，默认20
    ///   - arg: 参数值，默认2
    ///   - index: 结束的index
    ///   - datas: 数据
    /// - Returns: 计算后的std(close , 20)
    private class func calculateStd(num: Int = 20, arg: Int = 2, index: Int = 0, datas: [KSChartItem]) -> CGFloat {
        var result: CGFloat = 0.0
        
        if index < (num - 1) {
            return result
        }
        
        var sum: CGFloat     = 0.0
        var boll_ma: CGFloat = 0.0
        /*
         for i in stride(from: index, to: (index - num), by: -1) {
         let data = datas[i]
         if boll_ma != 0 {
         boll_ma = data.boll_ma
         }
         sum += pow((data.closePrice - boll_ma), CGFloat(arg))
         }
         */
        
        var i                = index
        while i > (index - num) {
            let data = datas[i]
            if boll_ma == 0.0 {
                boll_ma = data.boll_ma
            }
            sum += pow((data.closePrice - boll_ma), CGFloat(arg))
            i   -= 1
        }
        // 开平方
        result = sqrt((sum / CGFloat(num)))
        return result
    }
}

// MARK: - MACD
extension KSCalculator {
    /**
     MACD数据准备方法
     
     @param index 开始计算的下标
     @param emaSmall 默认12
     @param emaBig 默认26
     @param dea 默认9
     @param datas 需要处理的数据
     */
    class func ks_calculateMACD(from index: Int = 0, emaSmall: Int = 12, emaBig: Int = 26, dea: Int = 9, datas: [KSChartItem]) -> [KSChartItem] {
        var index = index
        if index >= (datas.count - 1) {
            index = datas.count - 1
        }
        if datas.count >= 1 {
            for i in index..<datas.count {
                let data                = datas[i]
                // 计算EMA12,EMA26
                self.calculateExpma(index: i, emaSmall: emaSmall, emaBig: emaBig, datas: datas)
                // DIF
                data.dif                = data.ema_small - data.ema_big
                // DEA
                self.calculateDea(argu: dea, end: i, datas: datas)
                // MACD柱线
                data.macd               = data.dif - data.dea//2.0 * data.dif - data.dea

                data.extVal["MACD_DIF"] = data.dif
                data.extVal["MACD_DEA"] = data.dea
                data.extVal["MACD_BAR"] = data.macd
            }
        }
        return datas
    }
    
    /**
     计算EMA的算法
     
     @param index 需要计算的下标
     @param emaSmall 默认12
     @param emaBig 默认26
     @param datas 需要处理的数据
     */
    private class func calculateExpma(index: Int, emaSmall: Int, emaBig: Int, datas: [KSChartItem]) {
        let currentModel = datas[index]
        if index == 0 {
            // 第一日的ema12为收盘价
            currentModel.ema_small = currentModel.closePrice
            currentModel.ema_big   = currentModel.closePrice
        }else{//测试
            let lastModel = datas[index - 1]
            currentModel.ema_small = (2.0 / CGFloat(emaSmall + 1)) * (currentModel.closePrice - lastModel.ema_small) + lastModel.ema_small
            currentModel.ema_big = (2.0 / CGFloat(emaBig + 1)) * (currentModel.closePrice - lastModel.ema_big) + lastModel.ema_big
        }
    }
    
    /**
     DIF的EMA(DEA)
     
     @param argu 计算平均值的平滑参数
     @param endIndex 结束时的index
     @param datas 需要处理的数据
     */
    private class func calculateDea(argu: Int, end endIndex: Int, datas: [KSChartItem]) {
        let endModel = datas[endIndex]
        if endIndex == 0 {
            // 第一日的dea为0
            endModel.dea = 0.0
        } else {
            let lastModel = datas[endIndex - 1]
            let last_dea  = lastModel.dea * (8.0 / 10.0)
            let end_dif   = endModel.dif * (2.0 / 10.0)
            endModel.dea  = last_dea + end_dif
        }
    }
}

// MARK: - KDJ
extension KSCalculator {
    /**
     KDJ数据准备方法
     
     @param index 结束的下标
     @param datas 需要处理的数据
     */
    class func ks_calculateKDJ(index: Int, rsvArg: Int = 9, kArg: Int = 3, dArg: Int = 3, datas: [KSChartItem]) -> [KSChartItem] {
        if index > (datas.count - 1) {
            return datas
        }
        
        if datas.count >= 1 {
            for i in index..<datas.count {
                let data = datas[i]
                if i == 0 {
                    data.k = 50.0
                    data.d = 50.0
                } else {
                    data.rsv = self.calculateRsv(endindex: i, rsvArg: rsvArg, datas: datas)
                    self.calculateKD(index: i, kArg: kArg, dArg: dArg, datas: datas)
                }
                data.j = (3.0 * data.k) - (2.0 * data.d)
                
                data.extVal["KDJ_K"] = data.k
                data.extVal["KDJ_D"] = data.d
                data.extVal["KDJ_J"] = data.j
            }
        }
        return datas
    }
    
    /**
     计算RSV
     
     @param endindex 结束的下标
     @param datas 需要处理的数据
     @return 计算后的RSV9
     */
    private class func calculateRsv(endindex: Int, rsvArg: Int = 9, datas: [KSChartItem]) -> CGFloat {
        var low             = CGFloat(MAXFLOAT)
        var high            = CGFloat(-MAXFLOAT)
        let close: CGFloat  = datas[endindex].closePrice

        var startIndex      = endindex - (rsvArg - 1)
        if startIndex < 0 {
            startIndex = 0
        }
        for index in startIndex...endindex {
            let tempModel = datas[index]
            if tempModel.lowPrice < low {
                low = tempModel.lowPrice
            }
            if tempModel.highPrice > high {
                high = tempModel.highPrice
            }
        }
        /*
        var i = endindex
        while i >= startIndex {
            let tempModel = datas[i]
            if tempModel.lowPrice < low {
                low = tempModel.lowPrice
            }
            if tempModel.highPrice > high {
                high = tempModel.highPrice
            }
            i -= 1
        }*/
        let result: CGFloat = (close - low) / (high - low) * 100.0
        return result.isNaN ? 0 : result
    }
    
    /**
     计算K值和D值
     
     @param index 需要计算的模型的下标
     @param datas 需要处理的数据
     */
    private class func calculateKD(index: Int, kArg: Int = 3, dArg: Int = 3, datas: [KSChartItem]) {
        let currentModel = datas[index]
        let lastModel    = datas[index - 1]
        currentModel.k   = ((2.0 * lastModel.k) + currentModel.rsv) / CGFloat(kArg)
        currentModel.d   = ((2.0 * lastModel.d) + currentModel.k) / CGFloat(dArg)
    }
}

// MARK: - MA
extension KSCalculator {
    /**
     分段计算MA数据[MA(5,10,30) 计算方法]
     
     @param index 下标
     @param big 默认30
     @param middle 默认10
     @param small 默认5
     @param datas 需要处理的数据
     */
    class func ks_calculateMA(index: Int, small: Int = 5, middle: Int = 10, big: Int = 30, datas: [KSChartItem]) -> [KSChartItem] {
        var index = index
        // MA准备数据方法
        if index >= (datas.count - 1) {
            index = datas.count - 1
        }
        if datas.count >= small {
            for i in index..<datas.count {
                let data = datas[i]
                if i >= (small - 1) {
                    data.ma_small = self.ks_calculateAveragePrice(count: small, endIndex: i, datas: datas)
                }
                if i >= (middle - 1) {
                    data.ma_middle = self.ks_calculateAveragePrice(count: middle, endIndex: i, datas: datas)
                }
                if i >= (big - 1) {
                    data.ma_big = self.ks_calculateAveragePrice(count: big, endIndex: i, datas: datas)
                }
                data.extVal["MA_\(small)"]  = data.ma_small//MA_5
                data.extVal["MA_\(middle)"] = data.ma_middle//MA_10
                data.extVal["MA_\(big)"]    = data.ma_big//MA_30
            }
        }
        return datas
    }
}

// MARK: - EMA
extension KSCalculator {
    /**
     计算EMA的算法 [EMA（N）=2/（N+1）*（C-昨日EMA）+昨日EMA；]
     
     @param index 需要计算的下标
     @param emaSmall 默认12
     @param emaBig 默认26
     @param datas 需要处理的数据
     */
    class func ks_calculateEMA(index: Int, emaSmall: Int, emaMiddle: Int, emaBig: Int, datas: [KSChartItem]) ->[KSChartItem] {
        for i in index..<datas.count {
            calculateSingleEMA(index: i, emaSmall: emaSmall, emaMiddle: emaMiddle, emaBig: emaBig, datas: datas)
            let data                        = datas[i]
            data.extVal["EMA_\(emaSmall)"]  = data.ema_small//EMA_7
            data.extVal["EMA_\(emaMiddle)"] = data.ema_middle//EMA_25
            data.extVal["EMA_\(emaBig)"]    = data.ema_big//EMA_99
        }
         return datas
    }
    
    private class func calculateSingleEMA(index: Int, emaSmall: Int, emaMiddle: Int, emaBig: Int, datas: [KSChartItem]) {
        let tempModel = datas[index]
        if index == 0 {
            // 第一日的ema12为收盘价
            tempModel.ema_small  = tempModel.closePrice
            tempModel.ema_middle = tempModel.closePrice
            tempModel.ema_big    = tempModel.closePrice
        } else {
            let lastModel        = datas[index - 1]
            tempModel.ema_small  = (2.0 / CGFloat(emaSmall + 1)) * (tempModel.closePrice - lastModel.ema_small) + lastModel.ema_small
            tempModel.ema_middle = (2.0 / CGFloat(emaMiddle + 1)) * (tempModel.closePrice - lastModel.ema_middle) + lastModel.ema_middle
            tempModel.ema_big    = (2.0 / CGFloat(emaBig + 1)) * (tempModel.closePrice - lastModel.ema_big) + lastModel.ema_big
        }
    }
}
