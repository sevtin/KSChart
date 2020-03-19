//
//  KSChartConfigure.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/27.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSChartConfigure: NSObject {
    var dateFormat:String = "yyyy-MM-dd"
    var decimal:Int       = 8
}

// MARK: - 自定义样式
extension KSChartConfigure {
    
    public func loadConfigure() -> KSKLineChartStyle {

        /// 默认指标
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
        
        let styleParams: KSStyleParam = KSStyleParam.styleParams
        
        let style                     = KSKLineChartStyle()
        style.labelFont               = KS_Const_Font_Normal_10
        style.lineColor               = KS_Const_Color_Chart_Line//UIColor(hex: styleParams.lineColor)//边框线颜色
        style.textColor               = UIColor(hex: styleParams.textColor)//下边和右边字的颜色
        style.selectedBGColor         = UIColor(hex: 0x666F80)//选中时下边右边字的背景颜色
        style.selectedTextColor       = UIColor(hex: styleParams.selectedTextColor)//选中时下边右边字的颜色
        style.backgroundColor         = KS_Const_Color_Clear//UIColor(hex: styleParams.backgroundColor)//视图背景颜色
        style.crosshairColor          = UIColor(hex: 0x666F80)//十字线颜色
        style.isInnerYAxis            = styleParams.isInnerYAxis
        style.showYAxisLabel          = KSYAxisShowPosition.none//显示y的位置，默认右边
        style.padding                 = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
        style.chartTais               = [KSSeriesKey.candle: .none,
                                         KSSeriesKey.timeline: .timeline,
                                         KSSeriesKey.volume: .none,
                                         KSSeriesKey.ma: .ma(5, 10, 30),
                                         KSSeriesKey.ema: .ema(7, 25, 99),
                                         KSSeriesKey.kdj: .kdj(9, 3, 3),
                                         KSSeriesKey.macd: .macd(12, 26, 9),
                                         KSSeriesKey.boll: .boll(20, 2),
                                         KSSeriesKey.rsi: .rsi(6, 12, 24),
                                         KSSeriesKey.avg: .avg(5)]
        
        //====================== 配置分区样式 ======================
        /// 主图
        let upcolor                         = (UIColor.ks_hex(styleParams.upColor), true)
        let downcolor                       = (UIColor.ks_hex(styleParams.downColor), true)
        let priceSection                    = KSSection()
        priceSection.backgroundColor        = style.backgroundColor
        priceSection.titleShowOutSide       = false
        priceSection.valueType              = .master
        priceSection.key                    = "master"
        priceSection.hidden                 = false
        priceSection.ratios                 = 3
        priceSection.yAxis.tickInterval     = 5
        priceSection.xAxis.referenceStyle   = .solid(color: KS_Const_Color_Chart_Line)
        priceSection.padding                = UIEdgeInsets(top: 64, left: 0, bottom: 16, right: 0)
        priceSection.tai                    = KSSeriesKey.ma

        /// 副图1
        let assistSection1                  = KSSection()
        assistSection1.backgroundColor      = style.backgroundColor
        assistSection1.valueType            = .assistant
        assistSection1.key                  = "assist1"
        assistSection1.hidden               = false//视图是否显示false:显示true:影藏
        assistSection1.ratios               = 1
        assistSection1.paging               = false
        assistSection1.yAxis.tickInterval   = 5
        assistSection1.xAxis.referenceStyle = .solid(color: KS_Const_Color_Chart_Line)
        assistSection1.padding              = UIEdgeInsets(top: 16, left: 0, bottom: 4, right: 0)
        assistSection1.tai                  = KSSeriesKey.volume

        /// 副图2
        let assistSection2                  = KSSection()
        assistSection2.backgroundColor      = style.backgroundColor
        assistSection2.valueType            = .assistant
        assistSection2.key                  = "assist2"
        assistSection2.hidden               = false//视图是否显示false:显示true:影藏
        assistSection2.ratios               = 1
        assistSection2.paging               = true
        assistSection2.yAxis.tickInterval   = 5
        assistSection2.xAxis.referenceStyle = .solid(color: KS_Const_Color_Chart_Line)
        assistSection2.padding              = UIEdgeInsets(top: 16, left: 0, bottom: 4, right: 0)
        assistSection2.tai                  = KSSeriesKey.volume

        //====================== 配置分区样式 ======================
        /// 时分线
        let timelineSeries = KSSeries.getTimeChart(
            color: KS_Const_Color_Chart_TimeLine,
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
        priceSeries.chartModels.first?.ultimateValueStyle = .tag(UIColor(white: 0.8, alpha: 1))
        
        priceSection.series.append(timelineSeries)
        priceSection.series.append(priceSeries)
        
        //====================== 读取用户配置中线段 ======================
        for series in seriesParams {
            if series.hidden {
                continue
            }
            //添加指标线段
            series.appendCustomIn(masterSection: priceSection, assistSections: assistSection1, assistSection2)
        }
        
        style.sections.append(priceSection)
        if assistSection1.series.count > 0 {
            style.sections.append(assistSection1)
        }
        
        if assistSection2.series.count > 0 {
            style.sections.append(assistSection2)
        }
        return style
    }
}
