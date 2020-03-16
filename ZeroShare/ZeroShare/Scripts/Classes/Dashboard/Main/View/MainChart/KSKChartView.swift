//
//  KSKChartView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit
@objc protocol KSKChartViewDelegate : NSObjectProtocol {
    @objc optional func kchartView(chart: KSKChartView, didSelectAt index: Int, item: KSChartItem)
    @objc optional func kchartView(chart: KSKChartView, displayCross: Bool)
    @objc optional func kchartViewTouch(chart: KSKChartView)
}
class KSKChartView: KSBaseView {
    
    var klineData = [KSChartItem]()
    var configure: KSChartConfigure = KSChartConfigure.init()
    
    weak var delegate: KSKChartViewDelegate?
    
    lazy var chartView: KSZeroChartView = {
        let chartView         = KSZeroChartView(frame: self.bounds)
        let style             = configure.loadConfigure()
        chartView.style       = style
        chartView.delegate    = self
        self.addSubview(chartView)
        return chartView
    }()
    
    var chartXAxisPrevDay: String?
    
    override func layoutSubviews() {
        self.chartView.frame = self.bounds
    }
    
    func resetChart(datas: [KSChartItem]) {
        chartView.selectedIndex = -1
        klineData               = datas
    }
}

extension KSKChartView: KSKLineChartDelegate {
    /**
     数据源总数
     
     - parameter chart:
     
     - returns:
     */
    func numberOfPoints(chart: KSKLineChartView) -> Int {
        return self.klineData.count
    }
    
    func dataSource(chart: KSKLineChartView) -> [KSChartItem] {
        return klineData
    }
    /**
     数据源索引为对应的对象
     
     - parameter chart:
     - parameter index: 索引位
     
     - returns: K线数据对象
     */
    func kLineChart(chart: KSKLineChartView, valueForPointAtIndex index: Int) -> KSChartItem {
        let item = self.klineData[index]
        return item
    }
    
    /**
     获取图表Y轴的显示的内容(右侧Y轴)
     
     - parameter chart:
     - parameter value:     计算得出的y值
     
     - returns:
     */
    func kLineChart(chart: KSKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: KSSection) -> String {
        /*
        var strValue = ""
        if section.key == "volumn" {
            if value / 1000 > 1 {
                strValue = (value / 1000).ks_toString(maximum: section.decimal) + "K"
            } else {
                strValue = value.ks_toString(maximum: section.decimal)
            }
        } else {
            strValue = value.ks_toString(maximum: section.decimal)
        }
        */
        return ""
    }
    
    /**
     获取图表X轴的显示的内容(KDJ/MACD底部时间)
     
     - parameter chart:
     - parameter index:     索引位
     
     - returns:
     */
    func kLineChart(chart: KSKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.klineData[index]
        return Date.ks_getTimeByStamp(data.time, format: configure.dateFormat)
    }
    /// 配置各个分区小数位保留数
    ///
    /// - parameter chart:
    /// - parameter decimalForSection: 分区
    ///
    /// - returns:
    func kLineChart(chart: KSKLineChartView, decimalAt section: Int) -> Int {
        return configure.decimal
    }

    func widthForYAxisLabelInKLineChart(chart: KSKLineChartView) -> CGFloat {
        return 0
    }
    
    func kLineChart(chart: KSKLineChartView, didSelectAt index: Int, item: KSChartItem) {
        if self.klineData.count > 1 && index > 0{
            let yesterItem   = self.klineData[index - 1]
            item.yesterPrice = yesterItem.closePrice
            /*
            if yesterItem.close == item.open {
                item.openType = .equal
            }
            else if yesterItem.close > item.open {
                item.openType = .down
            }
            else{
                item.openType = .up
            }
             */
        }
        self.delegate?.kchartView?(chart: self, didSelectAt: index, item: item)
    }
    
    func kLineChart(chart: KSKLineChartView, displayCross: Bool) {
        self.delegate?.kchartView?(chart: self, displayCross: displayCross)
    }
    
    func kLineChartTapAction(chart: KSKLineChartView) {
        self.delegate?.kchartViewTouch?(chart: self)
    }
    
}
