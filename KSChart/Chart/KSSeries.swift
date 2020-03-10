//
//  ZeroShare
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

/// 系列对应的key值
struct KSSeriesKey {
    static let candle    = "CANDLE"
    static let timeline  = "TIMELINE"
    static let volume    = "VOLUME"
    static let ma        = "MA"
    static let ema       = "EMA"
    static let kdj       = "KDJ"
    static let macd      = "MACD"
    static let boll      = "BOLL"
    static let sar       = "SAR"
    static let sam       = "SAM"
    static let rsi       = "RSI"
    static let wr        = "WR"
    static let avg       = "AVG"
}

/// 线段组
/// 在图表中一个要显示的“线段”都是以一个KSSeries进行封装。
/// 蜡烛图线段：包含一个蜡烛图点线模型（KSCandleModel）
/// 时分线段：包含一个线点线模型（KSLineModel）
/// 交易量线段：包含一个交易量点线模型（KSColumnModel）
/// MA/EMA线段：包含一个线点线模型（KSLineModel）
/// KDJ线段：包含3个线点线模型（KSLineModel），3个点线的数值根据KDJ指标算法计算所得
/// MACD线段：包含2个线点线模型（KSLineModel），1个条形点线模型
class KSSeries: NSObject {
    var key                       = ""//技术指标「KDJ,MACD,BOLL等」
    var title: String             = ""
    var chartModels               = [KSChartModel]()//每个系列包含多个点线模型
    var hidden: Bool              = false//是否显示指标
    var showTitle: Bool           = true//是否显示标题文本
    var baseValueSticky           = false//是否以固定基值显示最小或最大值，若超过范围
    var symmetrical               = false//是否以固定基值为中位数，对称显示最大最小值
    var seriesLayer: KSShapeLayer = KSShapeLayer()//点线模型的绘图层

    /// 清空图表的子图层
    func removeLayerView() {
        _ = self.seriesLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.seriesLayer.sublayers?.removeAll()
    }
}

// MARK: - 工厂方法
extension KSSeries {

    /// 返回一个标准的时分价格系列样式
    ///
    /// - Parameters:
    ///   - color: 线段颜色
    ///   - section: 分区
    ///   - showGuide: 是否显示最大最小值
    /// - Returns: 线系列模型
    class func getTimelinePrice(color: UIColor, section: KSSection, showGuide: Bool = false, ultimateValueStyle: KSUltimateValueStyle = .none, graphType: KSGraphType = .normal, lineWidth: CGFloat = 1) -> KSSeries {
        let series                  = KSSeries()
        series.key                  = KSSeriesKey.timeline
        let timeline                = KSChartModel.getLine(color, title: NSLocalizedString("Price", comment: ""), key: "\(KSSeriesKey.timeline)_\(KSSeriesKey.timeline)")
        if graphType == .timeChart {
            timeline.gradientColors = [color.withAlphaComponent(0.6).cgColor,color.withAlphaComponent(0.4).cgColor,color.withAlphaComponent(0.2).cgColor]
        }
        timeline.graphType          = graphType
        timeline.section            = section
        timeline.useTitleColor      = false
        timeline.ultimateValueStyle = ultimateValueStyle
        timeline.showMaxVal         = showGuide
        timeline.showMinVal         = showGuide
        timeline.lineWidth          = lineWidth
        series.chartModels          = [timeline]
        return series
    }
    
    /// 返回一个标准的蜡烛柱价格系列样式
    ///
    /// - Parameters:
    ///   - upStyle:
    ///   - downStyle:
    ///   - titleColor:
    ///   - section:
    ///   - showGuide:
    ///   - ultimateValueStyle:
    /// - Returns:
    class func getCandlePrice(upStyle: (color: UIColor, isSolid: Bool),
                                     downStyle: (color: UIColor, isSolid: Bool),
                                     titleColor: UIColor,
                                     section: KSSection,
                                     showGuide: Bool = false,
                                     ultimateValueStyle: KSUltimateValueStyle = .none) -> KSSeries {
        let series                = KSSeries()
        series.key                = KSSeriesKey.candle
        let candle                = KSChartModel.getCandle(upStyle: upStyle, downStyle: downStyle, titleColor: titleColor)
        candle.section            = section
        candle.useTitleColor      = false
        candle.showMaxVal         = showGuide
        candle.showMinVal         = showGuide
        candle.ultimateValueStyle = ultimateValueStyle
        series.chartModels        = [candle]
        return series
    }
    
    /// 返回一个标准的交易量系列样式
    ///
    /// - Parameters:
    ///   - upStyle:
    ///   - downStyle:
    ///   - section:
    /// - Returns:
    class func getDefaultVolume(upStyle: (color: UIColor, isSolid: Bool),
                                       downStyle: (color: UIColor, isSolid: Bool),
                                       section: KSSection) -> KSSeries {
        let series         = KSSeries()
        series.key         = KSSeriesKey.volume
        let vol            = KSChartModel.getVolume(upStyle: upStyle, downStyle: downStyle)
        vol.section        = section
        vol.useTitleColor  = false
        series.chartModels = [vol]
        return series
    }
    
    /// 获取交易量的MA线
    ///
    class func getVolumeMA(isEMA: Bool = false, num: [Int], colors: [UIColor], section: KSSection) -> KSSeries {
        let series = self.getMA(isEMA: isEMA, num: num, colors: colors, section: section)
        return series
    }
    
    /// 返回一个交易量+MA组合系列样式
    ///
    /// - Parameters:
    ///   - upStyle:
    ///   - downStyle:
    ///   - isEMA:
    ///   - num:
    ///   - colors:
    ///   - section:
    /// - Returns:
    class func getVolumeWithMA(upStyle: (color: UIColor, isSolid: Bool),
                                       downStyle: (color: UIColor, isSolid: Bool),
                                       isEMA: Bool = false,
                                       num: [Int],
                                       colors: [UIColor],
                                       section: KSSection) -> KSSeries {
        let series         = KSSeries()
        series.key         = KSSeriesKey.volume
        let volumeSeries   = KSSeries.getDefaultVolume(upStyle: upStyle, downStyle: downStyle, section: section)

        let volumeMASeries = KSSeries.getVolumeMA(
            isEMA: isEMA,
            num: num,
            colors: colors,
            section: section)

        series.chartModels.append(contentsOf: volumeSeries.chartModels)
        series.chartModels.append(contentsOf: volumeMASeries.chartModels)
        return series
    }
    
    /// 返回一个交易量+SAM组合系列样式
    ///
    /// - Parameters:
    ///   - upStyle:
    ///   - downStyle:
    ///   - num:
    ///   - barStyle:
    ///   - lineColor:
    ///   - section:
    /// - Returns:
    class func getVolumeWithSAM(upStyle: (color: UIColor, isSolid: Bool),
                                      downStyle: (color: UIColor, isSolid: Bool),
                                      num: Int,
                                      barStyle: (color: UIColor, isSolid: Bool),
                                      lineColor: UIColor,
                                      section: KSSection) -> KSSeries {
        let series          = KSSeries()
        series.key          = KSSeriesKey.sam
        let volumeSeries    = KSSeries.getDefaultVolume(upStyle: upStyle, downStyle: downStyle, section: section)

        let volumeSAMSeries = KSSeries.getVolumeSAM(num: num, barStyle: barStyle, lineColor: lineColor, section: section)

        series.chartModels.append(contentsOf: volumeSeries.chartModels)
        series.chartModels.append(contentsOf: volumeSAMSeries.chartModels)
        return series
    }
    
    /// 获取交易量的MA线
    ///
    class func getPriceMA(isEMA: Bool = false, num: [Int], colors: [UIColor], section: KSSection) -> KSSeries {
        let series   = self.getMA(isEMA: isEMA, num: num, colors: colors, section: section)
        return series
    }
    
    /// 返回一个移动平均线系列样式
    ///
    /// - Parameters:
    ///   - isEMA:
    ///   - num:
    ///   - colors:
    ///   - section:
    /// - Returns:
    class func getMA(isEMA: Bool = false, num: [Int], colors: [UIColor], section: KSSection) -> KSSeries {
        var key = ""
        if isEMA {
            key = KSSeriesKey.ema
        } else {
            key = KSSeriesKey.ma
        }
        
        let series = KSSeries()
        series.key = key
        for (i, n) in num.enumerated() {
            let ma = KSChartModel.getLine(colors[i], title: "\(key)\(n)", key: "\(key)_\(n)")
            ma.section = section
            series.chartModels.append(ma)
        }
        return series
    }
    
    /// 返回一个移动平均线系列样式
    ///
    /// - Parameters:
    ///   - num:
    ///   - colors:
    ///   - section:
    /// - Returns:
    class func getRSI(num: [Int], colors: [UIColor], section: KSSection) -> KSSeries {
        let series = KSSeries()
        series.key = KSSeriesKey.rsi
        for (i, n) in num.enumerated() {
            let ma = KSChartModel.getLine(colors[i], title: "\(series.key)\(n)", key: "\(series.key)_\(n)")
            ma.section = section
            series.chartModels.append(ma)
        }
        return series
    }
    
    /// 返回一个KDJ系列样式
    ///
    /// - Parameters:
    ///   - kc:
    ///   - dc:
    ///   - jc:
    ///   - section:
    /// - Returns:
    class func getKDJ(_ kc: UIColor, dc: UIColor, jc: UIColor, section: KSSection) -> KSSeries {
        let series         = KSSeries()
        series.key         = KSSeriesKey.kdj
        let k              = KSChartModel.getLine(kc, title: "K", key: "\(KSSeriesKey.kdj)_K")
        k.section          = section
        let d              = KSChartModel.getLine(dc, title: "D", key: "\(KSSeriesKey.kdj)_D")
        d.section          = section
        let j              = KSChartModel.getLine(jc, title: "J", key: "\(KSSeriesKey.kdj)_J")
        j.section          = section
        series.chartModels = [k, d, j]
        return series
    }
    
    /// 返回一个MACD系列样式
    ///
    /// - Parameters:
    ///   - difc:
    ///   - deac:
    ///   - barc:
    ///   - upStyle:
    ///   - downStyle:
    ///   - section:
    /// - Returns:
    class func getMACD(_ difc: UIColor,
                              deac: UIColor,
                              barc: UIColor,
                              upStyle: (color: UIColor, isSolid: Bool),
                              downStyle: (color: UIColor, isSolid: Bool),
                              section: KSSection) -> KSSeries {
        let series         = KSSeries()
        series.key         = KSSeriesKey.macd
        let dif            = KSChartModel.getLine(difc, title: "DIF", key: "\(KSSeriesKey.macd)_DIF")
        dif.section        = section
        let dea            = KSChartModel.getLine(deac, title: "DEA", key: "\(KSSeriesKey.macd)_DEA")
        dea.section        = section
        let bar            = KSChartModel.getBar(upStyle: upStyle, downStyle: downStyle, titleColor: barc, title: "MACD", key: "\(KSSeriesKey.macd)_BAR")
        bar.section        = section
        series.chartModels = [dif, dea,bar]
        return series
    }
    
    /// 返回一个BOLL系列样式
    ///
    /// - Parameters:
    ///   - bollc:
    ///   - ubc:
    ///   - lbc:
    ///   - section:
    /// - Returns:
    class func getBOLL(_ bollc: UIColor, ubc: UIColor, lbc: UIColor, section: KSSection) -> KSSeries {
        let series         = KSSeries()
        series.key         = KSSeriesKey.boll
        let boll           = KSChartModel.getLine(ubc, title: "MID", key: "\(KSSeriesKey.boll)_BOLL")
        boll.section       = section
        let ub             = KSChartModel.getLine(bollc, title: "UP", key: "\(KSSeriesKey.boll)_UB")
        ub.section         = section
        let lb             = KSChartModel.getLine(lbc, title: "LOW", key: "\(KSSeriesKey.boll)_LB")
        lb.section         = section
        series.chartModels = [ub, boll, lb]
        return series
    }
    
    /// 返回一个SAR系列样式
    ///
    /// - Parameters:
    ///   - upStyle:
    ///   - downStyle:
    ///   - titleColor:
    ///   - plotPaddingExt:
    ///   - section:
    /// - Returns:
    class func getSAR(
        upStyle: (color: UIColor, isSolid: Bool),
        downStyle: (color: UIColor, isSolid: Bool),
        titleColor: UIColor,
        plotPaddingExt: CGFloat = 0.3,
        section: KSSection) -> KSSeries {

        let series         = KSSeries()
        series.key         = KSSeriesKey.sar
        let sar            = KSChartModel.getRound(upStyle: upStyle, downStyle: downStyle, titleColor: titleColor, title: "SAR", plotPaddingExt: plotPaddingExt, key: "\(KSSeriesKey.sar)")
        sar.section        = section
        sar.useTitleColor  = true
        series.chartModels = [sar]
        return series
    }
    
    /// 获取交易量的SAM线
    ///
    /// - Parameters:
    ///   - num:
    ///   - barStyle:
    ///   - lineColor:
    ///   - section:
    /// - Returns:
    class func getVolumeSAM(num: Int,
                                   barStyle: (color: UIColor, isSolid: Bool),
                                   lineColor: UIColor,
                                   section: KSSection) -> KSSeries {
        let valueKey       = KSSeriesKey.volume

        let series         = KSSeries()
        series.key         = KSSeriesKey.sam

        let sam            = KSChartModel.getLine(lineColor, title: "\(KSSeriesKey.sam)\(num)", key: "\(KSSeriesKey.sam)_\(num)_\(valueKey)")
        sam.section        = section
        sam.useTitleColor  = true

        let vol            = KSChartModel.getVolume(upStyle: barStyle, downStyle: barStyle, key: "\(KSSeriesKey.sam)_\(num)_\(valueKey)_BAR")
        vol.section        = section

        series.chartModels = [sam, vol]

        return series
    }
    
    /// 获取主图价格的SAM线
    ///
    /// - Parameters:
    ///   - num:
    ///   - barStyle:
    ///   - lineColor:
    ///   - section:
    /// - Returns:
    class func getPriceSAM(num: Int,
                                  barStyle: (color: UIColor, isSolid: Bool),
                                  lineColor: UIColor,
                                  section: KSSection) -> KSSeries {
        let valueKey       = KSSeriesKey.timeline

        let series         = KSSeries()
        series.key         = KSSeriesKey.sam

        let sam            = KSChartModel.getLine(lineColor, title: "\(KSSeriesKey.sam)\(num)", key: "\(KSSeriesKey.sam)_\(num)_\(valueKey)")
        sam.section        = section
        sam.useTitleColor  = true

        let candle         = KSChartModel.getCandle(upStyle: barStyle, downStyle: barStyle, titleColor: barStyle.color, key: "\(KSSeriesKey.sam)_\(num)_\(valueKey)_BAR")
        candle.drawShadow  = false
        candle.section     = section

        series.chartModels = [sam, candle]
        return series
    }
}
