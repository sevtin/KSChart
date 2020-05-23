//
//  KSTimeChartModel.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/29.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSTimeChartModel: KSChartModel {

    /// 填充颜色
    var fillColor: CGColor?
    /// 不透明度
    var shadowOpacity: Float = 0.5;
    
    ///绘制渐变曲线
    override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        let serieLayer            = KSShapeLayer()
        let timelineLayer         = KSShapeLayer()
        timelineLayer.fillColor   = KS_Chart_Color_Clear_CgColor
        timelineLayer.strokeColor = self.upStyle.color.cgColor
        timelineLayer.lineJoin    = .round
        
        let fillLayer             = KSShapeLayer()
        fillLayer.fillColor       = self.fillColor
        fillLayer.strokeColor     = KS_Chart_Color_Clear_CgColor
        
        let curvelinePath         = UIBezierPath()
        curvelinePath.lineWidth   = self.lineWidth
        
        //每个点的间隔宽度  BOLL宽度 =（宽度 - 左边间隔 - 右边间隔）/（结束点 - 开始点）
        let plotWidth             = self.latticeWidth(startIndex, endIndex: endIndex)//(self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding           = plotWidth * self.plotPaddingExt
        plotPadding               = plotPadding < 0.25 ? 0.25 : plotPadding
        let sectionHeight         = self.section.frame.size.height
        let offsetX               = self.section.frame.origin.x
        let offsetY               = self.section.frame.origin.y
        var startX: CGFloat       = 0
        var startY: CGFloat       = 0
        var endX: CGFloat         = 0
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            let closePrice = datas[i].closePrice
            //开始X: 视图X + 左边间距 + ((i - 开始index) * 蜡烛的宽)
            let ix         = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            let iyc        = self.section.getLocalY(closePrice)//收盘
            let axisX      = ix + plotWidth / 2
            
            if i == startIndex {
                startX = axisX - offsetX
                startY = iyc - offsetY
                curvelinePath.move(to: CGPoint(x: startX, y: startY))
            }
            else if i == endIndex - 1 {
                endX = axisX - offsetX
                curvelinePath.addLine(to: CGPoint(x: endX, y: iyc - offsetY))
            }
            else{
                curvelinePath.addLine(to: CGPoint(x: axisX - offsetX, y: iyc - offsetY))
            }
        }
        
        timelineLayer.path = curvelinePath.cgPath
        if endIndex == self.datas.count {
            breathLightLayer.frame.origin = CGPoint.init(x: curvelinePath.currentPoint.x-2, y: curvelinePath.currentPoint.y-2)
            //frame = CGRect.init(x: curvelinePath.currentPoint.x-1.5, y: curvelinePath.currentPoint.y-1.5, width: 3, height: 3)
            serieLayer.addSublayer(breathLightLayer)
        }
        
        curvelinePath.addLine(to: CGPoint(x: endX, y: sectionHeight))
        curvelinePath.addLine(to: CGPoint(x: startX, y: sectionHeight))
        curvelinePath.addLine(to: CGPoint(x: startX, y: startY))
        fillLayer.path = curvelinePath.cgPath
        
        serieLayer.addSublayer(fillLayer)
        serieLayer.addSublayer(timelineLayer)
        
        return serieLayer
    }
    
    lazy var breathLightLayer: KSShapeLayer = {
        let circleLayer                         = KSShapeLayer()
        let circlepath                          = UIBezierPath.init(arcCenter: CGPoint.init(x: 1, y: 1),
                                                                    radius: 2,
                                                                    startAngle: 0,
                                                                    endAngle: CGFloat(Double.pi * 2.0),
                                                                    clockwise: false)
        circleLayer.path                        = circlepath.cgPath
        circleLayer.fillColor                   = self.upStyle.color.cgColor
        circleLayer.add(self.getbreathLightAnimate(2), forKey: nil)
        return circleLayer
    }()
    
    /// 获取呼吸灯动画
    private func getbreathLightAnimate(_ time:Double) -> CAAnimationGroup {
        let scaleAnimation                     = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue               = 1
        scaleAnimation.toValue                 = 2
        scaleAnimation.autoreverses            = false
        scaleAnimation.isRemovedOnCompletion   = true
        scaleAnimation.repeatCount             = MAXFLOAT
        scaleAnimation.duration                = time
        
        let opacityAnimation                   = CABasicAnimation(keyPath:"opacity")
        opacityAnimation.fromValue             = 1.0
        opacityAnimation.toValue               = 0
        opacityAnimation.autoreverses          = false
        opacityAnimation.isRemovedOnCompletion = true
        opacityAnimation.repeatCount           = MAXFLOAT
        opacityAnimation.duration              = time
        opacityAnimation.fillMode              = CAMediaTimingFillMode.forwards
        
        let group                              = CAAnimationGroup()
        group.duration                         = time
        group.autoreverses                     = false
        group.isRemovedOnCompletion            = false// 设置为false 在各种走势图切换后，动画不会失效
        group.fillMode                         = CAMediaTimingFillMode.forwards
        group.animations                       = [scaleAnimation, opacityAnimation]
        group.repeatCount                      = MAXFLOAT
        
        return group
    }
}
