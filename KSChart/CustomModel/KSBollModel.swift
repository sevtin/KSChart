//
//  KSBollModel.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSBollModel: KSChartModel {

    /// 绘制Boll
    ///
    /// - Parameters:
    ///   - startIndex: 起始索引
    ///   - endIndex: 结束索引
    /// - Returns: 点与点之间间断所占点宽的比例
    override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {

        let serieLayer  = CAShapeLayer()
        //每个点的间隔宽度  BOLL宽度 =（宽度 - 左边间隔 - 右边间隔）/（结束点 - 开始点）
        let plotWidth   = self.latticeWidth(startIndex, endIndex: endIndex)//(self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding = plotWidth * self.plotPaddingExt
        plotPadding     = plotPadding < 0.25 ? 0.25 : plotPadding

        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            let bollLayer = CAShapeLayer()
            let item = datas[i]

            //开始X: 视图X + 左边间距 + ((i - 开始index) * 蜡烛的宽)
            let ix        = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            //结束X
            let iNx       = self.section.frame.origin.x + self.section.padding.left + CGFloat(i + 1 - startIndex) * plotWidth

            //把具体的数值转为坐标系的y值
            let iyo       = self.section.getLocalY(item.openPrice)//开盘
            let iyc       = self.section.getLocalY(item.closePrice)//收盘
            let iyh       = self.section.getLocalY(item.highPrice)//最高
            let iyl       = self.section.getLocalY(item.lowPrice)//最低
            //如果最高价 > 收盘价 || 最高价 > 开盘价
            /*
            if iyh > iyc || iyh > iyo {
                NSLog("highPrice = \(item.highPrice), closePrice = \(item.closePrice), openPrice = \(item.openPrice)")
            }
             */
            
            switch item.trend {
            case .equal:
                //开盘收盘一样，则显示横线
                bollLayer.strokeColor = self.upStyle.color.cgColor
            case .up:
                //收盘价比开盘高，则显示涨的颜色
                bollLayer.strokeColor = self.upStyle.color.cgColor
            case .down:
                //收盘价比开盘低，则显示跌的颜色
                bollLayer.strokeColor = self.downStyle.color.cgColor
            }

            let axisX      = ix + plotWidth / 2
            let startPath  = UIBezierPath()
            startPath.move(to: CGPoint(x: ix+plotPadding, y: iyo))
            startPath.addLine(to: CGPoint(x: axisX, y: iyo))

            let axisPath   = UIBezierPath()
            axisPath.move(to: CGPoint(x: axisX, y: iyl))
            axisPath.addLine(to: CGPoint(x: axisX, y: iyh))
            startPath.append(axisPath)

            let endPath    = UIBezierPath()
            endPath.move(to: CGPoint(x: axisX, y: iyc))
            endPath.addLine(to: CGPoint(x: iNx-plotPadding, y: iyc))
            startPath.append(endPath)

            bollLayer.path = startPath.cgPath
            serieLayer.addSublayer(bollLayer)
        }
        return serieLayer
    }
}
