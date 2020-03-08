//
//  KSTimeChartModel.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/29.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSTimeChartModel: KSChartModel {
    /// 曲线类型
    var graphType: KSGraphType = .normal
    /// 渐变颜色
    var gradientColors: [CGColor]?
    /// 阴影偏移
    var shadowOffset: CGSize   = CGSize.init(width: 0, height: 2)
    /// 不透明度
    var shadowOpacity: Float = 0.5;
    
    ///绘制渐变曲线
    override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        let serieLayer               = KSShapeLayer()
        let timelineLayer            = KSShapeLayer()
        let curvelineLayer           = KSShapeLayer()
        curvelineLayer.fillColor     = UIColor.clear.cgColor
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
        
        if endIndex == self.datas.count {
            breathLightLayer.frame.origin = CGPoint.init(x: curvelinePath.currentPoint.x-1.5, y: curvelinePath.currentPoint.y-1.5)
            //frame = CGRect.init(x: curvelinePath.currentPoint.x-1.5, y: curvelinePath.currentPoint.y-1.5, width: 3, height: 3)
            serieLayer.addSublayer(breathLightLayer)
        }
        serieLayer.addSublayer(curvelineLayer)
        serieLayer.addSublayer(gradientLayer)
        
        return serieLayer
    }
    
    lazy var breathLightLayer: KSLayer = {
        let breathLightLayer             = KSLayer()
        breathLightLayer.backgroundColor = self.upStyle.color.cgColor//UIColor.kschart.color(rgba: "#0095e1").cgColor
        breathLightLayer.cornerRadius    = 1.5
        let layer                        = KSLayer()
        layer.frame                      = CGRect(x: 0, y: 0, width: 3, height: 3)
        layer.backgroundColor            = self.upStyle.color.cgColor//UIColor.kschart.color(rgba: "#0095e1").cgColor
        layer.cornerRadius               = 1.5
        layer.add(self.getbreathLightAnimate(2), forKey: nil)
        breathLightLayer.addSublayer(layer)
        return breathLightLayer
    }()
    
    /// 获取呼吸灯动画
    private func getbreathLightAnimate(_ time:Double) -> CAAnimationGroup {
        let scaleAnimation                     = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue               = 1
        scaleAnimation.toValue                 = 3.5
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
