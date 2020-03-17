//
//  ZeroShare
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
enum KSUltimateValueStyle {
    case none
    case arrow(UIColor)
    case circle(UIColor, Bool)
    case tag(UIColor)
    //case line(UIColor)
}

// MARK: - 图表样式配置类
class KSKLineChartStyle {
    
    /// 分区样式配置
    var sections: [KSSection]                  = [KSSection]()
    /// 支持的指标
    var chartTais: [String: KSIndexAlgorithm]!
    /// 背景颜色
    var backgroundColor: UIColor               = UIColor.white

    /// 显示边线上左下有
    var borderWidth: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (0.5, 0.5, 0.5, 0.5)

    //边距 UIEdgeInsets(top: 32, left: 8, bottom: 4, right: 0)  top<32顶部开盘/最高价等信息显示会有问题！
    var padding: UIEdgeInsets!

    //字体大小
    var labelFont: UIFont!

    //线条颜色
    var lineColor: UIColor         = UIColor.clear
    
    //十字线颜色
    var crosshairColor: UIColor    = UIColor.white

    //文字颜色
    var textColor: UIColor         = UIColor.clear

    //选中点的显示的框背景颜色
    var selectedBGColor: UIColor   = UIColor.clear

    //选中点的显示的文字颜色
    var selectedTextColor: UIColor = UIColor.clear

    //显示y的位置，默认右边
    var showYAxisLabel             = KSYAxisShowPosition.right

    /// 是否把y坐标内嵌到图表仲
    var isInnerYAxis: Bool         = false

    //是否可缩放
    var enablePinch: Bool          = true
    //是否可滑动
    var enablePan: Bool            = true
    //是否可点选
    var enableTap: Bool            = true

    /// 是否显示选中的内容
    var showSelection: Bool        = true
    
    /// 是否显示准星
    var isCrosshair:Bool          = true
    
    /// 把X坐标内容显示到哪个索引分区上，默认为-1，表示最后一个，如果用户设置溢出的数值，也以最后一个
    var showXAxisOnSection: Int    = -1

    /// 是否显示X轴标签
    var showXAxisLabel: Bool       = true

    /// 是否显示所有内容
    var isShowAll: Bool            = false

    /// 买方深度图层颜色
    var bidColor: (stroke: UIColor, fill: UIColor, lineWidth: CGFloat) = (.white, .white, 1)

    /// 卖方深度图层颜色
    var askColor: (stroke: UIColor, fill: UIColor, lineWidth: CGFloat) = (.white, .white, 1)

    /// 买单居右
    var bidChartOnDirection:KSDepthChartOnDirection = .right
}
