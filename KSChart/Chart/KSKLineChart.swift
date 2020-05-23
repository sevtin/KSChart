//
//  KSKLineChart.swift
//  KSChart
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

/// 图表滚动到那个位置
///
/// - top: 头部
/// - end: 尾部
/// - none: 不处理
enum KSScrollPosition {
    case top, end, none
}

/// 图表选中的十字y轴显示位置
///
/// - free: 自由就在显示的点上
/// - onClosePrice: 在收盘价上
enum KSSelectedPosition {
    case free
    case onClosePrice
}

/// K线数据源代理
@objc public protocol KSKLineChartDelegate: class {
    
    /// 数据源
    /// - Parameter lineChart: self
    @objc func ksLineChartDataSource(_ lineChart: KSKLineChartView) -> [KSChartItem]

    /// 获取图表X轴的显示的内容
    /// - Parameter lineChart: self
    /// - Parameter index: index
    @objc optional func ksLineChart(_ lineChart: KSKLineChartView, xAxisTextForIndex index: Int) -> String
    
    /// 配置各个分区小数位保留数
    /// - Parameter lineChart: self
    /// - Parameter section: 分区
    @objc optional func ksLineChart(_ lineChart: KSKLineChartView, decimalAt section: Int) -> Int
    
    /// 点击图表回调
    /// - Parameter lineChart: self
    /// - Parameter index: index
    /// - Parameter item: item
    @objc optional func ksLineChart(_ lineChart: KSKLineChartView, didSelectAt index: Int, item: KSChartItem)
    
    /// 行标题
    /// - Parameter lineChart: self
    /// - Parameter section: section
    /// - Parameter titleValue: titleValue
    @objc optional func ksLineChart(_ lineChart: KSKLineChartView, rowTitleInSection section: KSSection, titleValue: CGFloat) -> String
    
    /// 切换分区用分页方式展示的线组
    /// - Parameter lineChart: self
    /// - Parameter section: section
    @objc optional func ksLineChart(_ lineChart: KSKLineChartView, didFlipSection section: KSSection)
    
    /// 十字架显示和影藏
    /// - Parameter lineChart: self
    /// - Parameter displayCross: display
    @objc optional func ksLineChart(_ lineChart: KSKLineChartView, displayCross: Bool)
    
    /// Tap回调
    /// - Parameter lineChart: self
    @objc optional func ksLineChartDidTap(_ lineChart: KSKLineChartView)
}

public struct KSChartPref {
    let kMinRange:Int                        = 16//最小缩放范围
    let kMaxRange:Int                        = 128//最大缩放范围
    let kPerInterval:Int                     = 4//缩放的每段间隔
    let kXAxisHegiht: CGFloat                = 16//默认X坐标的高度
    var minCandleCount: Int                  = 30//最小蜡烛图数量
    var fixedWidth: CGFloat                  = 10//小于最小蜡烛图数量，蜡烛的宽度
    var fixedGrid: Int                       = 2//最小格子数
    var xAxisPerInterval: Int                = 4//x轴的间断个数
    var yAxisLabelWidth: CGFloat             = 64//Y轴的宽度
    var selectedPosition: KSSelectedPosition = .onClosePrice//选中显示y值的位置
    var selectedIndex: Int                   = -1//选择单个点的索引
    var scrollToPosition: KSScrollPosition   = .none//图表刷新后开始显示位置
    var selectedPoint: CGPoint               = CGPoint.zero
    var lineWidth: CGFloat                   = 0.5
    var plotCount: Int                       = 0//所有蜡烛图的个数
    var rangeFrom: Int                       = 0//可见区域的开始索引位
    var rangeTo: Int                         = 0//可见区域的结束索引位
    var range: Int                           = 60//显示在可见区域的个数
    var decelerationStartX: CGFloat          = 0//减速开始x
    var isLongPressMoveX: Bool               = true//长按时X轴是否移动触点
}

open class KSKLineChartView: UIView {
    public weak var delegate: KSKLineChartDelegate? //代理
    
    public lazy var pref: KSChartPref    = KSChartPref()//偏好设置
    lazy var datas: [KSChartItem]        = [KSChartItem]()//数据源
    
    var upColor: UIColor                 = KS_Chart_Color_White//升的颜色
    var downColor: UIColor               = KS_Chart_Color_White//跌的颜色
    var borderColor: UIColor             = KS_Chart_Color_White
    var labelHeight: CGFloat             = 16
    
    //动力学引擎
    lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self)
    //动力的作用点
    lazy var dynamicItem                 = KSDynamicItem()
    //滚动图表时用于处理线性减速
    weak var decelerationBehavior: UIDynamicItemBehavior?
    
    /// 用于图表的图层
    lazy var drawLayer: KSShapeLayer     = KSShapeLayer()
    /// 格子图层
    lazy var gridLayer: KSGridLayer      = KSGridLayer()
    /// 顶部图层
    lazy var topLayer: KSTopLayer        = KSTopLayer()
    
    //是否可点选
    var enableTap: Bool = true {
        didSet {
            self.showSelection = self.enableTap
        }
    }
    
    /// 是否显示选中的内容
    var showSelection: Bool = false {
        didSet {
            self.topLayer.updateCross(isShow: self.showSelection)
        }
    }
    
    public var style: KSKLineChartStyle! {
        didSet {
            assert(self.style.chartTais != nil, "chartTais 不能为nil")
            self.enableTap            = self.style.enableTap
            self.showSelection        = self.style.showSelection
            self.pref.minCandleCount  = self.pref.range/2
            self.pref.yAxisLabelWidth = self.style.yAxisLabelWidth
            
            for section in self.style.sections {
                for serie in section.series {
                    for model in serie.chartModels {
                        model.minCandleCount = self.pref.minCandleCount
                        model.fixedWidth     = self.pref.fixedWidth
                    }
                }
            }
            defaultConfigure()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeKit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// 初始化UI
    func initializeKit() {
        //开启多点触控
        self.isMultipleTouchEnabled                        = true
        
        //绘画图层
        self.layer.addSublayer(self.gridLayer)
        self.layer.addSublayer(self.drawLayer)
        self.layer.addSublayer(self.topLayer)
        
        //添加手势操作
        let pan                                            = UIPanGestureRecognizer(target: self, action: #selector(doPanAction(_:)))
        pan.delegate                                       = self
        self.addGestureRecognizer(pan)
        
        //点击手势操作
        let tap                                            = UITapGestureRecognizer(target: self, action: #selector(doTapAction(_:)))
        tap.delegate                                       = self
        self.addGestureRecognizer(tap)
        
        //双指缩放操作
        let pinch                                          = UIPinchGestureRecognizer(target: self, action: #selector(doPinchAction(_:)))
        pinch.delegate                                     = self
        self.addGestureRecognizer(pinch)
        
        //长按手势操作
        let longPress                                      = UILongPressGestureRecognizer(target: self, action: #selector(doLongPressAction(_:)))
        //长按时间为0.5秒
        longPress.minimumPressDuration                     = 0.5
        self.addGestureRecognizer(longPress)
    }
    
    func defaultConfigure() {
        self.backgroundColor = self.style.backgroundColor

        //绘制层级Layer
        self.drawLevelLayer()
        
    }
    
    public func resetChartData() {
        self.pref.selectedIndex = -1
    }
    
    public func scrollPositionEnd() -> Bool {
        if self.pref.rangeTo == 0 || self.pref.plotCount < self.pref.range {
            return true
        }
        if self.pref.rangeTo >= self.pref.plotCount {
            return true
        }
        if (self.pref.rangeFrom + self.pref.range + 1) >= self.pref.plotCount {
            return true
        }
        return false
    }
    
    /// 计算技术指标
    ///
    /// - Parameter isAll: 是否计算全部指标
    private func calculatorTai(isAll: Bool = true) {
        guard let myDatas = self.delegate?.ksLineChartDataSource(self) else {
            return
        }
        self.datas          = myDatas
        self.pref.plotCount = self.datas.count
        var index: Int = 0
        if isAll == false {
            index = self.datas.count - 1
            if index < 0 {
                index = 0
            }
        }
        for section in self.style.sections {
            _ = KSCalculator.ks_calculator(algorithm: self.style.chartTais[section.tai] ?? KSIndexAlgorithm.none, index: index, datas: self.datas)
        }
    }
    
    /// 刷新k线
    ///
    /// - Parameters:
    ///   - isAll: 是否刷新全部数据
    ///   - isDraw: 是否绘制
    ///   - isChangeTai: 是否修改了技术指标
    public func refreshChart(isAll: Bool = true, isDraw: Bool = true, isChangeTai: Bool = false) {
        self.calculatorTai(isAll: isAll)
        if isDraw {
            self.pref.scrollToPosition = self.scrollPositionEnd() ? .end : .none
            if isChangeTai {
                self.drawLayerView()
            }
            else{
                if self.pref.scrollToPosition == .end {
                    self.drawLayerView()
                }
            }
        }
    }
    
    /// 通过key隐藏或显示线系列
    public func updateSerie(hidden: Bool, key: String, isMasterCandle: Bool, index: Int = 0) {
        if index >= self.style.sections.count {
            return
        }
        let section = self.style.sections[index]
        section.updateTai(_tai: key)
        
        for serie in section.series {
            serie.hidden = (serie.key == key) ? hidden : true
            if section.valueType == .master {
                if serie.key == KSSeriesKey.timeline {
                    serie.hidden = isMasterCandle ? true : false
                }
                else if serie.key == KSSeriesKey.candle {
                    serie.hidden = isMasterCandle ? false : true
                }
            }
        }
    }
    
    /// 获取点击区域所在分区位
    ///
    /// - Parameter point: 点击坐标
    /// - Returns: 返回section和索引位
    func getSectionByTouchPoint(_ point: CGPoint) -> (Int, KSSection?) {
        //self.style.sections 分区样式，Demo中3个样式，分别是k线/成交量/技术指标
        for (i, section) in self.style.sections.enumerated() {
            if section.frame.contains(point) {
                return (i, section)
            }
        }
        return (-1, nil)
    }
    
    /// 取显示X轴坐标的分区
    ///
    /// - Returns:
    func getSecionWhichShowXAxis() -> KSSection {
        //数组(Array)过滤器(filter)
        let visiableSection = self.style.sections.filter { !$0.hidden }
        var showSection: KSSection?
        for (i, section) in visiableSection.enumerated() {
            //用户自定义显示X轴的分区
            if section.index == self.style.showXAxisOnSection {
                showSection = section
            }
            //如果最后都没有找到，取最后一个做显示
            if (i == visiableSection.count - 1) && (showSection == nil) {
                showSection = section
            }
        }
        return showSection!
    }
    
    func latticeWidth(section: KSSection) -> CGFloat {
        if self.datas.count < self.pref.minCandleCount {
            return self.pref.fixedWidth
        }
        let plotWidth = (section.frame.size.width - section.padding.left - section.padding.right) / CGFloat(self.pref.rangeTo - self.pref.rangeFrom)
        return plotWidth
    }
    
    /// 设置选中的数据点，绘制十字线
    ///
    /// - Parameter point:
    func setSelectedIndexByPoint(_ point: CGPoint) {
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
        
        //每个点的宽度
        let plotWidth    = latticeWidth(section: section!)// (section!.frame.size.width - section!.padding.left - section!.padding.right) / CGFloat(self.rangeTo - self.rangeFrom)
        var ixs: CGFloat = 0
        var ixe: CGFloat = 0
        var isNext: Bool = false
        
        for i in self.pref.rangeFrom...self.pref.rangeTo - 1 {
            //每个点的宽度 * index + 内视图左边偏移 + 自身左边偏移
            ixs = plotWidth * CGFloat(i - self.pref.rangeFrom) + section!.padding.left + self.style.padding.left
            ixe = plotWidth * CGFloat(i - self.pref.rangeFrom + 1) + section!.padding.left + self.style.padding.left
            
            //点在区间内
            if ixs <= point.x && point.x < ixe {
                if self.pref.selectedIndex == i {
                    self.pref.isLongPressMoveX = false
                    return
                }
                isNext                     = true
                self.pref.isLongPressMoveX = true
                self.pref.selectedIndex    = i
                break
            }
        }
        if isNext == false {
            return
        }
        
        self.pref.selectedPoint                  = point
        let showXAxisSection                     = self.getSecionWhichShowXAxis()
        
        let yaxis                                = section!.yAxis
        let format                               = "%.".appendingFormat("%df", yaxis.decimal)
        
        var yVal: CGFloat                        = 0//获取y轴坐标的实际值
        let currentIndex: Int                    = self.pref.selectedIndex
        
        let item                                 = self.datas[currentIndex]
        var hx                                   = section!.frame.origin.x + section!.padding.left
        hx                                       = hx + plotWidth * CGFloat(currentIndex - self.pref.rangeFrom) + plotWidth / 2
        let hy                                   = self.style.padding.top
        let hheight                              = lastSection.frame.maxY
        //显示辅助线
        self.topLayer.updateVerticalLine(rect: CGRect(x: hx, y: hy, width: self.pref.lineWidth, height: hheight - hy))

        let vx                                   = section!.frame.origin.x + section!.padding.left
        var vy: CGFloat                          = 0
        
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
        
        let hwidth = section!.frame.size.width - section!.padding.left - section!.padding.right
        //显示辅助线
        self.topLayer.updateHorizontalLine(rect: CGRect(x: vx, y: vy - self.pref.lineWidth / 2, width: hwidth, height: self.pref.lineWidth))
        
        //控制y轴的label在左还是右显示
        var yAxisStartX: CGFloat = 0
        switch self.style.showYAxisLabel {
        case .left:
            yAxisStartX = section!.frame.origin.x
        case .right:
            yAxisStartX = section!.frame.maxX - self.pref.yAxisLabelWidth
        case .none:break
        }
        self.topLayer.updateYAxisLabel(rect: CGRect(x: yAxisStartX, y: vy - self.labelHeight / 2, width: self.pref.yAxisLabelWidth, height: self.labelHeight),
        text: String(format: format, yVal))
        
        let time                       = self.delegate?.ksLineChart?(self, xAxisTextForIndex: currentIndex) ?? ""
        let size                       = time.ks_sizeWithConstrained(self.style.labelFont)

        //判断x是否超过左右边界
        let labelWidth = size.width  + 6
        var x = hx - (labelWidth) / 2
        
        if x < section!.frame.origin.x {
            x = section!.frame.origin.x
        } else if x + labelWidth > section!.frame.origin.x + section!.frame.size.width {
            x = section!.frame.origin.x + section!.frame.size.width - labelWidth
        }
        
        self.topLayer.updateXAxisLabel(rect: CGRect(x: x, y: showXAxisSection.frame.maxY, width: size.width  + 6, height: self.labelHeight),
        text: time)
        self.showSelection = true
        
        //设置选中点
        self.setSelectedByIndex(currentIndex)
    }
    
    /// 设置选中的数据点,并回调
    ///
    /// - Parameter index: 选中位置
    func setSelectedByIndex(_ index: Int) {
        if index >= self.datas.count {
            return
        }
        //如果不在区间内return
        guard index >= self.pref.rangeFrom && index < self.pref.rangeTo else {
            return
        }
        let item = self.datas[index]
        //是否移动了一格
        if self.pref.isLongPressMoveX {
            for section in self.style.sections {
                if section.hidden {
                    continue
                }
                //绘制顶部技术指标,例如:BOOL:0.0251 UB:0.0252 LB:0.0250
                section.drawTitle(self.pref.selectedIndex)
            }
            //回调
            self.delegate?.ksLineChart?(self, didSelectAt: index, item: item)
        }
    }
    
    private func hideCross() {
        if self.showSelection {
            self.showSelection = false
            self.delegate?.ksLineChart?(self, displayCross: false)
        }
    }
}

// MARK: - 绘图相关方法
extension KSKLineChartView {
    
    /// 清空图表的子图层
    func removeLayerView() {
        for section in self.style.sections {
            section.removeLayerView()
            for series in section.series {
                series.removeLayerView()
            }
        }
        _ = self.drawLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.drawLayer.sublayers?.removeAll()
    }
    
    /// 通过CALayer方式画图表
    @objc func drawLayerView() {
        //先清空图层
        self.removeLayerView()
        //初始化数据
        if self.initChart() {
            /// 待绘制的x坐标标签
            var xAxisToDraw = [(CGRect, String)]()
            for index in 0..<self.style.sections.count {
                let section     = self.style.sections[index]
                //获取各section的小数保留位数
                let decimal     = self.delegate?.ksLineChart?(self, decimalAt: index) ?? 2
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
                section.drawTitle(self.pref.selectedIndex)
                //更新Y轴数值
                self.updateYAxisTitle(section)
            }
            let showXAxisSection = self.getSecionWhichShowXAxis()
            //显示在分区下面绘制X轴坐标[底部时间]
            self.topLayer.drawXAxisLabel(showXAxisSection, xAxisToDraw: xAxisToDraw, style: self.style)
            //重新显示点击选中的坐标
            if self.showSelection {
                self.setSelectedIndexByPoint(self.pref.selectedPoint)
            }
        }
    }
    
    /// 初始化图表结构 -> 是否初始化数据
    func initChart() -> Bool {
        if self.pref.plotCount > 0 {
            drawRange()
        }
        
        //重置图表刷新滚动默认不处理
        self.pref.scrollToPosition = .none
        
        //选择最后一个元素选中
        if pref.selectedIndex == -1 {
            self.pref.selectedIndex = self.pref.rangeTo - 1
        }
        return self.datas.count > 0 ? true : false
    }
    
    func drawRange() {
        //如果显示全部，显示范围为全部数据量
        if self.style.isShowAll {
            self.pref.range     = self.pref.plotCount
            self.pref.rangeFrom = 0
            self.pref.rangeTo   = self.pref.plotCount
        }
        
        //图表刷新滚动为默认时，如果第一次初始化，就默认滚动到最后显示
        if self.pref.scrollToPosition == .none {
            //如果图表尽头的索引为0，则进行初始化
            if self.pref.rangeTo == 0 || self.pref.plotCount < self.pref.rangeTo {
                self.pref.scrollToPosition = .end
            }
        }
        else if self.pref.scrollToPosition == .top {
            self.pref.rangeFrom = 0
            if self.pref.rangeFrom + self.pref.range < self.pref.plotCount {
                self.pref.rangeTo = self.pref.rangeFrom + self.pref.range//计算结束的显示的位置
            } else {
                self.pref.rangeTo = self.pref.plotCount
            }
            self.pref.selectedIndex = -1
        } else if self.pref.scrollToPosition == .end {
            self.pref.rangeTo = self.pref.plotCount               //默认是数据最后一条为尽头
            if self.pref.rangeTo - self.pref.range > 0 {          //如果尽头 - 默认显示数大于0
                self.pref.rangeFrom = self.pref.rangeTo - self.pref.range   //计算开始的显示的位置
            } else {
                self.pref.rangeFrom = 0
            }
            self.pref.selectedIndex = -1
        }
    }
    
    /// 初始化各个分区
    ///
    /// - Parameter complete: 初始化后，执行每个分区绘制
    func buildSections(_ complete:(_ section: KSSection, _ index: Int) -> Void) {
        //计算实际的显示高度和宽度
        var height      = self.frame.size.height - (self.style.padding.top + self.style.padding.bottom)
        let width       = self.frame.size.width - (self.style.padding.left + self.style.padding.right)
        
        //X轴的布局高度
        let xAxisHeight = self.pref.kXAxisHegiht
        height          = height - xAxisHeight
        
        var total       = 0
        for (index, section) in self.style.sections.enumerated() {
            section.index = index
            if !section.hidden {
                //如果使用fixHeight，ratios要设置为0
                if section.ratios > 0 {
                    total = total + section.ratios
                }
            }
        }
        
        var offsetY: CGFloat       = self.style.padding.top
        //计算每个区域的高度，并绘制
        for (index, section) in self.style.sections.enumerated() {
            
            var heightOfSection: CGFloat = 0
            let WidthOfSection = width
            if section.hidden {
                continue
            }
            //计算每个区域的高度
            //如果fixHeight大于0，有限使用fixHeight设置高度，
            if section.fixHeight > 0 {
                heightOfSection = section.fixHeight
                height          = height - heightOfSection
            } else {
                heightOfSection = height * CGFloat(section.ratios) / CGFloat(total)
            }
            /*
            //y轴的标签显示方位
            switch self.style.showYAxisLabel {
            case .left:         //左边显示
                section.padding.left  = self.style.isInnerYAxis ? section.padding.left : self.pref.yAxisLabelWidth
                section.padding.right = 0
            case .right:        //右边显示
                section.padding.left  = 0
                section.padding.right = self.style.isInnerYAxis ? section.padding.right : self.pref.yAxisLabelWidth
            case .none:         //都不显示
                section.padding.left  = 0
                section.padding.right = 0
            }*/
            
            //计算每个section的坐标
            if section.frame.origin.y != offsetY || section.frame.height != heightOfSection {
                section.frame = CGRect(x: 0 + self.style.padding.left, y: offsetY, width: WidthOfSection, height: heightOfSection)
            }
            offsetY       = offsetY + section.frame.height
            
            //如果这个分区设置为显示X轴，下一个分区的Y起始位要加上X轴高度
            if self.style.showXAxisOnSection == index {
                offsetY = offsetY + xAxisHeight
            }
            
            complete(section, index)
        }
    }
    
    /// 绘制X轴上的标签
    ///
    /// - Parameter section: 内边距
    /// - Returns: 总宽度
    func drawXAxis(_ section: KSSection) -> [(CGRect, String)] {
        
        var xAxisToDraw              = [(CGRect, String)]()
        let xAxis                    = KSShapeLayer()
        var startX: CGFloat          = section.frame.origin.x + section.padding.left
        let endX: CGFloat            = section.frame.maxX - section.padding.right
        //x轴分平均分N个间断，显示N+1个x轴坐标，按照图表的值个数，计算每个间断的个数
        let dataRange                = self.pref.rangeTo - self.pref.rangeFrom
        var xTickInterval: Int       = dataRange / self.pref.xAxisPerInterval
        if xTickInterval <= 0 {
            xTickInterval = 1
        }
        
        //绘制x轴标签
        //每个点的间隔宽度
        let perPlotWidth: CGFloat  = latticeWidth(section: section)//(secWidth - secPaddingLeft - secPaddingRight) / CGFloat(self.rangeTo - self.rangeFrom)
        if self.datas.count < self.pref.minCandleCount {
            if self.datas.count < (self.pref.minCandleCount/self.pref.fixedGrid) {
                xTickInterval = dataRange
            }
            else {
                xTickInterval = dataRange / self.pref.fixedGrid - 1
            }
        }
        
        let startY = section.frame.maxY
        var k: Int = 0
        var showXAxisReference = false
        
        //相当 for var i = self.rangeFrom; i < self.rangeTo; i = i + xTickInterval
        for i in stride(from: self.pref.rangeFrom, to: self.pref.rangeTo, by: xTickInterval) {
            
            let xLabel     = self.delegate?.ksLineChart?(self, xAxisTextForIndex: i) ?? ""
            let textSize   = xLabel.ks_sizeWithConstrained(self.style.labelFont)
            var lineX      = startX + (perPlotWidth / 2)
            var xPox       = lineX - (textSize.width / 2)
            
            //计算最左最右的x轴标签不越过边界
            if (xPox <= section.padding.left) {
                xPox = startX
            } else if (xPox + textSize.width > endX) {
                if lineX > endX {
                    lineX = 0
                }
                xPox = endX - textSize.width
            }
            let barLabelRect         = CGRect(x: xPox, y: startY, width: textSize.width, height: textSize.height)
            
            //记录待绘制的文本
            xAxisToDraw.append((barLabelRect, xLabel))
            
            //绘制辅助线
            let referencePath        = UIBezierPath()
            let referenceLayer       = KSShapeLayer()
            referenceLayer.lineWidth = self.pref.lineWidth
            
            //处理辅助线样式
            switch section.xAxis.referenceStyle {
            case let .dash(color: dashColor, pattern: pattern):
                referenceLayer.strokeColor = dashColor.cgColor
                referenceLayer.lineDashPattern = pattern
                showXAxisReference = true
            case let .solid(color: solidColor):
                referenceLayer.strokeColor = solidColor.cgColor
                showXAxisReference = true
            default:
                showXAxisReference = false
            }
            
            //需要画x轴上的辅助线
            if showXAxisReference {
                if lineX > 0 {
                    referencePath.move(to: CGPoint(x: lineX, y: section.frame.minY + section.padding.top))
                    referencePath.addLine(to: CGPoint(x: lineX, y: section.frame.maxY - section.padding.bottom))
                    referenceLayer.path = referencePath.cgPath
                    xAxis.addSublayer(referenceLayer)
                }
            }
            k      = k + xTickInterval
            startX = perPlotWidth * CGFloat(k) + section.padding.left
        }
        self.drawLayer.addSublayer(xAxis)
        return xAxisToDraw
    }
    
    /// 初始化分区上各个线的Y轴
    ///
    /// - Parameter section: 
    func initYAxis(_ section: KSSection) {
        if section.series.count > 0 {
            //建立分区每条线的坐标系
            section.buildYAxis(startIndex: self.pref.rangeFrom, endIndex: self.pref.rangeTo, datas: self.datas)
        }
    }

    /// 绘制图表上的点线
    ///
    /// - Parameter section:
    func drawChart(_ section: KSSection) {
        if section.paging {
            //如果section以分页显示，则读取当前显示的系列
            let serie       = section.series[section.selectedIndex]
            let seriesLayer = self.drawSerie(serie)
            section.sectionLayer.addSublayer(seriesLayer)
        } else {
            //不分页显示，全部系列绘制到图表上
            for serie in section.series {
                let seriesLayer = self.drawSerie(serie)
                section.sectionLayer.addSublayer(seriesLayer)
            }
        }
        self.drawLayer.addSublayer(section.sectionLayer)
    }
    
    /// 绘制图表分区上的系列点
    ///
    /// - Parameter serie:
    /// - Returns:
    @objc func drawSerie(_ serie: KSSeries) -> KSShapeLayer {
        if !serie.hidden {
            //循环画出每个模型的线
            for model in serie.chartModels {
                let serieLayer = model.drawSerie(self.pref.rangeFrom, endIndex: self.pref.rangeTo)
                serie.seriesLayer.addSublayer(serieLayer)
            }
        }
        return serie.seriesLayer
    }
}

// MARK: - 公开方法
extension KSKLineChartView {
    
    /// 刷新视图
    ///
    /// - Parameters:
    ///   - toPosition:
    ///   - resetData:
    func reloadData(toPosition: KSScrollPosition = .none, resetData: Bool = true) {
        self.pref.scrollToPosition = toPosition
        if resetData {
            self.calculatorTai(isAll: true)
        }
        self.drawLayerView()
    }
    
    /// 刷新风格
    ///
    /// - Parameter style: 新风格
    func resetStyle(style: KSKLineChartStyle) {
        self.style         = style
        self.showSelection = false
        self.reloadData()
    }
    
    /// 通过key隐藏或显示线系列
    /// inSection = -1时，全section都隐藏，否则只隐藏对应的索引的section
    /// key = "" 时，设置全部线显示或隐藏
    func setSerie(hidden: Bool, by key: String = "", inSection: Int = -1) {
        
        var hideSections = [KSSection]()
        if inSection < 0 {
            hideSections = self.style.sections
        } else {
            if inSection >= self.style.sections.count {
                return //超过界限
            }
            hideSections.append(self.style.sections[inSection])
        }
        for section in hideSections {
            for (index, serie)  in section.series.enumerated() {
                
                if key == "" {
                    if section.paging {
                        section.selectedIndex = 0
                    } else {
                        serie.hidden = hidden
                    }
                } else if serie.key == key {
                    if section.paging {
                        if hidden == false {
                            section.selectedIndex = index
                        }
                    } else {
                        serie.hidden = hidden
                    }
                    break
                }
            }
        }
    }
    
    /// 通过key隐藏或显示分区
    ///
    /// - Parameters:
    ///   - hidden:
    ///   - key:
    func setSection(hidden: Bool, byKey key: String) {
        for section in self.style.sections {
            //副图才能隐藏
            if section.key == key && section.valueType == .assistant {
                section.hidden = hidden
                break
            }
        }
    }
    
    /// 通过索引位隐藏或显示分区
    ///
    /// - Parameters:
    ///   - hidden:
    ///   - index:
    func setSection(hidden: Bool, byIndex index: Int) {
        //副图才能隐藏
        guard let section = self.style.sections[safe: index], section.valueType == .assistant else {
            return
        }
        section.hidden = hidden
    }
    
    /// 缩放图表
    ///
    /// - Parameters:
    ///   - interval: 偏移量
    ///   - enlarge: 是否放大操作
    func zoomChart(by interval: Int, enlarge: Bool) {
        
        var newRangeTo   = 0
        var newRangeFrom = 0
        var newRange     = 0
        
        if enlarge {
            //双指张开
            newRangeTo   = self.pref.rangeTo - interval
            newRangeFrom = self.pref.rangeFrom + interval
            newRange     = self.pref.rangeTo - self.pref.rangeFrom
            if newRange >= self.pref.kMinRange {
                
                if self.pref.plotCount > self.pref.rangeTo - self.pref.rangeFrom {
                    if newRangeFrom < self.pref.rangeTo {
                        self.pref.rangeFrom = newRangeFrom
                    }
                    if newRangeTo > self.pref.rangeFrom {
                        self.pref.rangeTo = newRangeTo
                    }
                }else{
                    if newRangeTo > self.pref.rangeFrom {
                        self.pref.rangeTo = newRangeTo
                    }
                }
                self.pref.range = self.pref.rangeTo - self.pref.rangeFrom
                self.drawLayerView()
            }
            
        } else {
            //双指合拢
            newRangeTo   = self.pref.rangeTo + interval
            newRangeFrom = self.pref.rangeFrom - interval
            newRange     = self.pref.rangeTo - self.pref.rangeFrom
            if newRange <= self.pref.kMaxRange {
                
                if newRangeFrom >= 0 {
                    self.pref.rangeFrom = newRangeFrom
                } else {
                    self.pref.rangeFrom = 0
                    newRangeTo = newRangeTo - newRangeFrom //补充负数位到头部
                }
                if newRangeTo <= self.pref.plotCount {
                    self.pref.rangeTo = newRangeTo
                    
                } else {
                    self.pref.rangeTo = self.pref.plotCount
                    newRangeFrom = newRangeFrom - (newRangeTo - self.pref.plotCount)
                    if newRangeFrom < 0 {
                        self.pref.rangeFrom = 0
                    } else {
                        self.pref.rangeFrom = newRangeFrom
                    }
                }
                self.pref.range = self.pref.rangeTo - self.pref.rangeFrom
                self.drawLayerView()
            }
        }
    }
    
    /// 左右平移图表
    ///
    /// - Parameters:
    ///   - interval: 移动列数
    ///   - direction: 方向，true：右滑操作，fasle：左滑操作
    func moveChart(by interval: Int, direction: Bool) {
        if (interval > 0) {//有移动间隔才移动
            if direction {
                //单指向右拖，往后查看数据
                if self.pref.plotCount > (self.pref.rangeTo-self.pref.rangeFrom) {
                    if self.pref.rangeFrom - interval >= 0 {
                        self.pref.rangeFrom -= interval
                        self.pref.rangeTo   -= interval
                        
                    } else {
                        self.pref.rangeFrom = 0
                        self.pref.rangeTo   -= self.pref.rangeFrom
                    }
                    self.drawLayerView()
                }
            } else {
                //单指向左拖，往前查看数据
                if self.pref.plotCount > (self.pref.rangeTo-self.pref.rangeFrom) {
                    if self.pref.rangeTo + interval <= self.pref.plotCount {
                        self.pref.rangeFrom += interval
                        self.pref.rangeTo += interval
                        
                    } else {
                        self.pref.rangeFrom += self.pref.plotCount - self.pref.rangeTo
                        self.pref.rangeTo  = self.pref.plotCount
                    }
                    self.drawLayerView()
                }
            }
        }
        self.pref.range = self.pref.rangeTo - self.pref.rangeFrom
    }
    
    /// 手动设置分区头部文本显示内容
    ///
    /// - Parameters:
    ///   - titles: 文本内容及颜色元组
    ///   - section: 分区位置
    func setHeader(titles: [(title: String, color: UIColor)], inSection section: Int)  {
        guard let section = self.style.sections[safe: section] else {
            return
        }
        //设置标题
        section.setHeader(titles: titles)
    }
    
    /// 向分区添加新线段
    ///
    /// - Parameters:
    ///   - series: 线段
    ///   - section: 分区位置
    func addSeries(_ series: KSSeries, inSection section: Int) {
        guard let section = self.style.sections[safe: section] else {
            return
        }
        section.series.append(series)
        self.drawLayerView()
    }
    
    /// 通过主键名向分区删除线段
    ///
    /// - Parameters:
    ///   - key: 主键
    ///   - section: 分区位置
    func removeSeries(key: String, inSection section: Int) {
        guard let section = self.style.sections[safe: section] else {
            return
        }
        section.removeSeries(key: key)
        self.drawLayerView()
    }
}

// MARK: - 手势操作
extension KSKLineChartView: UIGestureRecognizerDelegate {
    
    /// 控制手势开关
    ///
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        switch gestureRecognizer {
        case is UITapGestureRecognizer:
            return self.enableTap
        case is UIPanGestureRecognizer:
            return self.style.enablePan
        case is UIPinchGestureRecognizer:
            return self.style.enablePinch
        default:
            return false
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is UITableView{
            return true
        }
        return false
    }
    
    /// 平移拖动操作
    ///
    /// - Parameter sender: 手势
    @objc func doPanAction(_ sender: UIPanGestureRecognizer) {
        
        if self.datas.count < self.pref.minCandleCount {
            return
        }
        
        if self.style.enablePan == false {
            return
        }
        
        self.showSelection  = false
        
        //手指滑动总平移量
        let translation     = sender.translation(in: self)
        //滑动力度，用于释放手指时完成惯性滚动的效果
        let velocity        = sender.velocity(in: self)
        
        //获取可见的其中一个分区
        let visiableSection = self.style.sections.filter { !$0.hidden }
        guard let section = visiableSection.first else {
            return
        }
        
        //该分区每个点的间隔宽度
        let plotWidth = (section.frame.size.width - section.padding.left - section.padding.right) / CGFloat(self.pref.rangeTo - self.pref.rangeFrom)
        
        switch sender.state {
        case .began:
            self.animator.removeAllBehaviors()
        case .changed:
            //计算移动距离的绝对值，距离满足超过线条宽度就进行图表平移刷新
            let distance = abs(translation.x)
            if distance > plotWidth {
                let isRight = translation.x > 0 ? true : false
                let interval = lroundf(abs(Float(distance / plotWidth)))
                self.moveChart(by: interval, direction: isRight)
                //重新计算起始位
                sender.setTranslation(CGPoint(x: 0, y: 0), in: self)
            }
            
        case .ended, .cancelled:
            //重置减速开始
            self.pref.decelerationStartX    = 0
            //添加减速行为
            self.dynamicItem.center         = self.bounds.origin
            let decelerationBehavior        = UIDynamicItemBehavior(items: [self.dynamicItem])
            decelerationBehavior.addLinearVelocity(velocity, for: self.dynamicItem)
            decelerationBehavior.resistance = 2.0
            var counter: Int                = 0
            decelerationBehavior.action = {[weak self]() -> Void in
                counter += 1
                if counter % 2 != 0 {
                    return
                }
                //到边界不执行移动
                if self?.pref.rangeFrom == 0 || self?.pref.rangeTo == self?.pref.plotCount{
                    return
                }
                let itemX    = self?.dynamicItem.center.x ?? 0
                let startX   = self?.pref.decelerationStartX ?? 0
                //计算移动距离的绝对值，距离满足超过线条宽度就进行图表平移刷新
                let distance = abs(itemX - startX)
                if distance > plotWidth {
                    let isRight                   = itemX > 0 ? true : false
                    let interval                  = lroundf(abs(Float(distance / plotWidth)))
                    self?.moveChart(by: interval, direction: isRight)
                    //重新计算起始位
                    self?.pref.decelerationStartX = itemX
                }
            }
            //添加动力行为
            self.animator.addBehavior(decelerationBehavior)
            self.decelerationBehavior = decelerationBehavior
        default:
            break
        }
    }
    
    /// 点击事件处理
    @objc func doTapAction(_ sender: UITapGestureRecognizer) {
        if self.enableTap == false {
            return
        }
        let point = sender.location(in: self)
        let tuple = self.getSectionByTouchPoint(point)
        if let section = tuple.1 {
            if section.paging {
                section.nextPage()
                updateSerie(hidden: false, key: section.tai, isMasterCandle: false, index: section.index)
                refreshChart(isAll: true, isDraw: true, isChangeTai: true)
                self.delegate?.ksLineChart?(self, didFlipSection: section)
            }
        }
        
        self.delegate?.ksLineChartDidTap?(self)

        if sender.state == .ended {
            self.showSelection = false
        }
        /*
        switch sender.state {
        case .possible:
            print("possible")
            break
        case .began:
            print("began")
            break
        case .changed:
            print("changed")
            break
        case .ended:
            print("ended")
            break
        case .cancelled:
            print("cancelled")
            break
        case .failed:
            print("failed")
            break
        default:
            print("Other")
        }*/
    }
    
    /// 双指手势缩放图表
    ///
    /// - Parameter sender: 手势
    @objc func doPinchAction(_ sender: UIPinchGestureRecognizer) {
        //防止数量较少时,显示异常
        if self.datas.count < self.pref.minCandleCount {
            return
        }
        
        if self.style.enablePinch == false {
            return
        }
        
        //获取可见的其中一个分区
        let visiableSection = self.style.sections.filter { !$0.hidden }
        guard let section = visiableSection.first else {
            return
        }
        
        //该分区每个点的间隔宽度
        let plotWidth = (section.frame.size.width - section.padding.left - section.padding.right) / CGFloat(self.pref.rangeTo - self.pref.rangeFrom)
        
        //双指合拢或张开
        let scale = sender.scale
        var newRange = 0
        
        //根据放大比例计算一个新的列宽
        let newPlotWidth = plotWidth * scale
        
        let newRangeF = (section.frame.size.width - section.padding.left - section.padding.right) / newPlotWidth
        newRange = scale > 1 ? Int(newRangeF + 1) : Int(newRangeF)
        let distance = abs(self.pref.range - newRange)
        //放大缩小的距离为偶数
        if distance % 2 == 0 && distance > 0 {
            let enlarge = scale > 1 ? true : false
            self.zoomChart(by: distance / 2, enlarge: enlarge)
            sender.scale = 1 //恢复比例
        }
    }
    
    /// 处理长按操作
    ///
    /// - Parameter sender:
    @objc func doLongPressAction(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .ended:
            self.hideCross()
        default: break
        }
        
        if self.pref.rangeFrom >= self.pref.rangeTo {
            return
        }
        
        let point = sender.location(in: self)
        let (_, section) = self.getSectionByTouchPoint(point)
        if section != nil {
            if section?.valueType == .assistant {
                return
            }
            if !section!.paging {
                //显示点击选中的内容
                self.setSelectedIndexByPoint(point)
            }
        }
    }
    
}
/// 绘制重构
extension KSKLineChartView {
    
    func drawLevelLayer() {
        self.drawLayer.removeSubLayer()
        self.topLayer.removeSubLayer()
        self.topLayer.initLayer(style: self.style)
        
        self.topLayer.resetLayerData()
        
        self.drawLevelContent()
    }
    
    func drawLevelContent() {
        self.buildSections {(section, index) in
            self.gridLayer.drawSectionGrid(section, style: self.style, pref: self.pref, topLayer: self.topLayer)
            self.gridLayer.addSublayer(section.titleLayer)//[绘制最顶部价格/指标值等数据]
        }
    }

    func updateYAxisTitle(_ section: KSSection) {
        if self.style.showYAxisLabel == .none {
            return
        }
        
        let interval           = (section.yAxis.max - section.yAxis.min)/CGFloat(section.yAxis.tickInterval - 1)
        var labelText: CGFloat = 0

        for i in 0..<section.yAxisTitles.count {
            if i == 0 {
                labelText = section.yAxis.max
            }
            else if i == section.yAxisTitles.count - 1 {
                labelText = section.yAxis.min
            }
            else {
                labelText = (section.yAxis.max - interval * CGFloat(i))
            }
            let yAxisLabel    = section.yAxisTitles[i]
            yAxisLabel.string = self.delegate?.ksLineChart?(self, rowTitleInSection: section, titleValue: labelText)
        }
    }
}
