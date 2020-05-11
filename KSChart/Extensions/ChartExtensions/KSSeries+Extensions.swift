//
//  KSSeries+Extensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

extension KSSeries {
    
    /// BOLL样式
    open class func getBollPrice(upStyle: (color: UIColor, isSolid: Bool),
                                   downStyle: (color: UIColor, isSolid: Bool),
                                   titleColor: UIColor,
                                   lineColors: [UIColor],
                                   section: KSSection,
                                   showGuide: Bool = false,
                                   ultimateValueStyle: KSUltimateValueStyle = .none) -> KSSeries {
        let series = KSSeries()
        series.symmetrical              = false
        series.key                      = KSSeriesKey.boll
        let bollPolyline                = KSChartModel.getBoll(upStyle: upStyle, downStyle: downStyle, titleColor: titleColor, key: KSSeriesKey.boll)
        bollPolyline.section            = section
        bollPolyline.useTitleColor      = false
        bollPolyline.showMaxVal         = showGuide
        bollPolyline.showMinVal         = showGuide
        bollPolyline.ultimateValueStyle = ultimateValueStyle

        let ubCurve                     = KSChartModel.getLine(lineColors[0], title: "UP", key: "\(KSSeriesKey.boll)_UB")
        ubCurve.section                 = section
        
        let bollCurve                   = KSChartModel.getLine(lineColors[1], title: "MID", key: "\(KSSeriesKey.boll)_BOLL")
        bollCurve.section               = section

        let lbCurve                     = KSChartModel.getLine(lineColors[2], title: "LOW", key: "\(KSSeriesKey.boll)_LB")
        lbCurve.section                 = section

        series.chartModels              = [bollPolyline, ubCurve, bollCurve, lbCurve]
        return series
    }
    
    ///返回一个WR样式
    open class func getWR(_ wrc: UIColor, num: Int, section: KSSection) -> KSSeries {
        let series         = KSSeries()
        series.key         = KSSeriesKey.wr
        let wr             = KSLineModel.getLine(wrc, title: KSSeriesKey.wr, key: "\(KSSeriesKey.wr)_\(num)")
        wr.section         = section
        series.chartModels = [wr]
        return series
    }
    
    ///分时图
    open class func getTimeChart(color: UIColor, section: KSSection, showGuide: Bool = false, ultimateValueStyle: KSUltimateValueStyle = .none, lineWidth: CGFloat = 1) -> KSSeries {
        let series                  = KSSeries()
        series.key                  = KSSeriesKey.timeline
        let timeline                = KSTimeChartModel.geTimeChart(color, title: NSLocalizedString("Price", comment: ""), key: "\(KSSeriesKey.timeline)_\(KSSeriesKey.timeline)")
        timeline.fillColor          = color.withAlphaComponent(0.1).cgColor
        timeline.section            = section
        timeline.useTitleColor      = false
        timeline.ultimateValueStyle = ultimateValueStyle
        timeline.showMaxVal         = showGuide
        timeline.showMinVal         = showGuide
        timeline.lineWidth          = lineWidth
        series.chartModels          = [timeline]
        return series
    }
}
