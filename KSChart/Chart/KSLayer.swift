//
//  KSLayer.swift
//  KSChart
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

public class KSShapeLayer: CAShapeLayer {
    
    // 关闭 CAShapeLayer 的隐式动画，避免滑动时候或者十字线出现时有残影的现象(实际上是因为 Layer 的 position 属性变化而产生的隐式动画)
    override public func action(forKey event: String) -> CAAction? {
        return nil
    }
    
    func removeSubLayer() {
        _ = self.sublayers?.map { $0.removeFromSuperlayer() }
        self.sublayers?.removeAll()
    }
}

public class KSTextLayer: CATextLayer {
    
    // 关闭 CAShapeLayer 的隐式动画，避免滑动时候或者十字线出现时有残影的现象(实际上是因为 Layer 的 position 属性变化而产生的隐式动画)
    override public func action(forKey event: String) -> CAAction? {
        return nil
    }
}

class KSVerticalTextLayer : CATextLayer {
    override public func action(forKey event: String) -> CAAction? {
        return nil
    }
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(layer: aDecoder)
    }
    
    override func draw(in ctx: CGContext) {
        let height   = self.bounds.size.height
        let fontSize = self.fontSize
        let yDiff    = (height-fontSize)/2 - fontSize/10

        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}

public class KSLayer: CALayer {
    /*
    deinit {
        print("------ KSLayer deinit ------")
    }
     */
}

public class KSTopLayer: KSShapeLayer {
    lazy var barLabels: [KSTextLayer] = [KSTextLayer]()
    var isDisplayCross: Bool          = false
    
    var horizontalLineView: KSShapeLayer?
    var verticalLineView: KSShapeLayer?
    var selectedXAxisLabel: KSVerticalTextLayer?
    var selectedYAxisLabel: KSVerticalTextLayer?
    
    func initLayer(style: KSKLineChartStyle) {

        horizontalLineView                  = KSShapeLayer()
        horizontalLineView!.backgroundColor = KS_Chart_Color_Gray_CgColor
        self.addSublayer(horizontalLineView!)

        verticalLineView                    = KSShapeLayer()
        verticalLineView!.backgroundColor   = KS_Chart_Color_Gray_CgColor
        self.addSublayer(verticalLineView!)

        selectedXAxisLabel                  = self.createTextLayer(style: style)
        self.addSublayer(selectedXAxisLabel!)
        selectedYAxisLabel                  = self.createTextLayer(style: style)
        self.addSublayer(selectedYAxisLabel!)
    }
    
    func createTextLayer(style: KSKLineChartStyle) -> KSVerticalTextLayer {
        let textLayer             = KSVerticalTextLayer()
        textLayer.fontSize        = style.labelFont.pointSize
        textLayer.foregroundColor = style.selectedTextColor.cgColor
        textLayer.backgroundColor = style.selectedBGColor.cgColor
        textLayer.contentsScale   = KS_Chart_ContentsScale
        textLayer.alignmentMode   = .center
        textLayer.isWrapped       = true
        textLayer.zPosition       = 1
        return textLayer
    }
    
    func updateXAxisLabel(rect: CGRect, text: String) {
        self.selectedXAxisLabel?.frame  = rect
        self.selectedXAxisLabel?.string = text
    }
    
    func updateYAxisLabel(rect: CGRect, text: String) {
        self.selectedYAxisLabel?.frame  = rect
        self.selectedYAxisLabel?.string = text
    }
    
    func updateVerticalLine(rect: CGRect) {
        self.verticalLineView?.frame = rect
    }
    
    func updateHorizontalLine(rect: CGRect) {
        self.horizontalLineView?.frame = rect
    }
    
    func resetLayerData() {
        self.barLabels.removeAll()
    }
    
    func updateCross(isShow: Bool) {
        if isDisplayCross == isShow {
            return
        }
        self.isDisplayCross = isShow
        
        self.selectedXAxisLabel?.isHidden = !isShow
        self.selectedYAxisLabel?.isHidden = !isShow
        self.verticalLineView?.isHidden   = !isShow
        self.horizontalLineView?.isHidden = !isShow
    }
    
    func drawYAxisTitle(_ section: KSSection, labelX: CGFloat, labelY: CGFloat, alignmentMode: CATextLayerAlignmentMode,style:KSKLineChartStyle,pref: KSChartPref) {
        let yAxisLabel             = KSTextLayer()
        yAxisLabel.frame           = CGRect.init(x: labelX, y: labelY, width: pref.yAxisLabelWidth, height: section.titleHeight)
        let fontRef                = CGFont.init("Helvetica Neue" as CFString)
        yAxisLabel.font            = fontRef
        yAxisLabel.fontSize        = style.labelFont.pointSize
        yAxisLabel.foregroundColor = style.textColor.cgColor
        yAxisLabel.backgroundColor = KS_Chart_Color_Clear_CgColor
        yAxisLabel.contentsScale   = KS_Chart_ContentsScale
        yAxisLabel.alignmentMode   = alignmentMode
        yAxisLabel.zPosition       = -1
        self.addSublayer(yAxisLabel)
        section.yAxisTitles.append(yAxisLabel)
    }
    
    /// 绘制X坐标标签
    ///
    /// - Parameters:
    ///   - section: 哪个分区绘制
    ///   - xAxisToDraw: 待绘制的内容
    func drawXAxisLabel(_ section: KSSection, xAxisToDraw: [(CGRect, String)], style: KSKLineChartStyle) {
        
        guard style.showXAxisLabel else {
            return
        }
        
        guard xAxisToDraw.count > 0 else {
            return
        }
        
        let startY = section.frame.maxY //需要显示x坐标标签名字的分区，再最下方显示
        if xAxisToDraw.count > barLabels.count {
            let xAxis = KSShapeLayer()
            for _ in barLabels.count..<xAxisToDraw.count {
                let xLabelText             = KSTextLayer()
                xLabelText.alignmentMode   = CATextLayerAlignmentMode.center
                xLabelText.fontSize        = style.labelFont.pointSize
                xLabelText.foregroundColor = style.textColor.cgColor
                xLabelText.backgroundColor = KS_Chart_Color_Clear_CgColor
                xLabelText.contentsScale   = KS_Chart_ContentsScale
                xLabelText.zPosition       = -1
                barLabels.append(xLabelText)
                xAxis.addSublayer(xLabelText)
            }
            self.addSublayer(xAxis)
        }
        for i in 0..<xAxisToDraw.count {
            var barLabelRect      = xAxisToDraw[i].0
            barLabelRect.origin.y = startY
            let xLabelText        = self.barLabels[i]
            if xLabelText.frame.origin.x != barLabelRect.origin.x {
                xLabelText.frame  = barLabelRect
            }
            xLabelText.string     = xAxisToDraw[i].1
            if xLabelText.isHidden {
                xLabelText.isHidden = false
            }
        }
        if xAxisToDraw.count < self.barLabels.count {
            for i in xAxisToDraw.count..<self.barLabels.count{
                let xLabelText = self.barLabels[i]
                if xLabelText.isHidden == false {
                    xLabelText.isHidden = true
                }
            }
        }
    }
}

public class KSGridLayer: KSShapeLayer {
    
    /// 绘制分区格子
    func drawSectionGrid(_ section: KSSection, style: KSKLineChartStyle, pref: KSChartPref, topLayer: KSTopLayer) {
        var leftX                 = section.frame.origin.x + section.padding.left
        let rightX                = section.frame.maxX - section.padding.right
        let topY                  = section.frame.origin.y + section.padding.top
        let bottomY               = section.frame.maxY - section.padding.bottom
        
        var titleX: CGFloat       = 0
        var alignmentMode         = CATextLayerAlignmentMode.left

        switch style.showYAxisLabel {
        case .left:
            titleX        = style.isInnerYAxis ? leftX : section.frame.origin.x
            leftX         = style.isInnerYAxis ? leftX : pref.yAxisLabelWidth
            alignmentMode = style.isInnerYAxis ? .left : .right
        case .right:
            titleX        = style.isInnerYAxis ? rightX - pref.yAxisLabelWidth : rightX
            alignmentMode = style.isInnerYAxis ? .right : .left
        case .none: break
        }
        
        let borderPath            = UIBezierPath()
        borderPath.move(to: CGPoint.init(x: leftX, y: topY))
        borderPath.addLine(to: CGPoint.init(x: rightX, y: topY))
        borderPath.addLine(to: CGPoint.init(x: rightX, y: bottomY))
        borderPath.addLine(to: CGPoint.init(x: leftX, y: bottomY))
        borderPath.addLine(to: CGPoint.init(x: leftX, y: topY))
        
        //添加到图层
        let borderLayer           = KSShapeLayer()
        borderLayer.lineWidth     = pref.lineWidth
        borderLayer.path          = borderPath.cgPath// 从贝塞尔曲线获取到形状
        borderLayer.strokeColor   = style.lineColor.cgColor
        borderLayer.fillColor     = KS_Chart_Color_Clear_CgColor// 闭环填充的颜色
        self.addSublayer(borderLayer)
        
        let linePath              = UIBezierPath()
        let padding               = (section.frame.height - section.padding.top - section.padding.bottom) / CGFloat(section.yAxis.tickInterval-1)
        
        section.yAxisTitles.removeAll()
        for i in 0..<section.yAxis.tickInterval {
            var lineY:CGFloat = padding * CGFloat(i) + topY
            if i == section.yAxis.tickInterval - 1 {
                lineY = lineY - section.titleHeight
            }
            else if i != 0 {
                linePath.move(to: CGPoint.init(x: leftX, y: lineY))
                linePath.addLine(to: CGPoint.init(x: rightX, y: lineY))
            }
            if style.showYAxisLabel != .none {
                topLayer.drawYAxisTitle(section, labelX: titleX, labelY: lineY, alignmentMode: alignmentMode, style: style, pref: pref)
            }
        }
        
        //添加到图层
        let lineLayer         = KSShapeLayer()
        lineLayer.lineWidth   = pref.lineWidth
        lineLayer.path        = linePath.cgPath// 从贝塞尔曲线获取到形状
        lineLayer.strokeColor = style.lineColor.cgColor
        lineLayer.fillColor   = KS_Chart_Color_Clear_CgColor// 闭环填充的颜色
        self.addSublayer(lineLayer)
    }
}

