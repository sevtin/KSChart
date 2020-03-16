//
//  SeriesParamList.swift
//  ZeroShare
//
//  Created by saeipi on 2019/6/11.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSSeriesParam: NSObject, Codable {
    var seriesKey: String = ""
    var name: String = ""
    var params: [KSSeriesParamControl] = [KSSeriesParamControl]()
    var order: Int = 0
    var hidden: Bool = false
    
    convenience init(seriesKey: String, name: String, params: [KSSeriesParamControl], order: Int, hidden: Bool) {
        self.init()
        self.seriesKey = seriesKey
        self.name = name
        self.params = params
        self.order = order
        self.hidden = hidden
    }
    /*
    /// 获取指标线段组
    func appendIn(masterSection: KSSection,
                  assistSections: KSSection...) {
        
        let styleParam = KSStyleParam.init()
        //分区点线样式
        let upcolor = (UIColor(hex: styleParam.upColor), true)
        let downcolor = (UIColor(hex: styleParam.downColor), true)
        
        let lineColors = [
            UIColor(hex: styleParam.lineColors[0]),
            UIColor(hex: styleParam.lineColors[1]),
            UIColor(hex: styleParam.lineColors[2]),
        ]
        
        switch seriesKey {
        case KSSeriesKey.ma:
            
            var maColor = [UIColor]()
            for i in 0..<self.params.count {
                maColor.append(lineColors[i])
            }
            
            let series = KSSeries.getPriceMA(
                isEMA: false,
                num: self.params.map {Int($0.value)},
                colors: maColor,
                section: masterSection)
            
            
            masterSection.series.append(series)
            
            for assistSection in assistSections {
                
                let volWithMASeries = KSSeries.getVolumeWithMA(upStyle: upcolor,
                                                               downStyle: downcolor,
                                                               isEMA: false,
                                                               num: self.params.map {Int($0.value)},
                                                               colors: maColor,
                                                               section: assistSection)
                
                assistSection.series.append(volWithMASeries)
            }
            
        case KSSeriesKey.ema:
            
            var emaColor = [UIColor]()
            for i in 0..<self.params.count {
                emaColor.append(lineColors[i])
            }
            
            let series = KSSeries.getPriceMA(
                isEMA: true,
                num: self.params.map {Int($0.value)},
                colors: emaColor,
                section: masterSection)
            
            
            masterSection.series.append(series)
            
        case KSSeriesKey.kdj:
            
            for assistSection in assistSections {
                
                let kdjSeries = KSSeries.getKDJ(
                    lineColors[0],
                    dc: lineColors[1],
                    jc: lineColors[2],
                    section: assistSection)
                kdjSeries.title = "KDJ(\(self.params[0].value.ks_indexToString()),\(self.params[1].value.ks_indexToString()),\(self.params[2].value.ks_indexToString()))"
                
                assistSection.series.append(kdjSeries)
            }
            
        case KSSeriesKey.macd:
            for assistSection in assistSections {
                
                let macdSeries = KSSeries.getMACD(
                    lineColors[0],
                    deac: lineColors[1],
                    barc: lineColors[2],
                    upStyle: upcolor, downStyle: downcolor,
                    section: assistSection)
                macdSeries.title = "MACD(\(self.params[0].value.ks_indexToString()),\(self.params[1].value.ks_indexToString()),\(self.params[2].value.ks_indexToString()))"
                macdSeries.symmetrical = true
                
                assistSection.series.append(macdSeries)
            }
        case KSSeriesKey.boll:
            // 主图Master
            let priceBOLLSeries = KSSeries.getBOLL(
                lineColors[0],
                ubc: lineColors[1],
                lbc: lineColors[2],
                section: masterSection)
            
            priceBOLLSeries.hidden = true
            masterSection.series.append(priceBOLLSeries)
            
            // 附图 [2019.8.7加]
            for assistSection in assistSections {
                let bollSeries = KSSeries.getBollPrice(
                    upStyle: upcolor,
                    downStyle: downcolor,
                    titleColor: UIColor(white: 0.5, alpha: 1),
                    lineColors: lineColors,
                    section: assistSection,
                    showGuide: true,
                    ultimateValueStyle: .arrow(UIColor(white: 0.5, alpha: 1)))
                //bollSeries.title = "BOLL"
                bollSeries.symmetrical = false
                assistSection.series.append(bollSeries)
                /*
                // 附图 [2019.8.7加]
                let assistPriceBOLLSeries = KSSeries.getBOLL(
                    lineColors[0],
                    ubc: lineColors[1],
                    lbc: lineColors[2],
                    section: assistSection)
                assistPriceBOLLSeries.title  = "ASSIST BOLL"
                assistPriceBOLLSeries.key    = KSSeriesKey.boll
                assistPriceBOLLSeries.hidden = false
                assistSection.series.append(assistPriceBOLLSeries)
                 */
            }
        case KSSeriesKey.sar:
            
            let priceSARSeries = KSSeries.getSAR(
                upStyle: upcolor,
                downStyle: downcolor,
                titleColor: lineColors[0],
                section: masterSection)
            
            priceSARSeries.hidden = true
            
            masterSection.series.append(priceSARSeries)
            
        case KSSeriesKey.sam:
            
            let priceSAMSeries = KSSeries.getPriceSAM(num: Int(self.params[0].value), barStyle: (UIColor.yellow, false), lineColor: UIColor(white: 0.4, alpha: 1), section: masterSection)
            
            priceSAMSeries.hidden = true
            
            masterSection.series.append(priceSAMSeries)
            
            for assistSection in assistSections {
                
                let volWithSAMSeries = KSSeries.getVolumeWithSAM(upStyle: upcolor,
                                                                 downStyle: downcolor,
                                                                 num: Int(self.params[0].value),
                                                                 barStyle: (UIColor.yellow, false),
                                                                 lineColor: UIColor(white: 0.4, alpha: 1),
                                                                 section: assistSection)
                
                assistSection.series.append(volWithSAMSeries)
            }
            
        case KSSeriesKey.rsi:
            
            var maColor = [UIColor]()
            for i in 0..<self.params.count {
                maColor.append(lineColors[i])
            }
            
            for assistSection in assistSections {
                let series = KSSeries.getRSI(
                    num: self.params.map {Int($0.value)},
                    colors: maColor,
                    section: assistSection)
                assistSection.series.append(series)
            }
            
        case KSSeriesKey.wr:
            for assistSection in assistSections {
                let series = KSSeries.getWR(lineColors[0],num: Int(self.params[0].value), section: assistSection)
                assistSection.series.append(series)
            }
        case KSSeriesKey.avg:
            let series         = KSSeries()
            series.key         = KSSeriesKey.avg
            let average        = KSChartModel.getLine(lineColors[0], title: "\(KSSeriesKey.avg)", key: "\(KSSeriesKey.avg)_\(self.params.map {Int($0.value)}[0])_\(KSSeriesKey.timeline)")
            average.section    = masterSection
            series.chartModels = [average]
            masterSection.series.append(series)
        default:break
        }
    }
    */
    
    /// 获取指标线段组
    func appendCustomIn(masterSection: KSSection,
                  assistSections: KSSection...) {
        
        let styleParam = KSStyleParam.styleParams
        //分区点线样式
        let upcolor = (UIColor(hex: styleParam.upColor), true)
        let downcolor = (UIColor(hex: styleParam.downColor), true)
        
        let lineColors = [
            UIColor(hex: styleParam.lineColors[0]),
            UIColor(hex: styleParam.lineColors[1]),
            UIColor(hex: styleParam.lineColors[2]),
        ]
        
        switch seriesKey {
        case KSSeriesKey.ma:
            
            var maColor = [UIColor]()
            for i in 0..<self.params.count {
                maColor.append(lineColors[i])
            }
            
            let series = KSSeries.getPriceMA(
                isEMA: false,
                num: self.params.map {Int($0.value)},
                colors: maColor,
                section: masterSection)
            
            
            masterSection.series.append(series)
            
            for assistSection in assistSections {
                let volumeSeries   = KSSeries.getDefaultVolume(upStyle: upcolor, downStyle: downcolor, section: assistSection)
                /*
                let volWithMASeries = KSSeries.getVolumeWithMA(upStyle: upcolor,
                                                               downStyle: downcolor,
                                                               isEMA: false,
                                                               num: self.params.map {Int($0.value)},
                                                               colors: maColor,
                                                               section: assistSection)
                */
                
                assistSection.series.append(volumeSeries)
            }
            
        case KSSeriesKey.ema:
            
            var emaColor = [UIColor]()
            for i in 0..<self.params.count {
                emaColor.append(lineColors[i])
            }
            
            let series = KSSeries.getPriceMA(
                isEMA: true,
                num: self.params.map {Int($0.value)},
                colors: emaColor,
                section: masterSection)
            
            
            masterSection.series.append(series)
            
        case KSSeriesKey.kdj:
            
            for assistSection in assistSections {
                
                let kdjSeries = KSSeries.getKDJ(
                    lineColors[0],
                    dc: lineColors[1],
                    jc: lineColors[2],
                    section: assistSection)
                kdjSeries.title = "KDJ[\(self.params[0].value.ks_indexToString()),\(self.params[1].value.ks_indexToString()),\(self.params[2].value.ks_indexToString())]"
                
                assistSection.series.append(kdjSeries)
            }
            
        case KSSeriesKey.macd:
            for assistSection in assistSections {
                
                let macdSeries = KSSeries.getMACD(
                    lineColors[0],
                    deac: lineColors[1],
                    barc: lineColors[2],
                    upStyle: upcolor, downStyle: downcolor,
                    section: assistSection)
                macdSeries.title = "MACD[\(self.params[0].value.ks_indexToString()),\(self.params[1].value.ks_indexToString()),\(self.params[2].value.ks_indexToString())]"
                macdSeries.symmetrical = true
                
                assistSection.series.append(macdSeries)
            }
        case KSSeriesKey.boll:
            // 主图Master
            let priceBOLLSeries = KSSeries.getBOLL(
                lineColors[0],
                ubc: lineColors[1],
                lbc: lineColors[2],
                section: masterSection)
            priceBOLLSeries.title = "BOLL[\(self.params[0].value.ks_indexToString()),\(self.params[1].value.ks_indexToString())]"
            priceBOLLSeries.hidden = true
            masterSection.series.append(priceBOLLSeries)
            
            // 附图 [2019.8.7加]
            for assistSection in assistSections {
                let bollSeries = KSSeries.getBollPrice(
                    upStyle: upcolor,
                    downStyle: downcolor,
                    titleColor: UIColor(white: 0.5, alpha: 1),
                    lineColors: lineColors,
                    section: assistSection,
                    showGuide: true,
                    ultimateValueStyle: .arrow(UIColor(white: 0.5, alpha: 1)))
                //bollSeries.title = "BOLL"
                bollSeries.symmetrical = false
                assistSection.series.append(bollSeries)
                /*
                 // 附图 [2019.8.7加]
                 let assistPriceBOLLSeries = KSSeries.getBOLL(
                 lineColors[0],
                 ubc: lineColors[1],
                 lbc: lineColors[2],
                 section: assistSection)
                 assistPriceBOLLSeries.title  = "ASSIST BOLL"
                 assistPriceBOLLSeries.key    = KSSeriesKey.boll
                 assistPriceBOLLSeries.hidden = false
                 assistSection.series.append(assistPriceBOLLSeries)
                 */
            }
        case KSSeriesKey.sar:
            
            let priceSARSeries = KSSeries.getSAR(
                upStyle: upcolor,
                downStyle: downcolor,
                titleColor: lineColors[0],
                section: masterSection)
            
            priceSARSeries.hidden = true
            
            masterSection.series.append(priceSARSeries)
            
        case KSSeriesKey.sam:
            
            let priceSAMSeries = KSSeries.getPriceSAM(num: Int(self.params[0].value), barStyle: (UIColor.yellow, false), lineColor: UIColor(white: 0.4, alpha: 1), section: masterSection)
            
            priceSAMSeries.hidden = true
            
            masterSection.series.append(priceSAMSeries)
            
            for assistSection in assistSections {
                
                let volWithSAMSeries = KSSeries.getVolumeWithSAM(upStyle: upcolor,
                                                                 downStyle: downcolor,
                                                                 num: Int(self.params[0].value),
                                                                 barStyle: (UIColor.yellow, false),
                                                                 lineColor: UIColor(white: 0.4, alpha: 1),
                                                                 section: assistSection)
                
                assistSection.series.append(volWithSAMSeries)
            }
            
        case KSSeriesKey.rsi:
            
            var maColor = [UIColor]()
            for i in 0..<self.params.count {
                maColor.append(lineColors[i])
            }
            
            for assistSection in assistSections {
                let series = KSSeries.getRSI(
                    num: self.params.map {Int($0.value)},
                    colors: maColor,
                    section: assistSection)
                series.title = "RSI[\(self.params[0].value.ks_indexToString()),\(self.params[1].value.ks_indexToString()),\(self.params[2].value.ks_indexToString())]"
                assistSection.series.append(series)
            }
            
        case KSSeriesKey.wr:
            for assistSection in assistSections {
                let series = KSSeries.getWR(lineColors[0],num: Int(self.params[0].value), section: assistSection)
                assistSection.series.append(series)
            }
        case KSSeriesKey.avg:
            let series         = KSSeries()
            series.key         = KSSeriesKey.avg
            let average        = KSChartModel.getLine(lineColors[0], title: "\(KSSeriesKey.avg)", key: "\(KSSeriesKey.avg)_\(self.params.map {Int($0.value)}[0])_\(KSSeriesKey.timeline)")
            average.section    = masterSection
            series.chartModels = [average]
            masterSection.series.append(series)
        default:break
        }
    }
}

class KSSeriesParamControl: NSObject, Codable {
    var value: Double = 0
    var note: String  = ""
    var min: Double   = 0
    var max: Double   = 0
    var step: Double  = 0
    
    convenience init(value: Double, note: String, min: Double, max: Double, step: Double) {
        self.init()
        self.value = value
        self.note  = note
        self.min   = min
        self.max   = max
        self.step  = step
    }
}
