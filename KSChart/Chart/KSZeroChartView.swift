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
        guard index >= self.pref.rangeFrom && index < self.pref.rangeTo else {
            return
        }
        let item                = self.datas[index]
        //回调给代理委托方法
        self.delegate?.kLineChart?(chart: self, didSelectAt: index, item: item)
    }
    
    /// 处理长按操作
    override func doLongPressAction(_ sender: UILongPressGestureRecognizer) {
        super.doLongPressAction(sender)

        if self.pref.isLongPressMoveX {
            DispatchQueue.global().async {
              for section in self.style.sections {
                  //绘制顶部技术指标,例如:BOOL:0.0251 UB:0.0252 LB:0.0250
                  section.drawCustomTitle(self.pref.selectedIndex)
              }
            }
            self.delegate?.kLineChartTapAction?(chart: self)
        }
    }
    
    /// 通过CALayer方式画图表
    override func drawLayerView() {
        //先清空图层
        self.removeLayerView()
        //初始化数据
        if self.initChart() {
            /// 待绘制的x坐标标签
            var xAxisToDraw = [(CGRect, String)]()
            for index in 0..<self.style.sections.count {
                let section     = self.style.sections[index]
                //获取各section的小数保留位数
                let decimal     = self.delegate?.kLineChart?(chart: self, decimalAt: index) ?? 2
                section.decimal = decimal
                //初始Y轴的数据
                self.initYAxis(section)
                //绘制每个区域
                xAxisToDraw     = self.drawXAxis(section)//[绘制辅助线返回底部时间Rect]
                //绘制图表的点线
                self.drawChart(section)//[--- 绘制每个区域主视图(绘制K线/均价曲线/成交量/指数指标) ---]
                //绘制顶部指标
                if self.showSelection == false {
                    if self.datas.count > 0 {
                        self.pref.selectedIndex = self.datas.count - 1
                    }
                }
                section.drawCustomTitle(self.pref.selectedIndex)
                //更新Y轴数值
                self.updateYAxisTitle(section)
            }
            /*
            self.buildSections {(section, index) in
                //获取各section的小数保留位数
                let decimal     = self.delegate?.kLineChart?(chart: self, decimalAt: index) ?? 2
                section.decimal = decimal
                //初始Y轴的数据
                self.initYAxis(section)
                //绘制每个区域
                xAxisToDraw     = self.drawXAxis(section)//[绘制辅助线返回底部时间Rect]
                //绘制图表的点线
                self.drawChart(section)//[--- 绘制每个区域主视图(绘制K线/均价曲线/成交量/指数指标) ---]
                //绘制顶部指标
                if self.showSelection == false {
                    if self.datas.count > 0 {
                        self.pref.selectedIndex = self.datas.count - 1
                    }
                }
                section.drawCustomTitle(self.pref.selectedIndex)
                //更新Y轴数值
                self.updateYAxisTitle(section)
            }*/
            
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
