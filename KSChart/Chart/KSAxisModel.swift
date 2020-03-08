//
//  ZeroShare
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

/// Y轴显示的位置
///
/// - left: 左边
/// - right: 右边
/// - none: 不显示
enum KSYAxisShowPosition {
    case left, right, none
}

/// 坐标轴辅助线样式风格
///
/// - none: 不显示
/// - dash: 虚线
/// - solid: 实线
enum KSAxisReferenceStyle {
    case none
    case dash(color: UIColor, pattern: [NSNumber])
    case solid(color: UIColor)
}

/// Y轴数据模型
struct KSYAxis {
    
    var max: CGFloat       = 0//Y轴的最大值
    var min: CGFloat       = 0//Y轴的最小值
    var ext: CGFloat       = 0//上下边界溢出值的比例
    var baseValue: CGFloat = 0//固定的基值
    var tickInterval: Int  = 4//间断显示个数
    var pos: Int           = 0
    var decimal: Int       = 2//约束小数位
    var isUsed             = false

    /// 辅助线样式
    var referenceStyle: KSAxisReferenceStyle = .dash(color: UIColor(white: 0.2, alpha: 1), pattern: [5])
    
}

/// X轴数据模型
struct KSXAxis {
    var tickInterval: Int = 6//间断显示个数
    var referenceStyle: KSAxisReferenceStyle = .none//辅助线样式
}
