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
    func isActiveRefresh(plotCount:Int) -> Bool{
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

    /// 通过key隐藏或显示线系列
    func updateSerie(hidden: Bool, key: String, isMasterCandle: Bool, index: Int = 0) {
        if index >= self.sections.count {
            return
        }
        let section = self.sections[index]
        section.updateTai(_tai: key)
        
        for serie in section.series {
            serie.hidden = (serie.key == key) ? hidden : true
            if section.valueType == .master {
                if serie.key == KSSeriesKey.timeline {
                    serie.hidden = isMasterCandle ? true : false
                }
                else if serie.key == KSSeriesKey.candle {
                    serie.hidden = isMasterCandle ? false : true
                }
            }
        }
    }
}
