//
//  KSBubbleMenuView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSBubbleMenuView: KSBaseView {
    
    var triangleCenterX: CGFloat = 0.0
    var isTop: Bool              = true
    var strokeColor: UIColor?
    var fillColor: UIColor?
    var kitRadius: CGFloat        = 5.0
    var lineWidth: CGFloat        = 1.0

//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        
//        let kitWidth:CGFloat         = rect.size.width
//        let kitHeight:CGFloat        = rect.size.height
//        let kitRadius:CGFloat        = 10
//        let margin:CGFloat           = 5
//        let angleBottomWidth:CGFloat = 12.0
//        let lineWidth:CGFloat        = 2
//        
//        let contextRef               = UIGraphicsGetCurrentContext()
//        
//        let bezierPath               = UIBezierPath.init()
//        //起始点
//        bezierPath.move(to: CGPoint(x: kitRadius, y: margin))
//        //顶部三角
//        bezierPath.addLine(to: CGPoint(x: triangleCenterX - angleBottomWidth/2, y: margin))
//        bezierPath.addLine(to: CGPoint(x: triangleCenterX, y: 0))
//        bezierPath.addLine(to: CGPoint(x: triangleCenterX + angleBottomWidth/2, y: margin))
//        //右上角圆弧
//        bezierPath.addArc(withCenter: CGPoint(x: kitWidth - kitRadius, y: margin + kitRadius), radius: kitRadius, startAngle: -CGFloat(Double.pi / 2), endAngle: 0.0, clockwise: true)
//        //右下角圆弧
//        bezierPath.addLine(to: CGPoint(x: kitWidth - lineWidth / 2, y: kitHeight - kitRadius))
//        bezierPath.addArc(withCenter: CGPoint(x: kitWidth - kitRadius, y: kitHeight - kitRadius), radius: kitRadius, startAngle: 0.0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
//        //左下角圆弧
//        bezierPath.addLine(to: CGPoint(x: kitWidth - kitRadius, y: kitHeight - lineWidth / 2))
//        bezierPath.addArc(withCenter: CGPoint(x: kitRadius, y: kitHeight - kitRadius), radius: kitRadius, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
//        //左上角圆弧
//        bezierPath.addLine(to: CGPoint(x: lineWidth / 2, y: margin + kitRadius))
//        bezierPath.addArc(withCenter: CGPoint(x: kitRadius, y: margin + kitRadius), radius: kitRadius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi * 1.5), clockwise: true)
//        //闭合
//        bezierPath.addLine(to: CGPoint(x: kitRadius, y: margin))
//        
//        //设置线宽
//        contextRef?.setLineWidth(lineWidth)
//        
//        //路径添加到上下文
//        contextRef?.closePath()
//        contextRef?.addPath(bezierPath.cgPath)
//        
//        //设置样式
//        //UIColor.red.set()
//        UIColor.yellow.setStroke()//边框
//        UIColor.red.setFill()//填充样式
//        
//        //渲染
//        contextRef?.drawPath(using: .fillStroke)
//    }
    
//    func drawBubble() {
//
//        let kitWidth:CGFloat         = self.frame.width
//        let kitHeight:CGFloat        = self.frame.height
//        let kitRadius:CGFloat        = 10
//        let margin:CGFloat           = 5
//        let angleBottomWidth:CGFloat = 12.0
//        let lineWidth:CGFloat        = 2
//
//        let bezierPath               = UIBezierPath.init()
//        //起始点
//        bezierPath.move(to: CGPoint(x: kitRadius, y: margin))
//        //顶部三角
//        bezierPath.addLine(to: CGPoint(x: triangleCenterX - angleBottomWidth/2, y: margin))
//        bezierPath.addLine(to: CGPoint(x: triangleCenterX, y: 0))
//        bezierPath.addLine(to: CGPoint(x: triangleCenterX + angleBottomWidth/2, y: margin))
//        //右上角圆弧
//        bezierPath.addArc(withCenter: CGPoint(x: kitWidth - kitRadius, y: margin + kitRadius), radius: kitRadius, startAngle: -CGFloat(Double.pi / 2), endAngle: 0.0, clockwise: true)
//        //右下角圆弧
//        bezierPath.addLine(to: CGPoint(x: kitWidth - lineWidth / 2, y: kitHeight - kitRadius))
//        bezierPath.addArc(withCenter: CGPoint(x: kitWidth - kitRadius, y: kitHeight - kitRadius), radius: kitRadius, startAngle: 0.0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
//        //左下角圆弧
//        bezierPath.addLine(to: CGPoint(x: kitWidth - kitRadius, y: kitHeight - lineWidth / 2))
//        bezierPath.addArc(withCenter: CGPoint(x: kitRadius, y: kitHeight - kitRadius), radius: kitRadius, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
//        //左上角圆弧
//        bezierPath.addLine(to: CGPoint(x: lineWidth / 2, y: margin + kitRadius))
//        bezierPath.addArc(withCenter: CGPoint(x: kitRadius, y: margin + kitRadius), radius: kitRadius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi * 1.5), clockwise: true)
//        //闭合
//        bezierPath.addLine(to: CGPoint(x: kitRadius, y: margin))
//
//        let maskLayer                = CAShapeLayer()
//        maskLayer.frame              = CGRect(x: 0, y: 0, width: kitWidth, height: kitHeight)
//
//        let borderLayer              = CAShapeLayer()
//        borderLayer.frame            = CGRect(x: 0, y: 0, width: kitWidth, height: kitHeight)
//        borderLayer.lineWidth        = 1.0
//        borderLayer.strokeColor      = UIColor.red.cgColor
//        borderLayer.fillColor        = UIColor.orange.cgColor
//
//        maskLayer.path               = bezierPath.cgPath
//        borderLayer.path             = bezierPath.cgPath
//
//        self.layer.insertSublayer(borderLayer, at: 0)
//        self.layer.mask              = maskLayer
//    }
    
    func drawBubble() {
        let kitWidth:CGFloat          = self.frame.width
        let kitHeight:CGFloat         = self.frame.height
        let angleBottomWidth: CGFloat = 12.0
        let triangleHeight: CGFloat   = 5
        
        let triangleBottomY           = isTop ? (lineWidth + triangleHeight) : (kitHeight - lineWidth - triangleHeight)
        let cornerY                   = isTop ? lineWidth : (kitHeight - lineWidth)

        let leftTopX                  = kitRadius + lineWidth
        let leftTopY                  = isTop ? triangleBottomY : lineWidth

        let leftTopArcX               = leftTopX
        let leftTopArcY               = leftTopY + kitRadius

        let rightTopArcX              = kitWidth - lineWidth - kitRadius
        let rightTopArcY              = leftTopArcY

        let rightBottomArcX           = rightTopArcX
        let rightBottomArcY           = isTop ? (kitHeight - kitRadius) : (kitHeight - lineWidth - triangleHeight - kitRadius)

        let leftBottomArcY            = rightBottomArcY
        let leftBottomArcX            = leftTopX

        let bezierPath                = UIBezierPath.init()
        //起始点
        bezierPath.move(to: CGPoint(x: leftTopX, y: leftTopY))
        //顶部三角
        if isTop {
            bezierPath.addLine(to: CGPoint(x: triangleCenterX - angleBottomWidth / 2, y: triangleBottomY))
            bezierPath.addLine(to: CGPoint(x: triangleCenterX, y: cornerY))
            bezierPath.addLine(to: CGPoint(x: triangleCenterX + angleBottomWidth / 2, y: triangleBottomY))
        }
        //右上角圆弧
        bezierPath.addArc(withCenter: CGPoint(x: rightTopArcX, y: rightTopArcY), radius: kitRadius, startAngle: -CGFloat(Double.pi / 2), endAngle: 0.0, clockwise: true)
        //右下角圆弧
        bezierPath.addArc(withCenter: CGPoint(x: rightBottomArcX, y: rightBottomArcY), radius: kitRadius, startAngle: 0.0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
        if isTop == false {
            bezierPath.addLine(to: CGPoint(x: triangleCenterX + angleBottomWidth / 2, y: triangleBottomY))
            bezierPath.addLine(to: CGPoint(x: triangleCenterX, y: cornerY))
            bezierPath.addLine(to: CGPoint(x: triangleCenterX - angleBottomWidth / 2, y: triangleBottomY))
        }
        //左下角圆弧
        bezierPath.addArc(withCenter: CGPoint(x: leftBottomArcX, y: leftBottomArcY), radius: kitRadius, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
        //左上角圆弧
        bezierPath.addArc(withCenter: CGPoint(x: leftTopArcX, y: leftTopArcY), radius: kitRadius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi * 1.5), clockwise: true)

        let maskLayer                 = CAShapeLayer()
        maskLayer.frame               = CGRect(x: 0, y: 0, width: kitWidth, height: kitHeight)

        let borderLayer               = CAShapeLayer()
        borderLayer.frame             = CGRect(x: 0, y: 0, width: kitWidth, height: kitHeight)
        borderLayer.lineWidth         = lineWidth
        borderLayer.strokeColor       = strokeColor?.cgColor
        borderLayer.fillColor         = fillColor?.cgColor

        maskLayer.path                = bezierPath.cgPath
        borderLayer.path              = bezierPath.cgPath

        self.layer.insertSublayer(borderLayer, at: 0)
        self.layer.mask              = maskLayer
    }
}
