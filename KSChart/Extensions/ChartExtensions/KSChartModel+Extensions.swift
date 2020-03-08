//
//  KSChartModel+Extensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

// MARK: - 扩展方法
extension KSChartModel {
    //生成一个BOLL样式
    class func getBoll(upStyle: (color: UIColor, isSolid: Bool),
                         downStyle: (color: UIColor, isSolid: Bool),
                         titleColor: UIColor,
                         key: String = KSSeriesKey.candle) -> KSBollModel {
        let model = KSBollModel(upStyle: upStyle, downStyle: downStyle, titleColor: titleColor)
        model.key = key
        return model
    }
    
    func latticeWidth(_ startIndex: Int, endIndex: Int) -> CGFloat {
        if datas.count < minCandleCount {
            return fixedWidth
        }
        let plotWidth = (self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        return plotWidth
    }

    //生成分时图
    class func geTimeChart(_ color: UIColor, title: String, key: String) -> KSTimeChartModel {
        let model   = KSTimeChartModel(upStyle: (color, true), downStyle: (color, true), titleColor: color)
        model.title = title
        model.key   = key
        return model
    }
}
