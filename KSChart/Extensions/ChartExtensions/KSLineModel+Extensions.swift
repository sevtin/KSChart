//
//  KSLineModel+Extensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/13.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

extension KSLineModel {
    ///绘制渐变曲线
    func drawTimeChartSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        let serieLayer               = KSShapeLayer()
        let timelineLayer            = KSShapeLayer()
        let curvelineLayer           = KSShapeLayer()
        curvelineLayer.fillColor     = KS_Chart_Color_Clear_CgColor
        curvelineLayer.strokeColor   = self.upStyle.color.cgColor
        curvelineLayer.lineWidth     = self.lineWidth
        curvelineLayer.shadowColor   = self.upStyle.color.cgColor
        curvelineLayer.shadowOffset  = self.shadowOffset
        curvelineLayer.shadowOpacity = self.shadowOpacity;
        //curvelineLayer.lineCap     = .round
        //curvelineLayer.lineJoin    = .round

        let timelinePath             = UIBezierPath()
        timelinePath.lineWidth       = self.lineWidth

        let curvelinePath            = UIBezierPath()
        curvelinePath.lineWidth      = self.lineWidth

        let gradientLayer            = CAGradientLayer()
        gradientLayer.colors         = gradientColors

        //每个点的间隔宽度  BOLL宽度 =（宽度 - 左边间隔 - 右边间隔）/（结束点 - 开始点）
        let plotWidth                = self.latticeWidth(startIndex, endIndex: endIndex)//(self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding              = plotWidth * self.plotPaddingExt
        plotPadding                  = plotPadding < 0.25 ? 0.25 : plotPadding
        let sectionHeight            = self.section.frame.size.height + self.section.padding.top + self.section.padding.bottom
        let offsetX                  = self.section.frame.origin.x
        let offsetY                  = self.section.frame.origin.y

        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            let closePrice = datas[i].closePrice
            //开始X: 视图X + 左边间距 + ((i - 开始index) * 蜡烛的宽)
            let ix         = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            let iyc        = self.section.getLocalY(closePrice)//收盘
            let axisX      = ix + plotWidth / 2
            
            if i == startIndex {
                timelinePath.move(to: CGPoint(x: axisX - offsetX, y: sectionHeight))
                timelinePath.addLine(to: CGPoint(x: axisX - offsetX, y: iyc - offsetY))
                
                curvelinePath.move(to: CGPoint(x: axisX, y: iyc))
            }
            else if i == endIndex - 1 {
                timelinePath.addLine(to: CGPoint(x: axisX - offsetX, y: iyc - offsetY))
                timelinePath.addLine(to: CGPoint(x: axisX - offsetX, y: sectionHeight))
                
                curvelinePath.addLine(to: CGPoint(x: axisX, y: iyc))
            }
            else{
                timelinePath.addLine(to: CGPoint(x: axisX - offsetX, y: iyc - offsetY))
    
                curvelinePath.addLine(to: CGPoint(x: axisX, y: iyc))
            }
        }
        curvelineLayer.path = curvelinePath.cgPath

        timelineLayer.path  = timelinePath.cgPath
        gradientLayer.mask  = timelineLayer
        
        gradientLayer.frame = CGRect.init(x: self.section.frame.origin.x,
                                          y: self.section.frame.origin.y,
                                          width: self.section.frame.size.width - self.section.padding.right,
                                          height: self.section.frame.size.height)

        serieLayer.addSublayer(curvelineLayer)
        serieLayer.addSublayer(gradientLayer)
        return serieLayer
    }
}
