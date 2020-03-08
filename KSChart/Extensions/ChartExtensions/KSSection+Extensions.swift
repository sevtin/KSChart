//
//  KSSection+Extensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/29.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

extension KSSection {

    /// 画分区的标题
    ///
    /// - Parameter chartSelectedIndex: 分区
    func drawCustomTitle(_ chartSelectedIndex: Int) {
        
        guard self.showTitle else {
            return
        }
        
        if chartSelectedIndex == -1 {
            return//没有数据返回
        }
        
        if self.paging {//如果分页
            let series = self.series[self.selectedIndex]
            if let attributes = self.getCustomTitleAttributesByIndex(chartSelectedIndex, series: series) {
                self.setHeader(titles: attributes)
            }
        } else {
            var titleAttr = [(title: String, color: UIColor)]()
            for serie in self.series {//不分页
                if let attributes = self.getCustomTitleAttributesByIndex(chartSelectedIndex, series: serie) {
                    titleAttr.append(contentsOf: attributes)
                }
            }
            self.setHeader(titles: titleAttr)
        }
    }
    
    /// 获取指标文本
    ///
    /// - Parameters:
    ///   - chartSelectedIndex: 图表选中位置
    ///   - series: 线
    /// - Returns: 标题属性
    func getCustomTitleAttributesByIndex(_ chartSelectedIndex: Int, series: KSSeries) -> [(title: String, color: UIColor)]? {
        
        if series.hidden {
            return nil
        }
        
        guard series.showTitle else {
            return nil
        }
        
        if chartSelectedIndex == -1 {
            return nil//没有数据返回
        }
        
        var titleAttr = [(title: String, color: UIColor)]()
        
        if !series.title.isEmpty {
            let seriesTitle = series.title + "  "
            titleAttr.append((title: seriesTitle, color: self.titleColor))
        }
        
        for model in series.chartModels {
            var title = ""
            var textColor: UIColor
            let item  = model[chartSelectedIndex]
            switch model {
            case is KSCandleModel:
                if model.key != KSSeriesKey.candle {
                    continue//不限蜡烛柱
                }
                /*
                //振幅
                var amplitude: CGFloat = 0
                if item.openPrice > 0 {
                    amplitude = (item.closePrice - item.openPrice) / item.openPrice * 100
                }
                
                title += NSLocalizedString("O", comment: "") + ": " +
                    item.openPrice.ks_toString(maximum: self.decimal) + "  "   //开始
                title += NSLocalizedString("H", comment: "") + ": " +
                    item.highPrice.ks_toString(maximum: self.decimal) + "  "   //最高
                title += NSLocalizedString("L", comment: "") + ": " +
                    item.lowPrice.ks_toString(maximum: self.decimal) + "  "    //最低
                title += NSLocalizedString("C", comment: "") + ": " +
                    item.closePrice.ks_toString(maximum: self.decimal) + "  "  //收市
                title += NSLocalizedString("R", comment: "") + ": " +
                    amplitude.ks_toString(maximum: self.decimal) + "%   "      //振幅
                */
            case is KSColumnModel:
                if model.key != KSSeriesKey.volume {
                    continue //不是量线
                }
                //title += model.title + ": " + item.vol.ks_toString(maximum: self.decimal) + "  "
                title += model.title + ": " + item.volume.ks_volume()
            case is KSBollModel: break
            case is KSTimeChartModel: break
            default:
                if item.value != nil {
                    title += model.title + ": " + item.value!.ks_toString(maximum: self.decimal) + "  "
                }  else {
                    title += model.title + ": --  "
                }
            }
            
            if model.useTitleColor { //是否用标题颜色
                textColor = model.titleColor
            } else {
                switch item.trend {
                case .up, .equal:
                    textColor = model.upStyle.color
                case .down:
                    textColor = model.downStyle.color
                }
            }
            titleAttr.append((title: title, color: textColor))
        }
        return titleAttr
    }
}
