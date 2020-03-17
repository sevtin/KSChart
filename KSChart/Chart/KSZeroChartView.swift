//
//  KSZeroChartView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/15.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSZeroChartView: KSKLineChartView {

    /// 设置选中的数据点,并回调
    ///
    /// - Parameter index: 选中位置
    override func setSelectedByIndex(_ index: Int) {
        if index >= self.datas.count {
            return
        }
        //如果不在区间内return
        guard index >= self.rangeFrom && index < self.rangeTo else {
            return
        }
        self.selectedIndex = index
        let item           = self.datas[index]
        //回调给代理委托方法
        self.delegate?.kLineChart?(chart: self, didSelectAt: index, item: item)
    }

    /// 平移拖动操作
    ///
    /// - Parameter sender: 手势
    override func doPanAction(_ sender: UIPanGestureRecognizer) {
        //防止数量较少时,显示异常
        if self.plotCount < self.minCandleCount {
            return
        }
        super.doPanAction(sender)
    }
    
    /// 处理长按操作
    ///
    /// - Parameter sender:
    override func doLongPressAction(_ sender: UILongPressGestureRecognizer) {
        
        super.doLongPressAction(sender)
        
        self.buildSections {(section, index) in
            //绘制顶部技术指标,例如:BOOL:0.0251 UB:0.0252 LB:0.0250
            section.drawCustomTitle(self.selectedIndex)
        }
        
        switch sender.state {
        case .ended:
            self.hideCross()
        default: break
        }
        self.delegate?.kLineChartTapAction?(chart: self)
    }
    
    /// 双指手势缩放图表
    ///
    /// - Parameter sender: 手势
    @objc override func doPinchAction(_ sender: UIPinchGestureRecognizer) {
        if self.plotCount < self.minCandleCount {
            return
        }
        super.doPinchAction(sender)
    }
    
    /// 绘制图表分区上的系列点
    ///
    /// - Parameter serie:
    /// - Returns:
    override func drawSerie(_ serie: KSSeries) -> KSShapeLayer {
        if !serie.hidden {
            //循环画出每个模型的线
            for model in serie.chartModels {
                let serieLayer = model.drawSerie(self.rangeFrom, endIndex: self.rangeTo)
                serie.seriesLayer.addSublayer(serieLayer)
            }
        }
        return serie.seriesLayer
    }
    
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
        
        let visiableSections = self.sections.filter { !$0.hidden }
        guard let lastSection = visiableSections.last else {
            return
        }
        
        let showXAxisSection                     = self.getSecionWhichShowXAxis()
        self.selectedPoint                       = point
        
        //每个点的宽度
        let plotWidth                            = self.latticeWidth(section: section!)
        var yVal: CGFloat                        = 0//获取y轴坐标的实际值
        
        let isLeft                               = point.x < (self.frame.width / 2)
        let horizontalValueWidth: CGFloat        = 60
        let offsetX: CGFloat                     = 5
        for i in self.rangeFrom...self.rangeTo - 1 {
            //每个点的宽度 * index + 内视图左边偏移 + 自身左边偏移
            let ixs = plotWidth * CGFloat(i - self.rangeFrom) + section!.padding.left + self.padding.left
            let ixe = plotWidth * CGFloat(i - self.rangeFrom + 1) + section!.padding.left + self.padding.left

            //点在区间内
            if ixs <= point.x && point.x < ixe {
                self.selectedIndex             = i
                let item                       = self.datas[i]
                var hx                         = section!.frame.origin.x + section!.padding.left
                hx                             = hx + plotWidth * CGFloat(i - self.rangeFrom) + plotWidth / 2
                let hy                         = self.padding.top
                let hheight                    = lastSection.frame.maxY
                //显示辅助线
                self.horizontalLineView?.frame = CGRect(x: hx, y: hy, width: self.lineWidth, height: hheight - hy)

                let vx                         = section!.frame.origin.x + section!.padding.left
                var vy: CGFloat                = 0
                
                //处理水平线y的值
                switch self.selectedPosition {
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
                let hwidth                   = section!.frame.size.width - section!.padding.left - section!.padding.right
                //显示辅助线
                self.verticalLineView?.frame = CGRect(x: vx, y: vy - self.lineWidth / 2, width: hwidth, height: self.lineWidth)

                //显示y轴辅助内容
                //控制y轴的label在左还是右显示
                var yAxisStartX: CGFloat     = 0
                
                self.selectedYAxisLabel?.text  = item.close//String(format: format, yVal)//显示收盘价
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
                
                let dateFormat                = self.delegate?.kLineChart?(chart: self, labelOnXAxisForIndex: i) ?? "MM-dd HH:mm"
                let time                      = Date.ks_getTimeByStamp(item.time, format: dateFormat)//显示时间
                let size                      = time.ks_sizeWithConstrained(self.labelFont)
                self.selectedXAxisLabel?.text = time

                //判断x是否超过左右边界
                let labelWidth                = size.width  + 6
                var x                         = hx - (labelWidth) / 2

                if x < section!.frame.origin.x {
                    x = section!.frame.origin.x
                } else if x + labelWidth > section!.frame.origin.x + section!.frame.size.width {
                    x = section!.frame.origin.x + section!.frame.size.width - labelWidth
                }
                
                self.selectedXAxisLabel?.frame = CGRect(x: x, y: showXAxisSection.frame.maxY, width: size.width  + 6, height: self.labelSize.height)
                
                //给用户进行最后的自定义
                self.delegate?.kLineChart?(chart: self, viewOfYAxis: self.selectedXAxisLabel!, viewOfXAxis: self.selectedYAxisLabel!)
                
                self.showSelection = true
                if self.isCrosshair {
                    self.sightView?.center     = CGPoint(x: hx, y: vy)
                }
                self.bringSubviewToFront(self.verticalLineView!)
                self.bringSubviewToFront(self.horizontalLineView!)
                self.bringSubviewToFront(self.selectedXAxisLabel!)
                self.bringSubviewToFront(self.selectedYAxisLabel!)
                if self.isCrosshair {
                    self.bringSubviewToFront(self.sightView!)
                }

                //设置选中点
                self.setSelectedByIndex(i)
                self.selectedYAxisLabel?.isHidden = false
                break
            }
        }
    }
    
    private func hideCross() {
        self.showSelection = false
        self.delegate?.kLineChart?(chart: self, displayCross: false)
    }

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
                
                //绘制X轴坐标系，先绘制辅助线，记录标签位置
                //返回出来，最后才在需要显示的分区上绘制
                xAxisToDraw = self.drawXAxis(section)//[绘制最底部时间]

                //绘制图表的点线
                self.drawChart(section)//[--- 绘制每个区域主视图(绘制K线/均价曲线/成交量/指数指标) ---]

                //把标题添加到主绘图层上
                self.drawLayer.addSublayer(section.titleLayer)//[绘制最顶部价格/指标值等数据]
                
                //绘制顶部指标
                if self.showSelection == false {
                    if self.datas.count > 0 {
                        self.selectedIndex = self.datas.count - 1
                    }
                }
                section.drawCustomTitle(self.selectedIndex)
            }
            
            let showXAxisSection = self.getSecionWhichShowXAxis()
            //显示在分区下面绘制X轴坐标[底部时间]
            self.drawXAxisLabel(showXAxisSection, xAxisToDraw: xAxisToDraw)
        }
    }
}
