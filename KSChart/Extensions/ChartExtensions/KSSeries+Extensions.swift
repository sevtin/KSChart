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
    class func getBollPrice(upStyle: (color: UIColor, isSolid: Bool),
                                   downStyle: (color: UIColor, isSolid: Bool),
                                   titleColor: UIColor,
                                   lineColors: [UIColor],
                                   section: KSSection,
                                   showGuide: Bool = false,
                                   ultimateValueStyle: KSUltimateValueStyle = .none) -> KSSeries {
        let series = KSSeries()
        series.symmetrical              = false
        series.key                      = KSSeriesKey.boll
        //series.title                    = "POLYLINE BOOL"
        let bollPolyline                = KSChartModel.getBoll(upStyle: upStyle, downStyle: downStyle, titleColor: titleColor, key: KSSeriesKey.boll)
        bollPolyline.section            = section
        bollPolyline.useTitleColor      = false
        bollPolyline.showMaxVal         = showGuide
        bollPolyline.showMinVal         = showGuide
        bollPolyline.ultimateValueStyle = ultimateValueStyle
        //series.chartModels      = [boll]

        let bollCurve                   = KSChartModel.getLine(lineColors[0], title: "BOLL", key: "\(KSSeriesKey.boll)_BOLL")
        bollCurve.section               = section

        let ubCurve                     = KSChartModel.getLine(lineColors[1], title: "UB", key: "\(KSSeriesKey.boll)_UB")
        ubCurve.section                 = section

        let lbCurve                     = KSChartModel.getLine(lineColors[2], title: "LB", key: "\(KSSeriesKey.boll)_LB")
        lbCurve.section                 = section

        series.chartModels              = [bollPolyline,bollCurve, ubCurve, lbCurve]
        return series
    }
    
    ///返回一个WR样式
    class func getWR(_ wrc: UIColor, num: Int, section: KSSection) -> KSSeries {
        let series         = KSSeries()
        series.key         = KSSeriesKey.wr
        let wr             = KSLineModel.getLine(wrc, title: KSSeriesKey.wr, key: "\(KSSeriesKey.wr)_\(num)_WR")
        wr.section         = section
        series.chartModels = [wr]
        return series
    }
    
    ///分时图
    class func getTimeChart(color: UIColor, section: KSSection, showGuide: Bool = false, ultimateValueStyle: KSUltimateValueStyle = .none, graphType: KSGraphType = .normal, lineWidth: CGFloat = 1) -> KSSeries {
        let series                  = KSSeries()
        series.key                  = KSSeriesKey.timeline
        let timeline                = KSTimeChartModel.geTimeChart(color, title: NSLocalizedString("Price", comment: ""), key: "\(KSSeriesKey.timeline)_\(KSSeriesKey.timeline)")
        timeline.gradientColors     = [color.withAlphaComponent(0.2).cgColor,color.withAlphaComponent(0.1).cgColor,color.withAlphaComponent(0.05).cgColor]
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
}
