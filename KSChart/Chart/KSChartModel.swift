//
//  ZeroShare
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

/// 该数据的走势方向[当天]
///
/// - up: 升
/// - down: 跌
/// - equal: 相等
enum KSChartItemTrend {
    case up
    case down
    case equal
}

/// 是否高开[相较上一天]
///
/// - up: 升
/// - down: 跌
/// - equal: 相等
enum KSChartOpenType {
    case up
    case down
    case equal
}

/// 曲线类型
///
/// - normal: 普通
/// - timeChart: 渐变分时图
enum KSGraphType: Int {
    case normal,timeChart
}

/// 数据元素
class KSChartItem: NSObject {
    @objc var time: Int           = 0
    var openPrice: CGFloat        = 0
    var closePrice: CGFloat       = 0
    var lowPrice: CGFloat         = 0
    var highPrice: CGFloat        = 0
    var vol: CGFloat              = 0
    var value: CGFloat?
    var extVal: [String: CGFloat] = [String: CGFloat]()//扩展值，用来记录各种技术指标
    var trend: KSChartItemTrend {
        //收盘价 = 开盘价
        if closePrice == openPrice {
            return .equal
            
        }else{
            //收盘价比开盘低
            if closePrice < openPrice {
                return .down
            } else {
                //收盘价比开盘高
                return .up
            }
        }
    }
    
    /// 以下为扩展属性
    var isUp:Bool               = false
    var yesterPrice: CGFloat    = 1
    
    @objc var low: String = "" {
        didSet {
            lowPrice = low.ks_floatValue()
        }
    }
    @objc var high:String = "" {
        didSet {
            highPrice = high.ks_floatValue()
        }
    }
    @objc var volume:String = "" {
        didSet {
            vol = volume.ks_floatValue()
        }
    }
    
    var volumeDisplay: String {
        get {
            return volume.ks_volume()
        }
    }
    
    @objc var open:String = "" {
        didSet {
            openPrice = open.ks_floatValue()
        }
    }
    @objc var close:String = "" {
        didSet {
            closePrice    = close.ks_floatValue()
            isUp          = closePrice > openPrice
        }
    }
    var priceChange: String {
        get {
            return String.init(format: "%.2f", ((closePrice - yesterPrice)/yesterPrice))
        }
    }
    var changePercent: String {
        get {
            return String.init(format: "%.2f%%", ((closePrice - yesterPrice)/yesterPrice*100))
        }
    }
    
    ///技术指标属性---RSI
    //单个指标[MARK: - RSI 计算单个指标]
    var up_avg: CGFloat     = 0
    var dn_avg: CGFloat     = 0

    //多个指标:[MARK: - RSI 计算全部指标]
    var up_avg_6: CGFloat   = 0
    var up_avg_12: CGFloat  = 0
    var up_avg_24: CGFloat  = 0
    var dn_avg_6: CGFloat   = 0
    var dn_avg_12: CGFloat  = 0
    var dn_avg_24: CGFloat  = 0
    var rsi6: CGFloat       = 0
    var rsi12: CGFloat      = 0
    var rsi24: CGFloat      = 0

    ///技术指标属性---BOLL
    //var ma20: CGFloat     = 0
    var boll_ma: CGFloat    = 0
    var boll_up: CGFloat    = 0
    var boll_low: CGFloat   = 0

    ///技术指标属性---MACD
    var dif: CGFloat        = 0.0
    var ema_small: CGFloat  = 0.0
    var ema_big: CGFloat    = 0.0
    var ema_middle: CGFloat = 0.0//单独计算EMA
    var dea: CGFloat        = 0.0
    var macd: CGFloat       = 0.0

    ///技术指标属性---KDJ
    var k: CGFloat          = 0.0
    var d: CGFloat          = 0.0
    var j: CGFloat          = 0.0
    var rsv: CGFloat        = 0.0

    ///技术指标属性---MA
    var ma_small: CGFloat   = 0.0
    var ma_middle: CGFloat  = 0.0
    var ma_big: CGFloat     = 0.0

    ///技术指标属性---AVG
    var avg_price: CGFloat = 0.0
}

/// 定义图表数据模型
class KSChartModel {
    
    /// MARK: - 成员变量
    //升的颜色
    var upStyle: (color: UIColor, isSolid: Bool)   = (.green, true)
    //跌的颜色
    var downStyle: (color: UIColor, isSolid: Bool) = (.red, true)
    var titleColor                                 = UIColor.white//标题文本的颜色
    var datas: [KSChartItem]                       = [KSChartItem]()//数据值
    var decimal: Int                               = 2//小数位的长度
    var showMaxVal: Bool                           = false//是否显示最大值
    var showMinVal: Bool                           = false//是否显示最小值
    var title: String                              = ""//标题
    var useTitleColor                              = true
    var key: String                                = ""//key的名字
    var ultimateValueStyle: KSUltimateValueStyle   = .none// 最大最小值显示样式
    var lineWidth: CGFloat                         = 0.6//线段宽度
    var plotPaddingExt: CGFloat                    = 0.165//点与点之间间断所占点宽的比例
    var minCandleCount: Int                        = 30//最小蜡烛图数量
    var fixedWidth: CGFloat                        = 10//小于最小蜡烛图数量，蜡烛的宽度
    weak var section: KSSection!
    
    convenience init(upStyle: (color: UIColor, isSolid: Bool),
                     downStyle: (color: UIColor, isSolid: Bool),
                     title: String = "",
                     titleColor: UIColor,
                     datas: [KSChartItem] = [KSChartItem](),
                     decimal: Int = 2,
                     plotPaddingExt: CGFloat = 0.165) {
        
        self.init()
        self.upStyle        = upStyle
        self.downStyle      = downStyle
        self.titleColor     = titleColor
        self.title          = title
        self.datas          = datas
        self.decimal        = decimal
        self.plotPaddingExt = plotPaddingExt
    }
    
    /**
     画点线【子类重写】
     
     - parameter startIndex:     起始索引
     - parameter endIndex:       结束索引
     - parameter plotPaddingExt: 点与点之间间断所占点宽的比例
     */
    func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        return CAShapeLayer()
    }
}

/// 线点样式模型
class KSLineModel: KSChartModel {
    
    /// 曲线类型
    var graphType: KSGraphType = .normal
    /// 渐变颜色
    var gradientColors: [CGColor]?
    /// 阴影偏移
    var shadowOffset: CGSize   = CGSize.init(width: 0, height: 2)
    /// 不透明度
    var shadowOpacity: Float = 0.5;

    /// 画点线（均线/MACD/KDJ/RSI）
    ///
    /// - Parameters:
    ///   - startIndex: 起始索引
    ///   - endIndex: 结束索引
    /// - Returns: 点与点之间间断所占点宽的比例
    override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        if self.graphType == .timeChart {
            return self.drawTimeChartSerie(startIndex, endIndex: endIndex)
        }
        
        let serieLayer         = CAShapeLayer()
        let modelLayer         = CAShapeLayer()
        modelLayer.strokeColor = self.upStyle.color.cgColor
        modelLayer.fillColor   = UIColor.clear.cgColor
        modelLayer.lineWidth   = self.lineWidth
        modelLayer.lineCap     = .round
        modelLayer.lineJoin    = .bevel

        //每个点的宽度
        let plotWidth          = self.latticeWidth(startIndex, endIndex: endIndex)//(self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)

        //使用bezierPath画线段
        let linePath           = UIBezierPath()

        var maxValue: CGFloat  = 0//最大值的项
        var maxPoint: CGPoint?//最大值所在坐标
        var minValue: CGFloat  = CGFloat.greatestFiniteMagnitude//最小值的项
        var minPoint: CGPoint?//最小值所在坐标

        var isStartDraw        = false//是否开始绘制
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            //开始的点 let value: CGFloat
            guard let value = self[i].value else {
                continue //无法计算的值不绘画
            }
            
            //开始X （i - startIndex 代表起始位置从0开始）
            let ix = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            //结束X
            //let iNx = self.section.frame.origin.x + self.section.padding.left + CGFloat(i + 1 - startIndex) * plotWidth
            
            //把具体的数值转为坐标系的y值
            let iys = self.section.getLocalY(value)
            //let iye = self.section.getLocalY(valueNext!)
            let point = CGPoint(x: ix + plotWidth / 2, y: iys)
            //第一个点移动路径起始
            if !isStartDraw {
                //1开始绘制
                linePath.move(to: point)
                isStartDraw = true
            } else {
                //2追加绘制
                linePath.addLine(to: point)
            }
            
            //记录最大值信息
            if value > maxValue {
                maxValue = value
                maxPoint = point
            }
            
            //记录最小值信息
            if value < minValue {
                minValue = value
                minPoint = point
            }
        }
        
        modelLayer.path = linePath.cgPath
        
        serieLayer.addSublayer(modelLayer)
        
        //显示最大最小值
        if self.showMaxVal && maxValue != 0 {
            let highPrice = maxValue.ks_toString(maximum: section.decimal)
            //绘制最大值
            let maxLayer = self.drawGuideValue(value: highPrice, section: section, point: maxPoint!, trend: KSChartItemTrend.up)
            serieLayer.addSublayer(maxLayer)
        }
        
        //显示最大最小值
        if self.showMinVal && minValue != CGFloat.greatestFiniteMagnitude {
            let lowPrice = minValue.ks_toString(maximum: section.decimal)
            //绘制最小值
            let minLayer = self.drawGuideValue(value: lowPrice, section: section, point: minPoint!, trend: KSChartItemTrend.down)
            serieLayer.addSublayer(minLayer)
        }
        return serieLayer
    }
}

/// 蜡烛样式模型
class KSCandleModel: KSChartModel {
    //是否绘制阴影
    var drawShadow = true
    
    /// 绘制蜡烛图
    ///
    /// - Parameters:
    ///   - startIndex: 起始索引
    ///   - endIndex: 结束索引
    /// - Returns: 点与点之间间断所占点宽的比例
    override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        
        let serieLayer        = CAShapeLayer()
        let modelLayer        = CAShapeLayer()

        //每个点的间隔宽度  蜡烛宽度 =（宽度 - 左边间隔 - 右边间隔）/（结束点 - 开始点）
        let plotWidth         = self.latticeWidth(startIndex, endIndex: endIndex)//(self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding       = plotWidth * self.plotPaddingExt
        plotPadding           = plotPadding < 0.25 ? 0.25 : plotPadding

        var maxValue: CGFloat = 0//最大值的项
        var maxPoint: CGPoint?//最大值所在坐标
        var minValue: CGFloat = CGFloat.greatestFiniteMagnitude//最小值的项
        var minPoint: CGPoint?//最小值所在坐标
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            if self.key != KSSeriesKey.candle {
                //不是蜡烛柱类型，要读取具体的数值才绘制
                if self[i].value == nil {//读取的值
                    continue//无法计算的值不绘画
                }
            }
            
            var isSolid          = true//是否是实体
            let candleLayer      = CAShapeLayer()
            var candlePath: UIBezierPath?
            let shadowLayer      = CAShapeLayer()
            let shadowPath       = UIBezierPath()
            shadowPath.lineWidth = 0

            let item             = datas[i]
            //开始X: 视图X + 左边间距 + ((i - 开始index) * 蜡烛的宽)
            let ix               = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth
            //结束X
            let iNx              = self.section.frame.origin.x + self.section.padding.left + CGFloat(i + 1 - startIndex) * plotWidth

            //把具体的数值转为坐标系的y值
            let iyo              = self.section.getLocalY(item.openPrice)//开盘
            let iyc              = self.section.getLocalY(item.closePrice)//收盘
            let iyh              = self.section.getLocalY(item.highPrice)//最高
            let iyl              = self.section.getLocalY(item.lowPrice)//最低
            //如果最高价 > 收盘价 || 最高价 > 开盘价
            if iyh > iyc || iyh > iyo {
                NSLog("highPrice = \(item.highPrice), closePrice = \(item.closePrice), openPrice = \(item.openPrice)")
            }
            
            switch item.trend {
            case .equal:
                //开盘收盘一样，则显示横线
                shadowLayer.strokeColor = self.upStyle.color.cgColor
                isSolid                 = true
            case .up:
                //收盘价比开盘高，则显示涨的颜色
                shadowLayer.strokeColor = self.upStyle.color.cgColor
                candleLayer.strokeColor = self.upStyle.color.cgColor
                candleLayer.fillColor   = self.upStyle.color.cgColor
                isSolid                 = self.upStyle.isSolid
            case .down:
                //收盘价比开盘低，则显示跌的颜色
                shadowLayer.strokeColor = self.downStyle.color.cgColor
                candleLayer.strokeColor = self.downStyle.color.cgColor
                candleLayer.fillColor   = self.downStyle.color.cgColor
                isSolid                 = self.downStyle.isSolid
            }
            
            //1.先画最高和最低价格的线
            if self.drawShadow {
                //最高和最低的竖线“|”
                shadowPath.move(to: CGPoint(x: ix + plotWidth / 2, y: iyh))
                shadowPath.addLine(to: CGPoint(x: ix + plotWidth / 2, y: iyl))
            }
            
            //2.画蜡烛柱的矩形，空心的刚好覆盖上面的线
            switch item.trend {
            case .equal:
                //开盘收盘一样，则显示横线
                shadowPath.move(to: CGPoint(x: ix + plotPadding, y: iyo))
                shadowPath.addLine(to: CGPoint(x: iNx - plotPadding, y: iyo))
            case .up:
                //收盘价比开盘高，则从收盘的Y值向下画矩形
                candlePath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyc, width: plotWidth - 2 * plotPadding, height: iyo - iyc))
            case .down:
                //收盘价比开盘低，则从开盘的Y值向下画矩形
                candlePath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyo, width: plotWidth - 2 *  plotPadding, height: iyc - iyo))
            }
            
            shadowLayer.path = shadowPath.cgPath
            modelLayer.addSublayer(shadowLayer)
            
            if candlePath != nil {
                //如果为自定义为空心，需要把矩形缩小lineWidth一圈。
                if isSolid {
                    candleLayer.lineWidth = self.lineWidth
                } else {
                    candleLayer.fillColor = UIColor.clear.cgColor
                    candleLayer.lineWidth = self.lineWidth
                }
                
                candleLayer.path = candlePath!.cgPath
                modelLayer.addSublayer(candleLayer)
            }

            //记录最大值信息
            if item.highPrice > maxValue {
                maxValue = item.highPrice
                maxPoint = CGPoint(x: ix + plotWidth / 2, y: iyh)
            }
            
            //记录最小值信息
            if item.lowPrice < minValue {
                minValue = item.lowPrice
                minPoint = CGPoint(x: ix + plotWidth / 2, y: iyl)
            }
            
        }
        
        serieLayer.addSublayer(modelLayer)
        
        //绘制最大值
        if self.showMaxVal && maxValue != 0 {
            let highPrice = maxValue.ks_toString(maximum: section.decimal)
            let maxLayer  = self.drawGuideValue(value: highPrice, section: section, point: maxPoint!, trend: KSChartItemTrend.up)
            serieLayer.addSublayer(maxLayer)
        }
        
        //绘制最小值
        if self.showMinVal && minValue != CGFloat.greatestFiniteMagnitude {
            let lowPrice = minValue.ks_toString(maximum: section.decimal)
            let minLayer = self.drawGuideValue(value: lowPrice, section: section, point: minPoint!, trend: KSChartItemTrend.down)
            serieLayer.addSublayer(minLayer)
        }
        
        return serieLayer
    }
    
}

/// 交易量样式模型
class KSColumnModel: KSChartModel {
    
    /// 绘制成交量
    ///
    /// - Parameters:
    ///   - startIndex: 起始索引
    ///   - endIndex: 结束索引
    /// - Returns: 点与点之间间断所占点宽的比例
    override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        
        let serieLayer  = CAShapeLayer()
        let modelLayer  = CAShapeLayer()

        //每个点的间隔宽度
        let plotWidth   = self.latticeWidth(startIndex, endIndex: endIndex)//(self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding = plotWidth * self.plotPaddingExt
        plotPadding     = plotPadding < 0.25 ? 0.25 : plotPadding

        let iybase      = self.section.getLocalY(section.yAxis.baseValue)

        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            if self.key != KSSeriesKey.volume {
                //不是蜡烛柱类型，要读取具体的数值才绘制
                if self[i].value == nil {//读取的值
                    continue//无法计算的值不绘画
                }
            }
            
            var isSolid     = true
            let columnLayer = CAShapeLayer()

            let item        = datas[i]
            //开始X
            let ix          = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth

            //把具体的数值转为坐标系的y值
            let iyv         = self.section.getLocalY(item.vol)

            //收盘价比开盘低，则显示跌的颜色
            switch item.trend {
            case .up, .equal:
                //收盘价比开盘高，则显示涨的颜色
                columnLayer.strokeColor = self.upStyle.color.cgColor
                columnLayer.fillColor   = self.upStyle.color.cgColor
                isSolid                 = self.upStyle.isSolid
            case .down:
                columnLayer.strokeColor = self.downStyle.color.cgColor
                columnLayer.fillColor   = self.downStyle.color.cgColor
                isSolid                 = self.downStyle.isSolid
            }
            
            //画交易量的矩形
            let columnPath   = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyv, width: plotWidth - 2 * plotPadding, height: iybase - iyv))
            columnLayer.path = columnPath.cgPath

            if isSolid {
                columnLayer.lineWidth = self.lineWidth//不设置为0会受到抗锯齿处理导致变大
            } else {
                columnLayer.fillColor = UIColor.clear.cgColor
                columnLayer.lineWidth = self.lineWidth
            }
            modelLayer.addSublayer(columnLayer)
        }
        serieLayer.addSublayer(modelLayer)
        return serieLayer
    }
}

/// MACD模型
class KSBarModel: KSChartModel {
    
    /// 绘制MACD指标附图
    ///
    /// - Parameters:
    ///   - startIndex: 起始索引
    ///   - endIndex: 结束索引
    /// - Returns: 点与点之间间断所占点宽的比例
    override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {
        
        let serieLayer  = CAShapeLayer()
        let modelLayer  = CAShapeLayer()

        //每个点的间隔宽度
        let plotWidth   = self.latticeWidth(startIndex, endIndex: endIndex)//(self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding = plotWidth * self.plotPaddingExt
        plotPadding     = plotPadding < 0.25 ? 0.25 : plotPadding

        let iybase      = self.section.getLocalY(section.yAxis.baseValue)

        //let context = UIGraphicsGetCurrentContext()
        //context?.setShouldAntialias(false)
        //context?.setLineWidth(1)
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            //            let value = self[i].value
            //
            //            if value == nil{
            //                continue  //无法计算的值不绘画
            //            }
            var isSolid = true
            let value = self[i].value//读取的值
            if value == nil {
                continue//无法计算的值不绘画
            }
            
            let barLayer = CAShapeLayer()

            //开始X
            let ix       = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth

            //把具体的数值转为坐标系的y值
            let iyv      = self.section.getLocalY(value!)

            //如果值是正数
            if value! > 0 {
                //收盘价比开盘高，则显示涨的颜色
                barLayer.strokeColor = self.upStyle.color.cgColor
                barLayer.fillColor   = self.upStyle.color.cgColor
            } else {
                barLayer.strokeColor = self.downStyle.color.cgColor
                barLayer.fillColor   = self.downStyle.color.cgColor
            }
            
            if i < endIndex - 1, let newValue = self[i + 1].value {
                if newValue >= value! {
                    isSolid = self.upStyle.isSolid
                } else {
                    isSolid = self.downStyle.isSolid
                }
                
            }
            
            if isSolid {
                barLayer.lineWidth = self.lineWidth //不设置为0会受到抗锯齿处理导致变大
            } else {
                barLayer.fillColor = section.backgroundColor.cgColor
                barLayer.lineWidth = self.lineWidth
            }
            
            //画交易量的矩形
            let barPath = UIBezierPath(rect: CGRect(x: ix + plotPadding, y: iyv, width: plotWidth - 2 * plotPadding, height: iybase - iyv))
            barLayer.path = barPath.cgPath
            modelLayer.addSublayer(barLayer)
        }
        serieLayer.addSublayer(modelLayer)
        return serieLayer
    }
    
}

/// 圆点样式模型
class KSRoundModel: KSChartModel {
    
    /// SAR指标
    ///
    /// - Parameters:
    ///   - startIndex: 起始索引
    ///   - endIndex: 结束索引
    /// - Returns: 点与点之间间断所占点宽的比例
    override func drawSerie(_ startIndex: Int, endIndex: Int) -> CAShapeLayer {

        let serieLayer         = CAShapeLayer()
        let modelLayer         = CAShapeLayer()
        modelLayer.strokeColor = self.upStyle.color.cgColor
        modelLayer.fillColor   = UIColor.clear.cgColor
        modelLayer.lineWidth   = self.lineWidth
        modelLayer.lineCap     = .round
        modelLayer.lineJoin    = .bevel

        //每个点的间隔宽度
        let plotWidth          = self.latticeWidth(startIndex, endIndex: endIndex)//(self.section.frame.size.width - self.section.padding.left - self.section.padding.right) / CGFloat(endIndex - startIndex)
        var plotPadding        = plotWidth * self.plotPaddingExt
        plotPadding            = plotPadding < 0.25 ? 0.25 : plotPadding

        var maxValue: CGFloat  = 0//最大值的项
        var maxPoint: CGPoint?//最大值所在坐标
        var minValue: CGFloat  = CGFloat.greatestFiniteMagnitude//最小值的项
        var minPoint: CGPoint?//最小值所在坐标
        
        //循环起始到终结
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            //开始的点
            guard let value = self[i].value else {
                continue //无法计算的值不绘画
            }
            
            let item             = datas[i]

            //开始X
            let ix               = self.section.frame.origin.x + self.section.padding.left + CGFloat(i - startIndex) * plotWidth

            //把具体的数值转为坐标系的y值
            let iys              = self.section.getLocalY(value)

            let roundLayer       = CAShapeLayer()

            let roundPoint       = CGPoint(x: ix + plotPadding, y: iys)
            let roundSize        = CGSize(width: plotWidth - 2 * plotPadding, height: plotWidth - 2 * plotPadding)
            let roundPath        = UIBezierPath(ovalIn: CGRect(origin: roundPoint, size: roundSize))

            roundLayer.lineWidth = self.lineWidth
            roundLayer.path      = roundPath.cgPath

            //收盘价大于指导价
            var fillColor: (color: UIColor, isSolid: Bool)
            if item.closePrice > value {
                fillColor = self.upStyle
            } else {
                fillColor = self.downStyle
            }
            
            roundLayer.strokeColor = fillColor.color.cgColor
            roundLayer.fillColor = fillColor.color.cgColor
            
            //设置为空心
            if !fillColor.isSolid {
                roundLayer.fillColor = section.backgroundColor.cgColor
            }
            
            modelLayer.addSublayer(roundLayer)
            
            //记录最大值信息
            if value > maxValue {
                maxValue = value
                maxPoint = roundPoint
            }
            
            //记录最小值信息
            if value < minValue {
                minValue = value
                minPoint = roundPoint
            }
        }
        
        serieLayer.addSublayer(modelLayer)
        
        //显示最大最小值
        if self.showMaxVal && maxValue != 0 {
            let highPrice = maxValue.ks_toString(maximum: section.decimal)
            let maxLayer = self.drawGuideValue(value: highPrice, section: section, point: maxPoint!, trend: KSChartItemTrend.up)
            
            serieLayer.addSublayer(maxLayer)
        }
        
        //显示最大最小值
        if self.showMinVal && minValue != CGFloat.greatestFiniteMagnitude {
            let lowPrice = minValue.ks_toString(maximum: section.decimal)
            let minLayer = self.drawGuideValue(value: lowPrice, section: section, point: minPoint!, trend: KSChartItemTrend.down)
            
            serieLayer.addSublayer(minLayer)
        }
        
        return serieLayer
    }
}

// MARK: - 扩展公共方法
extension KSChartModel {
    
    /// 绘画最大值
    ///
    /// - Parameters:
    ///   - value:
    ///   - section:
    ///   - point:
    ///   - trend:
    /// - Returns: 
    func drawGuideValue(value: String, section: KSSection, point: CGPoint, trend: KSChartItemTrend) -> CAShapeLayer {
        
        let guideValueLayer              = CAShapeLayer()

        let fontSize                     = value.ks_sizeWithConstrained(section.labelFont)
        let arrowLineWidth: CGFloat      = 4
        var isUp: CGFloat                = -1
        var isLeft: CGFloat              = -1
        var tagStartY: CGFloat           = 0
        var isShowValue: Bool            = true//是否显示值，圆形样式可以不显示值，只显示圆形
        var guideValueTextColor: UIColor = UIColor.white//显示最大最小的文字颜色
        //判断绘画完整时是否超过界限
        var maxPriceStartX               = point.x + arrowLineWidth * 2
        var maxPriceStartY: CGFloat      = 0
        if maxPriceStartX + fontSize.width > section.frame.origin.x + section.frame.size.width - section.padding.right {
            //超过了最右边界，则反方向画
            isLeft = -1
            maxPriceStartX = point.x + arrowLineWidth * isLeft * 2 - fontSize.width - 2
        } else {
            isLeft = 1
        }

        var fillColor: UIColor = self.upStyle.color
        switch trend {
        case .up:
            fillColor      = self.upStyle.color
            isUp           = -1
            tagStartY      = point.y - (fontSize.height + arrowLineWidth)
            maxPriceStartY = point.y - (fontSize.height + arrowLineWidth / 2)
        case .down:
            fillColor      = self.downStyle.color
            isUp           = 1
            tagStartY      = point.y
            maxPriceStartY = point.y + arrowLineWidth / 2
        default:break
        }
        //根据样式类型绘制
        switch self.ultimateValueStyle {
        case let .arrow(color)://箭头风格
            
            let arrowPath          = UIBezierPath()
            let arrowLayer         = CAShapeLayer()
            
            guideValueTextColor    = color
            //画小箭头
            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft, y: point.y + arrowLineWidth * isUp))
            
            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp * 2))
            
            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft, y: point.y + arrowLineWidth * isUp * 2))
            
            arrowLayer.path        = arrowPath.cgPath
            arrowLayer.strokeColor = self.titleColor.cgColor
            guideValueLayer.addSublayer(arrowLayer)
            break
        case let .tag(color)://标签风格
            
            let tagLayer         = CAShapeLayer()
            let arrowLayer       = CAShapeLayer()

            guideValueTextColor  = color

            let arrowPath        = UIBezierPath()
            arrowPath.move(to: CGPoint(x: point.x, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft * 2, y: point.y + arrowLineWidth * isUp))
            arrowPath.addLine(to: CGPoint(x: point.x + arrowLineWidth * isLeft * 2, y: point.y + arrowLineWidth * isUp * 3))
            arrowPath.close()
            arrowLayer.path      = arrowPath.cgPath
            arrowLayer.fillColor = fillColor.cgColor
            guideValueLayer.addSublayer(arrowLayer)

            let tagPath          = UIBezierPath(
                roundedRect: CGRect(x: maxPriceStartX - arrowLineWidth, y: tagStartY, width: fontSize.width + arrowLineWidth * 2, height: fontSize.height + arrowLineWidth), cornerRadius: arrowLineWidth * 2)

            tagLayer.path        = tagPath.cgPath
            tagLayer.fillColor   = fillColor.cgColor
            guideValueLayer.addSublayer(tagLayer)
            break
        case let .circle(color, show)://空心圆风格

            let circleLayer          = CAShapeLayer()

            guideValueTextColor      = color
            isShowValue              = show

            let circleWidth: CGFloat = 6
            let circlePoint          = CGPoint(x: point.x - circleWidth / 2, y: point.y - circleWidth / 2)
            let circleSize           = CGSize(width: circleWidth, height: circleWidth)
            let circlePath           = UIBezierPath(ovalIn: CGRect(origin: circlePoint, size: circleSize))

            circleLayer.lineWidth    = self.lineWidth
            circleLayer.path         = circlePath.cgPath
            circleLayer.fillColor    = self.section.backgroundColor.cgColor
            circleLayer.strokeColor  = fillColor.cgColor
            guideValueLayer.addSublayer(circleLayer)
            break
            /*
        case let .line(color)://线风格
            let linePath          = UIBezierPath()
            let lineLayer         = CAShapeLayer()
            guideValueTextColor   = color

            let lineY             = point.y + arrowLineWidth * isUp * 2//point.y + arrowLineWidth * isUp - isUp * 4
            linePath.move(to: CGPoint(x: point.x + 2 * isLeft, y: lineY))
            linePath.addLine(to: CGPoint(x: point.x + arrowLineWidth * 3.5 * isLeft, y:lineY))

            lineLayer.path        = linePath.cgPath
            lineLayer.strokeColor = color.cgColor
            guideValueLayer.addSublayer(lineLayer)*/
        default:
            isShowValue = false
            break
        }
        
        if isShowValue {
            //计算画文字的位置
            let point                 = CGPoint(x: maxPriceStartX, y: maxPriceStartY)
            //let point                 = CGPoint(x: maxPriceStartX, y: mmPointY - textSize.height/2)
            //画最大值数字
            let valueText             = KSTextLayer()
            valueText.frame           = CGRect(origin: point, size: fontSize)
            valueText.string          = value
            valueText.fontSize        = section.labelFont.pointSize
            valueText.foregroundColor = guideValueTextColor.cgColor
            valueText.backgroundColor = UIColor.clear.cgColor
            valueText.contentsScale   = UIScreen.main.scale

            guideValueLayer.addSublayer(valueText)
        }
        return guideValueLayer
    }
}

// MARK: - 工厂方法
extension KSChartModel {
    
    //生成一个点线样式
    class func getLine(_ color: UIColor, title: String, key: String) -> KSLineModel {
        let model   = KSLineModel(upStyle: (color, true), downStyle: (color, true), titleColor: color)
        model.title = title
        model.key   = key
        return model
    }
    
    //生成一个蜡烛样式
    class func getCandle(upStyle: (color: UIColor, isSolid: Bool),
                         downStyle: (color: UIColor, isSolid: Bool),
                         titleColor: UIColor,
                         key: String = KSSeriesKey.candle) -> KSCandleModel {
        let model = KSCandleModel(upStyle: upStyle, downStyle: downStyle, titleColor: titleColor)
        model.key = key
        return model
    }
    
    //生成一个交易量样式
    class func getVolume(upStyle: (color: UIColor, isSolid: Bool),
                         downStyle: (color: UIColor, isSolid: Bool),
                         key: String = KSSeriesKey.volume) -> KSColumnModel {
        let model   = KSColumnModel(upStyle: upStyle, downStyle: downStyle,
                                  titleColor: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1))
        model.title = NSLocalizedString("Vol", comment: "")
        model.key   = key
        return model
    }
    
    //生成一个柱状样式
    class func getBar(upStyle: (color: UIColor, isSolid: Bool),
                      downStyle: (color: UIColor, isSolid: Bool),
                      titleColor: UIColor, title: String, key: String) -> KSBarModel {
        let model   = KSBarModel(upStyle: upStyle, downStyle: downStyle,
                               titleColor: titleColor)
        model.title = title
        model.key   = key
        return model
    }
    
    //生成一个圆点样式
    class func getRound(upStyle: (color: UIColor, isSolid: Bool),
                        downStyle: (color: UIColor, isSolid: Bool),
                        titleColor: UIColor, title: String,
                        plotPaddingExt: CGFloat,
                        key: String) -> KSRoundModel {
        let model   = KSRoundModel(upStyle: upStyle, downStyle: downStyle,
                                 titleColor: titleColor, plotPaddingExt: plotPaddingExt)
        model.title = title
        model.key   = key
        return model
    }
}

// MARK: - 扩展技术指标公式
extension KSChartModel {
    
    subscript (index: Int) -> KSChartItem {
        var value: CGFloat?
        let item   = self.datas[index]
        value      = item.extVal[self.key]
        item.value = value
        return item
    }
    
}
