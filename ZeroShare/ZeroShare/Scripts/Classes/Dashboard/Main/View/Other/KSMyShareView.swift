//
//  KSMyShareView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSMyShareView: KSBaseView {
    
    var klineData = [KSChartItem]()
    
    lazy var chartView: KSKLineChartView = {
        let chartView      = KSKLineChartView.init(frame: self.bounds)
        let style          = loadUserStyle()
        chartView.style    = style
        chartView.delegate = self
        self.addSubview(chartView)
        return chartView
    }()
    
    var chartXAxisPrevDay: String?
    
    override func layoutSubviews() {
        self.chartView.frame = self.bounds
    }
}

extension KSMyShareView: KSKLineChartDelegate {
    
    /**
     数据源总数
     
     - parameter chart:
     
     - returns:
     */
    func numberOfPointsInKLineChart(chart: KSKLineChartView) -> Int {
        return self.klineData.count
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
        return strValue
    }
    
    /**
     获取图表X轴的显示的内容(KDJ/MACD底部时间)
     
     - parameter chart:
     - parameter index:     索引位
     
     - returns:
     */
    func kLineChart(chart: KSKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        
        let data = self.klineData[index]
        return Date.ks_getTimeByStamp(data.time, format: "HH:mm")
    }
    /// 配置各个分区小数位保留数
    ///
    /// - parameter chart:
    /// - parameter decimalForSection: 分区
    ///
    /// - returns:
    func kLineChart(chart: KSKLineChartView, decimalAt section: Int) -> Int {
        return 6
    }
    
    func dataSource(in chart: KSKLineChartView) -> [KSChartItem] {
        return self.klineData
    }
    
}

// MARK: - 自定义样式
extension KSMyShareView {
    
    func loadUserStyle() -> KSKLineChartStyle {
        
        var seriesParams: [KSSeriesParam] {
            let ma = KSSeriesParam(seriesKey: KSSeriesKey.ma,
                                   name: KSSeriesKey.ma,
                                   params: [
                                    KSSeriesParamControl(value: 5, note: "周期均线", min: 5, max: 120, step: 1),
                                    KSSeriesParamControl(value: 10, note: "周期均线", min: 5, max: 120, step: 1),
                                    KSSeriesParamControl(value: 30, note: "周期均线", min: 5, max: 120, step: 1),
                ],
                                   order: 0,
                                   hidden: false)
            
            let ema = KSSeriesParam(seriesKey: KSSeriesKey.ema,
                                    name: KSSeriesKey.ema,
                                    params: [
                                        KSSeriesParamControl(value: 7, note: "周期均线", min: 5, max: 120, step: 1),
                                        KSSeriesParamControl(value: 25, note: "周期均线", min: 5, max: 120, step: 1),
                                        KSSeriesParamControl(value: 99, note: "周期均线", min: 5, max: 120, step: 1),
                ],
                                    order: 1,
                                    hidden: false)
            
            let boll = KSSeriesParam(seriesKey: KSSeriesKey.boll,
                                     name: KSSeriesKey.boll,
                                     params: [
                                        KSSeriesParamControl(value: 20, note: "日布林线", min: 2, max: 120, step: 1),
                                        KSSeriesParamControl(value: 2, note: "倍宽度", min: 1, max: 100, step: 1),
                ],
                                     order: 2,
                                     hidden: false)
            
            let kdj = KSSeriesParam(seriesKey: KSSeriesKey.kdj,
                                    name: KSSeriesKey.kdj,
                                    params: [
                                        KSSeriesParamControl(value: 9, note: "周期", min: 2, max: 90, step: 1),
                                        KSSeriesParamControl(value: 3, note: "周期", min: 2, max: 30, step: 1),
                                        KSSeriesParamControl(value: 3, note: "周期", min: 2, max: 30, step: 1),
                ],
                                    order: 5,
                                    hidden: false)
            
            let macd = KSSeriesParam(seriesKey: KSSeriesKey.macd,
                                     name: KSSeriesKey.macd,
                                     params: [
                                        KSSeriesParamControl(value: 12, note: "快线移动平均", min: 2, max: 60, step: 1),
                                        KSSeriesParamControl(value: 26, note: "慢线移动平均", min: 2, max: 90, step: 1),
                                        KSSeriesParamControl(value: 9, note: "移动平均", min: 2, max: 60, step: 1),
                ],
                                     order: 6,
                                     hidden: false)
            
            let rsi = KSSeriesParam(seriesKey: KSSeriesKey.rsi,
                                    name: KSSeriesKey.rsi,
                                    params: [
                                        KSSeriesParamControl(value: 6, note: "相对强弱指数", min: 5, max: 120, step: 1),
                                        KSSeriesParamControl(value: 12, note: "相对强弱指数", min: 5, max: 120, step: 1),
                                        KSSeriesParamControl(value: 24, note: "相对强弱指数", min: 5, max: 120, step: 1),
                ],
                                    order: 7,
                                    hidden: false)
            return [
                ma,
                ema,
                boll,
                kdj,
                macd,
                rsi
            ]
        }
        
        var styleParam: KSStyleParam {
            let style = KSStyleParam()
            style.theme = "Dark"   //风格名，Dark，Light
            style.candleColors = "Green/Red"
            style.showYAxisLabel = "right"
            style.isInnerYAxis = false
            style.backgroundColor = 0x152036
            style.textColor = 0x627C9E
            style.selectedTextColor = 0xFFFFFF
            style.lineColor = 0x29344A
            style.upColor = 0x03AD8F
            style.downColor = 0xDE345B
            style.lineColors = [
                0xff783c,
                0x49a5ff,
                0x8A2BE2,
            ]
            style.isInnerYAxis = false
            return style
        }
        
        let style               = KSKLineChartStyle()
        style.labelFont         = UIFont.systemFont(ofSize: 10)
        style.lineColor         = UIColor(hex: styleParam.lineColor)//边框线颜色
        style.textColor         = UIColor(hex: styleParam.textColor)//下边和右边字的颜色
        style.selectedBGColor   = UIColor.ks_rgba(41, 52, 74)//选中时下边右边字的背景颜色
        style.selectedTextColor = UIColor(hex: styleParam.selectedTextColor)//选中时下边右边字的颜色
        style.backgroundColor   = UIColor(hex: styleParam.backgroundColor)//视图背景颜色
        //style.crosshairColor    = KS_Color_Crosshair//十字线颜色
        style.isInnerYAxis      = styleParam.isInnerYAxis
        
        if styleParam.showYAxisLabel == "Left" {
            style.showYAxisLabel = .left
            style.padding = UIEdgeInsets(top: 32, left: 0, bottom: 4, right: 8)
            
        } else {
            style.showYAxisLabel = .right
            style.padding = UIEdgeInsets(top: 32, left: 8, bottom: 4, right: 0)
        }
        
        //====================== 配置分区样式 ======================
        /// 主图
        let upcolor                       = (UIColor.ks_hex(styleParam.upColor), true)
        let downcolor                     = (UIColor.ks_hex(styleParam.downColor), true)
        let priceSection                  = KSSection()
        priceSection.backgroundColor      = style.backgroundColor
        priceSection.titleShowOutSide     = true
        priceSection.valueType            = .master
        priceSection.key                  = "master"
        priceSection.hidden               = false
        priceSection.ratios               = 3
        priceSection.padding              = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        /// 副图1
        let assistSection1                = KSSection()
        assistSection1.backgroundColor    = style.backgroundColor
        assistSection1.valueType          = .assistant
        assistSection1.key                = "assist1"
        assistSection1.hidden             = false//视图是否显示false:显示true:影藏
        assistSection1.ratios             = 1
        assistSection1.paging             = true
        assistSection1.yAxis.tickInterval = 4
        assistSection1.padding            = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)

        //====================== 配置分区样式 ======================
        /// 时分线
        let timelineSeries = KSSeries.getTimelinePrice(
            color: UIColor.ks_hex(0x03AD8F),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .circle(UIColor.ks_hex(0x03AD8F), true),
            graphType: .timeChart,
            lineWidth: 1)
        timelineSeries.hidden = true
        
        /// 蜡烛线
        let priceSeries = KSSeries.getCandlePrice(
            upStyle: upcolor,
            downStyle: downcolor,
            titleColor: UIColor(white: 0.8, alpha: 1),
            section: priceSection,
            showGuide: true,
            ultimateValueStyle: .arrow(UIColor(white: 0.8, alpha: 1)))
        priceSeries.showTitle = true
        priceSeries.chartModels.first?.ultimateValueStyle = .arrow(UIColor(white: 0.8, alpha: 1))
        
        priceSection.series.append(timelineSeries)
        priceSection.series.append(priceSeries)
        
        //====================== 读取用户配置中线段 ======================
        for series in seriesParams {
            if series.hidden {
                continue
            }
            //添加指标线段
            series.appendIn(masterSection: priceSection, assistSections: assistSection1)
        }
        
        style.sections.append(priceSection)
        if assistSection1.series.count > 0 {
            style.sections.append(assistSection1)
        }
        /*
         if assistSection2.series.count > 0 {
         style.sections.append(assistSection2)
         }
         */
        return style
    }
}

