//
//  KSZeroChartView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/15.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSZeroChartView: KSKLineChartView {

    /*
    override func defaultConfigure() {
        super.defaultConfigure()
        self.layer.addSublayer(self.gridLayer)
        self.gridLayer.zPosition = -1
        self.drawGrids()
    }*/
    /// 设置选中的数据点,并回调 10%
    ///
    /// - Parameter index: 选中位置
    override func setSelectedByIndex(_ index: Int) {
        if index >= self.datas.count {
            return
        }
        //如果不在区间内return
        guard index >= self.pref.rangeFrom && index < self.pref.rangeTo else {
            return
        }
        let item                = self.datas[index]
        //回调给代理委托方法
        self.delegate?.kLineChart?(chart: self, didSelectAt: index, item: item)
    }
    
    /// 处理长按操作
    ///
    /// - Parameter sender:
    override func doLongPressAction(_ sender: UILongPressGestureRecognizer) {
        super.doLongPressAction(sender)

        if self.pref.isLongPressMoveX {
            for section in self.style.sections {
                //绘制顶部技术指标,例如:BOOL:0.0251 UB:0.0252 LB:0.0250
                section.drawCustomTitle(self.pref.selectedIndex)
            }
            self.delegate?.kLineChartTapAction?(chart: self)
        }
    }
    
    /*
    /// 显示选中的数据点的时间和价格
    ///
    /// - Parameter point:
    override func setSelectedIndexByPoint(_ point: CGPoint) {
        
        if self.enableTap == false {
            return
        }
        
        if point.equalTo(CGPoint.zero) {
            return
        }
        
        let (_, section) = self.getSectionByTouchPoint(point)
        if section == nil {
            return
        }
        
        let visiableSections = self.style.sections.filter { !$0.hidden }
        guard let lastSection = visiableSections.last else {
            return
        }

        let showXAxisSection              = self.getSecionWhichShowXAxis()
        self.pref.selectedPoint           = point

        //每个点的宽度
        let plotWidth                     = self.latticeWidth(section: section!)
        var yVal: CGFloat                 = 0//获取y轴坐标的实际值

        let isLeft                        = point.x < (self.frame.width / 2)
        let horizontalValueWidth: CGFloat = 60
        let offsetX: CGFloat              = 5
        for i in self.pref.rangeFrom...self.pref.rangeTo - 1 {
            //每个点的宽度 * index + 内视图左边偏移 + 自身左边偏移
            let ixs = plotWidth * CGFloat(i - self.pref.rangeFrom) + section!.padding.left + self.style.padding.left
            let ixe = plotWidth * CGFloat(i - self.pref.rangeFrom + 1) + section!.padding.left + self.style.padding.left

            //点在区间内
            if ixs <= point.x && point.x < ixe {
                self.pref.selectedIndex        = i
                let item                       = self.datas[i]
                var hx                         = section!.frame.origin.x + section!.padding.left
                hx                             = hx + plotWidth * CGFloat(i - self.pref.rangeFrom) + plotWidth / 2
                let hy                         = self.style.padding.top
                let hheight                    = lastSection.frame.maxY
                //显示辅助线
                self.horizontalLineView?.frame = CGRect(x: hx, y: hy, width: self.pref.lineWidth, height: hheight - hy)

                let vx                         = section!.frame.origin.x + section!.padding.left
                var vy: CGFloat                = 0
                
                //处理水平线y的值
                switch self.pref.selectedPosition {
                case .free:
                    vy = point.y
                    yVal = section!.getRawValue(point.y) //获取y轴坐标的实际值
                case .onClosePrice:
                    if let series = section?.getSeries(key: KSSeriesKey.candle), !series.hidden {
                        yVal = item.closePrice          //获取收盘价作为实际值
                    }
                    else if let series = section?.getSeries(key: KSSeriesKey.timeline), !series.hidden {
                        yVal = item.closePrice          //获取收盘价作为实际值
                    }
                    else if let series = section?.getSeries(key: KSSeriesKey.volume), !series.hidden {
                        yVal = item.vol                 //获取交易量作为实际值
                    }
                    
                    vy = section!.getLocalY(yVal)
                    
                }
                let hwidth                    = section!.frame.size.width - section!.padding.left - section!.padding.right
                //显示辅助线
                self.verticalLineView?.frame  = CGRect(x: vx, y: vy - self.pref.lineWidth / 2, width: hwidth, height: self.pref.lineWidth)

                //显示y轴辅助内容
                //控制y轴的label在左还是右显示
                var yAxisStartX: CGFloat      = 0

                self.selectedYAxisLabel?.text = item.close//String(format: format, yVal)//显示收盘价
                if isLeft {
                    yAxisStartX = section!.frame.origin.x
                    if point.x < (horizontalValueWidth + offsetX) {
                        yAxisStartX = section!.frame.width - horizontalValueWidth
                    }
                }
                else{
                    yAxisStartX = section!.frame.width - horizontalValueWidth
                    if point.x > yAxisStartX - offsetX {
                        yAxisStartX = section!.frame.origin.x
                    }
                }
                self.selectedYAxisLabel?.frame = CGRect(x: yAxisStartX, y: vy - self.labelSize.height / 2, width: horizontalValueWidth, height: self.labelSize.height)

                let dateFormat                 = self.delegate?.kLineChart?(chart: self, labelOnXAxisForIndex: i) ?? "MM-dd HH:mm"
                let time                       = Date.ks_getTimeByStamp(item.time, format: dateFormat)//显示时间
                let size                       = time.ks_sizeWithConstrained(self.style.labelFont)
                self.selectedXAxisLabel?.text  = time

                //判断x是否超过左右边界
                let labelWidth                 = size.width  + 6
                var x                          = hx - (labelWidth) / 2

                if x < section!.frame.origin.x {
                    x = section!.frame.origin.x
                } else if x + labelWidth > section!.frame.origin.x + section!.frame.size.width {
                    x = section!.frame.origin.x + section!.frame.size.width - labelWidth
                }
                
                self.selectedXAxisLabel?.frame = CGRect(x: x, y: showXAxisSection.frame.maxY, width: size.width  + 6, height: self.labelSize.height)
                
                //给用户进行最后的自定义
                //self.delegate?.kLineChart?(chart: self, viewOfYAxis: self.selectedXAxisLabel!, viewOfXAxis: self.selectedYAxisLabel!)
                
                self.showSelection = true
                if self.pref.isCrosshair {
                    self.sightView?.center     = CGPoint(x: hx, y: vy)
                }
                
                self.bringSubviewToFront(self.verticalLineView!)
                self.bringSubviewToFront(self.horizontalLineView!)
                self.bringSubviewToFront(self.selectedXAxisLabel!)
                self.bringSubviewToFront(self.selectedYAxisLabel!)
                if self.pref.isCrosshair {
                    self.bringSubviewToFront(self.sightView!)
                }

                //设置选中点
                self.setSelectedByIndex(i)
                self.selectedYAxisLabel?.isHidden = false
                break
            }
        }
    }*/
    
    /// 通过CALayer方式画图表
    override func drawLayerView() {
        //先清空图层
        self.removeLayerView()
        //初始化数据
        if self.initChart() {
            
            /// 待绘制的x坐标标签
            var xAxisToDraw = [(CGRect, String)]()
            
            //闭包，建立每个分区，分区几个回调几次
            self.buildSections {(section, index) in

                //获取各section的小数保留位数
                let decimal     = self.delegate?.kLineChart?(chart: self, decimalAt: index) ?? 2
                section.decimal = decimal

                //初始Y轴的数据
                self.initYAxis(section)

                //绘制每个区域
                self.drawSection(section)//[绘制每个区域顶部区域]
                xAxisToDraw     = self.drawXAxis(section)//[绘制辅助线返回底部时间Rect]
                //绘制图表的点线
                self.drawChart(section)//[--- 绘制每个区域主视图(绘制K线/均价曲线/成交量/指数指标) ---]
                //把标题添加到主绘图层上
                self.drawLayer.addSublayer(section.titleLayer)//[绘制最顶部价格/指标值等数据]

                //绘制顶部指标
                if self.showSelection == false {
                    if self.datas.count > 0 {
                        self.pref.selectedIndex = self.datas.count - 1
                    }
                }
                section.drawCustomTitle(self.pref.selectedIndex)
                //绘制数值
                //self.drawRowValue(section)
            }
            
            let showXAxisSection = self.getSecionWhichShowXAxis()
            //显示在分区下面绘制X轴坐标[底部时间]
            self.drawXAxisLabel(showXAxisSection, xAxisToDraw: xAxisToDraw)
            //重新显示点击选中的坐标
            if self.showSelection {
                self.setSelectedIndexByPoint(self.pref.selectedPoint)
            }
        }
    }
}
