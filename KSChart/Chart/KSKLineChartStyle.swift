//
//  KSKLineChartStyle.swift
//  KSChart
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

/// 最大最小值显示风格
///
/// - none: 不显示
/// - arrow: 箭头风格
/// - circle: 空心圆风格
/// - tag: 标签风格
public enum KSUltimateValueStyle {
    case none
    case arrow(UIColor)
    case circle(UIColor, Bool)
    case tag(UIColor)
    case line(UIColor)
}

// MARK: - 图表样式配置类
public class KSKLineChartStyle: NSObject {
    
    /// 分区样式配置
    public var sections: [KSSection]    = [KSSection]()
    
    /// 支持的指标
    public var chartTais: [String: KSIndexAlgorithm]!
    
    /// 背景颜色
    public var backgroundColor: UIColor = KS_Chart_Color_White

    /// 显示边线上左下有
    public var borderWidth: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (0.5, 0.5, 0.5, 0.5)

    /// 边距 
    public var padding: UIEdgeInsets!

    /// 字体大小
    public var labelFont: UIFont!

    /// 线条颜色
    public var lineColor: UIColor         = KS_Chart_Color_White
    
    /// 十字线颜色
    public var crosshairColor: UIColor    = KS_Chart_Color_White

    /// 文字颜色
    public var textColor: UIColor         = KS_Chart_Color_White

    /// 选中点的显示的框背景颜色
    public var selectedBGColor: UIColor   = KS_Chart_Color_White

    /// 选中点的显示的文字颜色
    public var selectedTextColor: UIColor = KS_Chart_Color_White

    /// 显示y的位置，默认右边
    public var showYAxisLabel             = KSYAxisShowPosition.right

    /// 是否把y坐标内嵌到图表仲
    public var isInnerYAxis: Bool         = false

    /// 是否可缩放
    public var enablePinch: Bool          = true
    
    /// 是否可滑动
    public var enablePan: Bool            = true
    
    /// 是否可点选
    public var enableTap: Bool            = true

    /// 是否显示选中的内容
    public var showSelection: Bool        = true
    
    /// 把X坐标内容显示到哪个索引分区上，默认为-1，表示最后一个，如果用户设置溢出的数值，也以最后一个
    public var showXAxisOnSection: Int    = -1

    /// 是否显示X轴标签
    public var showXAxisLabel: Bool       = true

    /// 是否显示所有内容
    public var isShowAll: Bool            = false
    
    public var yAxisLabelWidth: CGFloat   = 64
}
