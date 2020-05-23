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
    
    lazy var klineData = [KSChartItem]()
    lazy var configure: KSChartConfigure = KSChartConfigure.init()
    
    weak var delegate: KSKChartViewDelegate?
    
    lazy var chartView: KSKLineChartView = {
        let chartView         = KSKLineChartView(frame: self.bounds)
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
        chartView.resetChartData()
        klineData                    = datas
    }
}

extension KSKChartView: KSKLineChartDelegate {
    
    func ksLineChartDataSource(_ lineChart: KSKLineChartView) -> [KSChartItem] {
        return klineData
    }
    
    func ksLineChart(_ lineChart: KSKLineChartView, xAxisTextForIndex index: Int) -> String {
        let data = self.klineData[index]
        return Date.ks_getTimeByStamp(data.time, format: configure.dateFormat)
    }
    
    func ksLineChart(_ lineChart: KSKLineChartView, decimalAt section: Int) -> Int {
        return configure.decimal
    }
    
    func ksLineChart(_ lineChart: KSKLineChartView, didSelectAt index: Int, item: KSChartItem) {
        if self.klineData.count > 1 && index > 0{
            let yesterItem   = self.klineData[index - 1]
            item.yesterPrice = yesterItem.closePrice
        }
        //CPU 10%左右的消耗
        self.delegate?.kchartView?(chart: self, didSelectAt: index, item: item)
    }
    
    func ksLineChart(_ lineChart: KSKLineChartView, rowTitleInSection section: KSSection, titleValue: CGFloat) -> String {
        return titleValue.ks_thousand(section.decimal)
    }
    
    func ksLineChart(_ lineChart: KSKLineChartView, displayCross: Bool) {
        self.delegate?.kchartView?(chart: self, displayCross: displayCross)
    }
    
}
