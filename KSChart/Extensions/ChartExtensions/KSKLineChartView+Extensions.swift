//
//  KSKLineChartView+Extensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import Foundation

// MARK: - 扩展方法
extension KSKLineChartView {
    
    /// 是否主动刷新图表
    ///
    /// - Parameter plotCount: 所有数据的个数
    /// - Returns:
    public func isActiveRefresh(plotCount:Int) -> Bool{
        //print(String.init(format: "rangeFrom:%d,rangeTo:%d,range:%d,plotCount:%d", self.rangeFrom,self.rangeTo,self.range,plotCount))
        // 如果图表尽头的索引为0，或者全部数据小于设定显示数量
        if self.rangeTo == 0 || plotCount < self.range {
            return true
        }
        
        if self.rangeTo >= plotCount {
            return true
        }
        
        if (self.rangeFrom + self.range + 1) >= plotCount {
            return true
        }
        
        return false
    }
}

// MARK: - CPU优化调试
extension KSKLineChartView {

    public func updateMasterChartSerie(key: String, hidden: Bool) {
        
        var isCandle: Bool = false
        if key == KSSeriesKey.candle {
            isCandle = true
        }
        else if key == KSSeriesKey.timeline {
            isCandle = false
        }
        else{
            return
        }
        
        for section in self.sections {
            if section.valueType == .master {
                section.specifications[KSSeriesKey.candle]   = nil
                section.specifications[KSSeriesKey.timeline] = nil
                for serie in section.series {
                    if serie.key == key {
                        serie.hidden                = hidden
                        updateSerieHidden(section: section, serie: serie)
                    }
                    if isCandle {
                        if serie.key == KSSeriesKey.timeline {
                            serie.hidden = !hidden
                            updateSerieHidden(section: section, serie: serie)
                        }
                    }
                    else{
                        if serie.key == KSSeriesKey.candle {
                            serie.hidden = !hidden
                            updateSerieHidden(section: section, serie: serie)
                        }
                    }
                }
            }
        }
    }
    
    public func updateSerieHidden(section: KSSection, serie: KSSeries) {
        if serie.hidden == false {
            section.specifications[serie.key] = serie.key
        }
    }
    
    /// 通过key隐藏或显示线系列
    /// inSection = -1时，全section都隐藏，否则只隐藏对应的索引的section
    public func updateSerie(hidden: Bool, by key: String, inSection: Int = -1) {
        var hideSections = [KSSection]()
        if inSection < 0 {
            hideSections = self.sections
        } else {
            if inSection >= self.sections.count {
                return //超过界限
            }
            hideSections.append(self.sections[inSection])
        }
        for section in hideSections {
            section.specifications.removeAll()
            for (index, serie)in section.series.enumerated() {
                if serie.key == key {
                    if section.paging {//section.paging 初始化设置为true
                        if hidden == false {
                            section.selectedIndex = index//记录选中的index
                        }
                    }
                    serie.hidden = hidden
                    updateSerieHidden(section: section, serie: serie)
                }
                else{
                    serie.hidden = true
                }
            }
        }
    }
    
    public func updateHeader(sectionType:KSSectionValueType, isOpenIndex:Bool) {
        for section in self.sections {
            if section.valueType == sectionType {
                section.isOpenIndex = isOpenIndex
            }
        }
    }
}
