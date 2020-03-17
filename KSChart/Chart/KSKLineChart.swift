//
//  ZeroShare
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
@objc protocol KSKLineChartDelegate: class {
    
    /// 更新chart datas:[KSChartItem]数据
    ///
    /// - Parameter chart: 视图
    @objc func dataSource(chart: KSKLineChartView) -> [KSChartItem]
    
    /// 获取图表Y轴的显示的内容
    ///
    /// - Parameters:
    ///   - chart:
    ///   - value: 计算得出的y值
    ///   - index:
    ///   - section:
    func kLineChart(chart: KSKLineChartView, labelOnYAxisForValue value: CGFloat, atIndex index: Int, section: KSSection) -> String
    
    /// 获取图表X轴的显示的内容
    ///
    /// - Parameters:
    ///   - chart:
    ///   - index:
    @objc optional func kLineChart(chart: KSKLineChartView, labelOnXAxisForIndex index: Int) -> String
    
    /// 完成绘画图表
    ///
    /// - Parameter chart:
    @objc optional func didFinishKLineChartRefresh(chart: KSKLineChartView)
    
    /// 配置各个分区小数位保留数
    ///
    /// - parameter chart:
    /// - parameter decimalForSection: 分区
    ///
    /// - returns:
    @objc optional func kLineChart(chart: KSKLineChartView, decimalAt section: Int) -> Int
    
    /// 设置y轴标签的宽度
    ///
    /// - parameter chart:
    ///
    /// - returns:
    @objc optional func widthForYAxisLabelInKLineChart(chart: KSKLineChartView) -> CGFloat
    
    /// 点击图表列响应方法
    ///
    /// - Parameters:
    ///   - chart: 图表
    ///   - index: 点击的位置
    ///   - item: 数据对象
    @objc optional func kLineChart(chart: KSKLineChartView, didSelectAt index: Int, item: KSChartItem)
    
    /// X轴的布局高度
    ///
    /// - Parameter chart: 图表
    /// - Returns: 返回自定义的高度
    @objc optional func heightForXAxisInKLineChart(chart: KSKLineChartView) -> CGFloat
    
    /// 初始化时的显示范围长度
    ///
    /// - Parameter chart: 图表
    /// @objc optional func initRangeInKLineChart(chart: KSKLineChartView) -> Int
    
    /// 自定义选择点时出现的标签样式
    ///
    /// - Parameters:
    ///   - chart: 图表
    ///   - yAxis: 可给用户自定义的y轴显示标签
    ///   - viewOfXAxis: 可给用户自定义的x轴显示标签
    @objc optional func kLineChart(chart: KSKLineChartView, viewOfYAxis yAxis: UILabel, viewOfXAxis: UILabel)
    
    /// 自定义section的头部View显示内容
    ///
    /// - Parameters:
    ///   - chart: 图表
    ///   - section: 分区的索引位
    /// - Returns: 自定义的View
    @objc optional func kLineChart(chart: KSKLineChartView, viewForHeaderInSection section: Int) -> UIView?
    
    /// 自定义section的头部View显示内容
    ///
    /// - Parameters:
    ///   - chart: 图表
    ///   - section: 分区的索引位
    /// - Returns: 自定义的View
    @objc optional func kLineChart(chart: KSKLineChartView, titleForHeaderInSection section: KSSection, index: Int, item: KSChartItem) -> NSAttributedString?
    
    /// 切换分区用分页方式展示的线组
    @objc optional func kLineChart(chart: KSKLineChartView, didFlipPageSeries section: KSSection, series: KSSeries, seriesIndex: Int)
    
    /// 十字架显示和影藏
    @objc optional func kLineChart(chart: KSKLineChartView, displayCross: Bool)
    
    /// Tap事件回调
    @objc optional func kLineChartTapAction(chart: KSKLineChartView)
}

class KSKLineChartView: UIView {
    
    /// MARK: - 常量
    let kMinRange                            = 16//最小缩放范围
    let kMaxRange                            = 128//最大缩放范围
    let kPerInterval                         = 4//缩放的每段间隔
    let kYAxisLabelWidth: CGFloat            = 46//默认文字宽度
    let kXAxisHegiht: CGFloat                = 16//默认X坐标的高度

    var minCandleCount: Int                  = 30//最小蜡烛图数量
    var fixedWidth: CGFloat                  = 10//小于最小蜡烛图数量，蜡烛的宽度
    var fixedGrid: Int                       = 2//最小格子数

    /// MARK: - 成员变量
    var upColor: UIColor                     = UIColor.green//升的颜色
    var downColor: UIColor                   = UIColor.red//跌的颜色
    var labelFont                            = UIFont.systemFont(ofSize: 10)
    var lineColor: UIColor                   = UIColor(white: 0.2, alpha: 1)//线条颜色
    var textColor: UIColor                   = UIColor(white: 0.8, alpha: 1)//文字颜色
    var xAxisPerInterval: Int                = 4//x轴的间断个数

    var yAxisLabelWidth: CGFloat             = 0//Y轴的宽度
    var padding: UIEdgeInsets                = UIEdgeInsets.zero//内边距
    var showYAxisLabel                       = KSYAxisShowPosition.right//显示y的位置，默认右边
    var isInnerYAxis: Bool                   = false// 是否把y坐标内嵌到图表中
    var selectedPosition: KSSelectedPosition = .onClosePrice//选中显示y值的位置

    open weak var delegate: KSKLineChartDelegate? //代理

    var sections                             = [KSSection]()//分区样式Demo中N个样式，分别是主图/附图1/附图2
    var selectedIndex: Int                   = -1//选择单个点的索引
    var scrollToPosition: KSScrollPosition   = .none//图表刷新后开始显示位置
    var selectedPoint: CGPoint               = CGPoint.zero

    //是否可缩放
    var enablePinch: Bool                    = true
    //是否可滑动
    var enablePan: Bool                      = true
    //是否可点选
    var enableTap: Bool = true {
        didSet {
            self.showSelection = self.enableTap
        }
    }
    
    /// 是否显示选中的内容
    var showSelection: Bool = true {
        didSet {
            self.selectedXAxisLabel?.isHidden = !self.showSelection
            self.selectedYAxisLabel?.isHidden = !self.showSelection
            self.verticalLineView?.isHidden   = !self.showSelection
            self.horizontalLineView?.isHidden = !self.showSelection
            if isCrosshair {
                self.sightView?.isHidden      = !self.showSelection
            }
            else{
                self.sightView?.isHidden      = true
            }
        }
    }
    
    /// 把X坐标内容显示到哪个索引分区上，默认为-1，表示最后一个，如果用户设置溢出的数值，也以最后一个
    var showXAxisOnSection: Int = -1

    /// 是否显示X轴标签
    var showXAxisLabel: Bool    = true

    /// 是否显示所有内容
    var isShowAll: Bool         = false
    
    /// 显示边线上左下有
    var borderWidth: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (0.25, 0.25, 0.25, 0.25)
    
    var lineWidth: CGFloat               = 0.5
    var plotCount: Int                   = 0//所有蜡烛图的个数
    var rangeFrom: Int                   = 0//可见区域的开始索引位
    var rangeTo: Int                     = 0//可见区域的结束索引位
    var range: Int                       = 60//显示在可见区域的个数
    var borderColor: UIColor             = UIColor.gray
    var labelSize                        = CGSize(width: 40, height: 16)

    var datas: [KSChartItem]             = [KSChartItem]()//数据源,不能直接赋值，后面会被清空

    var selectedBGColor: UIColor         = UIColor(white: 0.4, alpha: 1)//选中点的显示的框背景颜色
    var selectedTextColor: UIColor       = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)//选中点的显示的文字颜色
    var verticalLineView: UIView?
    var horizontalLineView: UIView?
    var selectedXAxisLabel: UILabel?
    var selectedYAxisLabel: UILabel?
    var sightView: UIView?//点击出现的准星
    var isCrosshair:Bool                 = false//是否显示准星

    //动力学引擎
    lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self)

    //动力的作用点
    lazy var dynamicItem                 = KSDynamicItem()

    //滚动图表时用于处理线性减速
    weak var decelerationBehavior: UIDynamicItemBehavior?

    //滚动释放后用于反弹回来
    //weak var springBehavior: UIAttachmentBehavior?

    //减速开始x
    var decelerationStartX: CGFloat      = 0

    /// 用于图表的图层
    var drawLayer: KSShapeLayer          = KSShapeLayer()

    /// 点线图层
    var chartModelLayer: KSShapeLayer    = KSShapeLayer()

    /// 图表数据信息显示层，显示每个分区的数值内容
    var chartInfoLayer: KSShapeLayer     = KSShapeLayer()
    /// 技术指标名称:算法
    var chartTais: [String: KSIndexAlgorithm]!
    
    var style: KSKLineChartStyle! {           //显示样式
        didSet {
            assert(self.style.chartTais != nil, "chartTais 不能为nil")
            //重新配置样式
            self.sections            = self.style.sections
            self.chartTais           = self.style.chartTais
            self.padding             = self.style.padding
            self.lineColor           = self.style.lineColor
            self.textColor           = self.style.textColor
            self.labelFont           = self.style.labelFont
            self.showYAxisLabel      = self.style.showYAxisLabel
            self.selectedBGColor     = self.style.selectedBGColor
            self.selectedTextColor   = self.style.selectedTextColor
            self.isInnerYAxis        = self.style.isInnerYAxis
            self.enableTap           = self.style.enableTap
            self.enablePinch         = self.style.enablePinch
            self.enablePan           = self.style.enablePan
            self.isCrosshair         = self.style.isCrosshair
            self.showSelection       = self.style.showSelection
            self.showXAxisOnSection  = self.style.showXAxisOnSection
            self.isShowAll           = self.style.isShowAll
            self.showXAxisLabel      = self.style.showXAxisLabel
            self.borderWidth         = self.style.borderWidth

            minCandleCount           = range/2
            for section in sections {
                for serie in section.series {
                    for model in serie.chartModels {
                        model.minCandleCount = minCandleCount
                        model.fixedWidth     = fixedWidth
                    }
                }
            }
            
            initViewState()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeKit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /// 初始化UI
    func initializeKit() {
        //开启多点触控
        self.isMultipleTouchEnabled                        = true

        //初始化点击选择的辅助线显示
        self.verticalLineView                              = UIView(frame: CGRect(x: 0, y: 0, width: lineWidth, height: 0))
        self.addSubview(self.verticalLineView!)

        self.horizontalLineView                            = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: lineWidth))
        self.addSubview(self.horizontalLineView!)

        //用户点击图表显示当前y轴的实际值
        self.selectedYAxisLabel                            = UILabel(frame: CGRect.zero)
        self.selectedYAxisLabel?.minimumScaleFactor        = 0.5
        self.selectedYAxisLabel?.lineBreakMode             = .byClipping
        self.selectedYAxisLabel?.adjustsFontSizeToFitWidth = true
        self.selectedYAxisLabel?.textAlignment             = NSTextAlignment.center
        self.addSubview(self.selectedYAxisLabel!)

        //用户点击图表显示当前x轴的实际值
        self.selectedXAxisLabel                            = UILabel(frame: CGRect.zero)
        self.selectedXAxisLabel?.textAlignment             = NSTextAlignment.center
        self.addSubview(self.selectedXAxisLabel!)

        self.sightView                                     = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        self.sightView?.layer.cornerRadius                 = 3
        self.addSubview(self.sightView!)

        //绘画图层
        self.layer.addSublayer(self.drawLayer)

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

    private func initViewState() {
        self.backgroundColor                     = self.style.backgroundColor
        self.verticalLineView?.backgroundColor   = self.style.crosshairColor
        self.horizontalLineView?.backgroundColor = self.style.crosshairColor
        self.sightView?.backgroundColor          = self.style.crosshairColor

        self.selectedYAxisLabel?.font            = self.labelFont
        self.selectedYAxisLabel?.backgroundColor = self.selectedBGColor
        self.selectedYAxisLabel?.textColor       = self.selectedTextColor

        self.selectedXAxisLabel?.font            = self.labelFont
        self.selectedXAxisLabel?.backgroundColor = self.selectedBGColor
        self.selectedXAxisLabel?.textColor       = self.selectedTextColor

        self.verticalLineView?.isHidden          = true
        self.horizontalLineView?.isHidden        = true
        self.selectedYAxisLabel?.isHidden        = true
        self.selectedXAxisLabel?.isHidden        = true
        self.sightView?.isHidden                 = true
    }
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        //布局完成重绘
        self.drawLayerView()
    }
    */
    
    public func scrollPositionEnd() -> Bool {
        if self.rangeTo == 0 || self.plotCount < self.range {
            return true
        }
        if self.rangeTo >= self.plotCount {
            return true
        }
        if (self.rangeFrom + self.range + 1) >= self.plotCount {
            return true
        }
        return false
    }
    
    /// 计算技术指标
    ///
    /// - Parameter isAll: 是否计算全部指标
    private func calculatorTai(isAll: Bool = true) {
        guard let myDatas = self.delegate?.dataSource(chart: self) else {
            return
        }
        
        self.plotCount = self.datas.count
        self.datas     = myDatas
        var index: Int = 0
        if isAll == false {
            index = self.datas.count - 1
            if index < 0 {
                index = 0
            }
        }
        for section in self.sections {
            _ = KSCalculator.ks_calculator(algorithm: chartTais[section.tai] ?? KSIndexAlgorithm.none, index: index, datas: self.datas)
        }
    }

    /// 刷新k线
    ///
    /// - Parameters:
    ///   - isAll: 是否刷新全部数据
    ///   - isDraw: 是否绘制
    ///   - isChangeTai: 是否修改了技术指标
    func refreshChart(isAll: Bool = true, isDraw: Bool = true, isChangeTai: Bool = false) {
        self.calculatorTai(isAll: isAll)
        if isDraw {
            self.scrollToPosition = self.scrollPositionEnd() ? .end : .none
            if isChangeTai {
                self.drawLayerView()
            }
            else{
                if self.scrollToPosition == .end {
                    self.drawLayerView()
                }
            }
        }
    }
    
    /// 通过key隐藏或显示线系列
    func updateSerie(hidden: Bool, key: String, isMasterCandle: Bool, index: Int = 0) {
        if index >= self.sections.count {
            return
        }
        let section = self.sections[index]
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
        //self.sections 分区样式，Demo中3个样式，分别是k线/成交量/技术指标
        for (i, section) in self.sections.enumerated() {
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
        let visiableSection = self.sections.filter { !$0.hidden }
        var showSection: KSSection?
        for (i, section) in visiableSection.enumerated() {
            //用户自定义显示X轴的分区
            if section.index == self.showXAxisOnSection {
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
        if self.datas.count < minCandleCount {
            return fixedWidth
        }
        let plotWidth = (section.frame.size.width - section.padding.left - section.padding.right) / CGFloat(self.rangeTo - self.rangeFrom)
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
        
        let visiableSections = self.sections.filter { !$0.hidden }
        guard let lastSection = visiableSections.last else {
            return
        }
        
        let showXAxisSection                     = self.getSecionWhichShowXAxis()

        //重置文字颜色和字体
        self.selectedYAxisLabel?.font            = self.labelFont
        self.selectedYAxisLabel?.backgroundColor = self.selectedBGColor
        self.selectedYAxisLabel?.textColor       = self.selectedTextColor
        self.selectedXAxisLabel?.font            = self.labelFont
        self.selectedXAxisLabel?.backgroundColor = self.selectedBGColor
        self.selectedXAxisLabel?.textColor       = self.selectedTextColor

        let yaxis                                = section!.yAxis
        let format                               = "%.".appendingFormat("%df", yaxis.decimal)

        self.selectedPoint                       = point

        //每个点的宽度
        let plotWidth                            = latticeWidth(section: section!)// (section!.frame.size.width - section!.padding.left - section!.padding.right) / CGFloat(self.rangeTo - self.rangeFrom)

        var yVal: CGFloat                        = 0//获取y轴坐标的实际值
        
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
                //self.horizontalLineView?.isHidden = false

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
                let hwidth = section!.frame.size.width - section!.padding.left - section!.padding.right
                //显示辅助线
                self.verticalLineView?.frame = CGRect(x: vx, y: vy - self.lineWidth / 2, width: hwidth, height: self.lineWidth)
                //self.verticalLineView?.isHidden = false
                
                //显示y轴辅助内容
                //控制y轴的label在左还是右显示
                var yAxisStartX: CGFloat = 0
                //self.selectedYAxisLabel?.isHidden = false
                //self.selectedXAxisLabel?.isHidden = false
                switch self.showYAxisLabel {
                case .left:
                    yAxisStartX = section!.frame.origin.x
                case .right:
                    yAxisStartX = section!.frame.maxX - self.yAxisLabelWidth
                case .none:
                    self.selectedYAxisLabel?.isHidden = true
                }
                self.selectedYAxisLabel?.text  = String(format: format, yVal)//显示实际值
                self.selectedYAxisLabel?.frame = CGRect(x: yAxisStartX, y: vy - self.labelSize.height / 2, width: self.yAxisLabelWidth, height: self.labelSize.height)
                let time                       = Date.ks_getTimeByStamp(item.time, format: "yyyy-MM-dd HH:mm")//显示实际值
                let size                       = time.ks_sizeWithConstrained(self.labelFont)
                self.selectedXAxisLabel?.text  = time

                //判断x是否超过左右边界
                let labelWidth = size.width  + 6
                var x = hx - (labelWidth) / 2
                
                if x < section!.frame.origin.x {
                    x = section!.frame.origin.x
                } else if x + labelWidth > section!.frame.origin.x + section!.frame.size.width {
                    x = section!.frame.origin.x + section!.frame.size.width - labelWidth
                }
                
                self.selectedXAxisLabel?.frame = CGRect(x: x, y: showXAxisSection.frame.maxY, width: size.width  + 6, height: self.labelSize.height)
                
                if self.isCrosshair {
                    self.sightView?.center     = CGPoint(x: hx, y: vy)
                }
                
                //给用户进行最后的自定义
                self.delegate?.kLineChart?(chart: self, viewOfYAxis: self.selectedXAxisLabel!, viewOfXAxis: self.selectedYAxisLabel!)
                
                self.showSelection = true
                
                self.bringSubviewToFront(self.verticalLineView!)
                self.bringSubviewToFront(self.horizontalLineView!)
                self.bringSubviewToFront(self.selectedXAxisLabel!)
                self.bringSubviewToFront(self.selectedYAxisLabel!)
                if self.isCrosshair {
                    self.bringSubviewToFront(self.sightView!)
                }
                
                //设置选中点
                self.setSelectedByIndex(i)
                
                break
            }
        }
    }
    
    /// 设置选中的数据点,并回调
    ///
    /// - Parameter index: 选中位置
    func setSelectedByIndex(_ index: Int) {
        if index >= self.datas.count {
            return
        }
        
        //如果不在区间内return
        guard index >= self.rangeFrom && index < self.rangeTo else {
            return
        }
        
        self.selectedIndex = index
        let item           = self.datas[index]

        //显示分区的header标题
        for (_, section) in self.sections.enumerated() {
            if section.hidden {
                continue
            }
            
            if let titleString = self.delegate?.kLineChart?(chart: self,
                                                            titleForHeaderInSection: section,
                                                            index: index,
                                                            item: self.datas[index]) {
                //显示用户自定义的title
                section.drawTitleForHeader(title: titleString)
            } else {
                //显示默认
                section.drawTitle(index)
            }
        }
        
        //回调
        self.delegate?.kLineChart?(chart: self, didSelectAt: index, item: item)
    }
}

// MARK: - 绘图相关方法
extension KSKLineChartView {
    
    /// 清空图表的子图层
    func removeLayerView() {
        for section in self.sections {
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
                xAxisToDraw     = self.drawXAxis(section)//[绘制最底部时间]

                //绘制Y轴坐标系，但最后的y轴标签放到绘制完线段才做
                let yAxisToDraw = self.drawYAxis(section)
                //绘制图表的点线
                self.drawChart(section)//[--- 绘制每个区域主视图(绘制K线/均价曲线/成交量/指数指标) ---]
                //绘制Y轴坐标上的标签
                self.drawYAxisLabel(yAxisToDraw)//[绘制最右侧价格/成交量/指标值等数据]

                //把标题添加到主绘图层上
                self.drawLayer.addSublayer(section.titleLayer)//[绘制最顶部价格/指标值等数据]

                //是否采用用户自定义
                if let titleView = self.delegate?.kLineChart?(chart: self, viewForHeaderInSection: index) {
                    
                    //显示用户自定义的View，显示内容交由委托者
                    section.showTitle = false
                    section.addCustomView(titleView, inView: self)
                    
                } else {
                    
                    if let titleString = self.delegate?.kLineChart?(chart: self,
                                                                   titleForHeaderInSection: section,
                                                                   index: self.selectedIndex,
                                                                   item: self.datas[self.selectedIndex]) {
                        //显示用户自定义的section title
                        section.drawTitleForHeader(title: titleString)
                    } else {
                        //显示范围最后一个点的内容
                        section.drawTitle(self.selectedIndex)
                    }
                }
            }
            
            let showXAxisSection = self.getSecionWhichShowXAxis()
            //显示在分区下面绘制X轴坐标
            self.drawXAxisLabel(showXAxisSection, xAxisToDraw: xAxisToDraw)
            
            //重新显示点击选中的坐标
            if self.showSelection {
                self.setSelectedIndexByPoint(self.selectedPoint)
            }
            self.delegate?.didFinishKLineChartRefresh?(chart: self)
        }
    }
    
    /// 初始化图表结构 -> 是否初始化数据
    func initChart() -> Bool {
        if self.scrollToPosition == .end && self.plotCount != self.datas.count {
            self.calculatorTai(isAll: true)
        }

        if self.plotCount > 0 {
            drawRange()
        }
        
        //重置图表刷新滚动默认不处理
        self.scrollToPosition = .none
        
        //选择最后一个元素选中
        if selectedIndex == -1 {
            self.selectedIndex = self.rangeTo - 1
        }
        
        let backgroundLayer       = KSShapeLayer()
        let backgroundPath        = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.size.width,height: self.bounds.size.height), cornerRadius: 0)
        backgroundLayer.path      = backgroundPath.cgPath
        backgroundLayer.fillColor = self.backgroundColor?.cgColor
        self.drawLayer.addSublayer(backgroundLayer)
        //let context = UIGraphicsGetCurrentContext()
        //context?.setFillColor(self.backgroundColor!.cgColor)
        //context?.fill (CGRect (x: 0, y: 0, width: self.bounds.size.width,height: self.bounds.size.height))
        return self.datas.count > 0 ? true : false
    }
    
    func drawRange() {
        //如果显示全部，显示范围为全部数据量
        if self.isShowAll {
            self.range     = self.plotCount
            self.rangeFrom = 0
            self.rangeTo   = self.plotCount
        }
        
        //图表刷新滚动为默认时，如果第一次初始化，就默认滚动到最后显示
        if self.scrollToPosition == .none {
            //如果图表尽头的索引为0，则进行初始化
            if self.rangeTo == 0 || self.plotCount < self.rangeTo {
                self.scrollToPosition = .end
            }
        }
        else if self.scrollToPosition == .top {
            self.rangeFrom = 0
            if self.rangeFrom + self.range < self.plotCount {
                self.rangeTo = self.rangeFrom + self.range//计算结束的显示的位置
            } else {
                self.rangeTo = self.plotCount
            }
            self.selectedIndex = -1
        } else if self.scrollToPosition == .end {
            self.rangeTo = self.plotCount               //默认是数据最后一条为尽头
            if self.rangeTo - self.range > 0 {          //如果尽头 - 默认显示数大于0
                self.rangeFrom = self.rangeTo - range   //计算开始的显示的位置
            } else {
                self.rangeFrom = 0
            }
            self.selectedIndex = -1
        }
    }
    
    /// 初始化各个分区
    ///
    /// - Parameter complete: 初始化后，执行每个分区绘制
    func buildSections(_ complete:(_ section: KSSection, _ index: Int) -> Void) {
        //计算实际的显示高度和宽度
        var height      = self.frame.size.height - (self.padding.top + self.padding.bottom)
        let width       = self.frame.size.width - (self.padding.left + self.padding.right)

        //X轴的布局高度
        let xAxisHeight = self.delegate?.heightForXAxisInKLineChart?(chart: self) ?? self.kXAxisHegiht
        height          = height - xAxisHeight

        var total       = 0
        for (index, section) in self.sections.enumerated() {
            section.index = index
            if !section.hidden {
                //如果使用fixHeight，ratios要设置为0
                if section.ratios > 0 {
                    total = total + section.ratios
                }
            }
        }
        
        var offsetY: CGFloat = self.padding.top
        //计算每个区域的高度，并绘制
        for (index, section) in self.sections.enumerated() {

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
            
            //设置y轴标签的宽度
            self.yAxisLabelWidth = self.delegate?.widthForYAxisLabelInKLineChart?(chart: self) ?? self.kYAxisLabelWidth
            
            //y轴的标签显示方位
            switch self.showYAxisLabel {
            case .left:         //左边显示
                section.padding.left = self.isInnerYAxis ? section.padding.left : self.yAxisLabelWidth
                section.padding.right = 0
            case .right:        //右边显示
                section.padding.left = 0
                section.padding.right = self.isInnerYAxis ? section.padding.right : self.yAxisLabelWidth
            case .none:         //都不显示
                section.padding.left = 0
                section.padding.right = 0
            }
            
            //计算每个section的坐标
            section.frame = CGRect(x: 0 + self.padding.left, y: offsetY, width: WidthOfSection, height: heightOfSection)
            offsetY       = offsetY + section.frame.height

            //如果这个分区设置为显示X轴，下一个分区的Y起始位要加上X轴高度
            if self.showXAxisOnSection == index {
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
        let endX: CGFloat            = section.frame.origin.x + section.frame.size.width - section.padding.right
        //let secWidth: CGFloat        = section.frame.size.width
        //let secPaddingLeft: CGFloat  = section.padding.left
        //let secPaddingRight: CGFloat = section.padding.right

        //x轴分平均分N个间断，显示N+1个x轴坐标，按照图表的值个数，计算每个间断的个数
        let dataRange                = self.rangeTo - self.rangeFrom
        var xTickInterval: Int       = dataRange / self.xAxisPerInterval
        if xTickInterval <= 0 {
            xTickInterval = 1
        }
        
        //绘制x轴标签
        //每个点的间隔宽度
        let perPlotWidth: CGFloat  = latticeWidth(section: section)//(secWidth - secPaddingLeft - secPaddingRight) / CGFloat(self.rangeTo - self.rangeFrom)
        if self.datas.count < minCandleCount {
            if self.datas.count < (minCandleCount/fixedGrid) {
                xTickInterval = dataRange
            }
            else {
                xTickInterval = dataRange / fixedGrid - 1
            }
        }

        let startY = section.frame.maxY
        var k: Int = 0
        var showXAxisReference = false
        
        //相当 for var i = self.rangeFrom; i < self.rangeTo; i = i + xTickInterval
        for i in stride(from: self.rangeFrom, to: self.rangeTo, by: xTickInterval) {
            
            let xLabel     = self.delegate?.kLineChart?(chart: self, labelOnXAxisForIndex: i) ?? ""
            let textSize   = xLabel.ks_sizeWithConstrained(self.labelFont)
            var xPox       = startX + (perPlotWidth / 2) - (textSize.width / 2)
            //计算最左最右的x轴标签不越过边界
            if (xPox < 0) {
                xPox = startX
            } else if (xPox + textSize.width > endX) {
                xPox = endX - textSize.width
            }
            let barLabelRect         = CGRect(x: xPox, y: startY, width: textSize.width, height: textSize.height)

            //记录待绘制的文本
            xAxisToDraw.append((barLabelRect, xLabel))

            //绘制辅助线
            let referencePath        = UIBezierPath()
            let referenceLayer       = KSShapeLayer()
            referenceLayer.lineWidth = self.lineWidth

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
                referencePath.move(to: CGPoint(x: xPox + textSize.width / 2, y: section.frame.minY))
                referencePath.addLine(to: CGPoint(x: xPox + textSize.width / 2, y: section.frame.maxY))
                referenceLayer.path = referencePath.cgPath
                xAxis.addSublayer(referenceLayer)
            }

            k      = k + xTickInterval
            startX = perPlotWidth * CGFloat(k)
        }
        self.drawLayer.addSublayer(xAxis)
        return xAxisToDraw
    }
    
    
    /// 绘制X坐标标签
    ///
    /// - Parameters:
    ///   - section: 哪个分区绘制
    ///   - xAxisToDraw: 待绘制的内容
    func drawXAxisLabel(_ section: KSSection, xAxisToDraw: [(CGRect, String)]) {
        
        guard self.showXAxisLabel else {
            return
        }
        
        guard xAxisToDraw.count > 0 else {
            return
        }
        
        let xAxis = KSShapeLayer()
        
        let startY = section.frame.maxY //需要显示x坐标标签名字的分区，再最下方显示
        //绘制x坐标标签，x的位置通过画辅助线时计算得出
        for (var barLabelRect, xLabel) in xAxisToDraw {

            barLabelRect.origin.y      = startY

            //绘制文本
            let xLabelText             = KSTextLayer()
            xLabelText.frame           = barLabelRect
            xLabelText.string          = xLabel
            xLabelText.alignmentMode   = CATextLayerAlignmentMode.center
            xLabelText.fontSize        = self.labelFont.pointSize
            xLabelText.foregroundColor = self.textColor.cgColor
            xLabelText.backgroundColor = UIColor.clear.cgColor
            xLabelText.contentsScale   = UIScreen.main.scale

            xAxis.addSublayer(xLabelText)
        }
        self.drawLayer.addSublayer(xAxis)
    }
    
    /// 绘制分区
    ///
    /// - Parameter section:
    func drawSection(_ section: KSSection) {
        
        //画分区的背景
        let sectionPath        = UIBezierPath(rect: section.frame)
        let sectionLayer       = KSShapeLayer()
        sectionLayer.fillColor = section.backgroundColor.cgColor
        sectionLayer.path      = sectionPath.cgPath
        self.drawLayer.addSublayer(sectionLayer)

        let borderPath         = UIBezierPath()

        //画底部边线
        if self.borderWidth.bottom > 0 {
            borderPath.append(UIBezierPath(rect: CGRect(x: section.frame.origin.x + section.padding.left, y: section.frame.size.height + section.frame.origin.y, width: section.frame.size.width - section.padding.left, height: self.borderWidth.bottom)))
        }
        
        //画顶部边线
        if self.borderWidth.top > 0 {
            borderPath.append(UIBezierPath(rect: CGRect(x: section.frame.origin.x + section.padding.left, y: section.frame.origin.y, width: section.frame.size.width - section.padding.left, height: self.borderWidth.top)))
        }

        //画左边线
        if self.borderWidth.left > 0 {
            borderPath.append(UIBezierPath(rect: CGRect(x: section.frame.origin.x + section.padding.left, y: section.frame.origin.y, width: self.borderWidth.left, height: section.frame.size.height)))
        }
        
        //画右边线
        if self.borderWidth.right > 0 {
            borderPath.append(UIBezierPath(rect: CGRect(x: section.frame.origin.x + section.frame.size.width - section.padding.right, y: section.frame.origin.y, width: self.borderWidth.left, height: section.frame.size.height)))
        }
        
        //添加到图层
        let borderLayer       = KSShapeLayer()
        borderLayer.lineWidth = self.lineWidth
        borderLayer.path      = borderPath.cgPath// 从贝塞尔曲线获取到形状
        borderLayer.fillColor = self.lineColor.cgColor// 闭环填充的颜色
        self.drawLayer.addSublayer(borderLayer)
    }
    
    /// 初始化分区上各个线的Y轴
    ///
    /// - Parameter section: 
    func initYAxis(_ section: KSSection) {
        if section.series.count > 0 {
            //建立分区每条线的坐标系
            section.buildYAxis(startIndex: self.rangeFrom, endIndex: self.rangeTo, datas: self.datas)
        }
    }
    
    /// 绘制Y轴左边
    ///
    /// - Parameter section: 分区
    /// - Returns:
    func drawYAxis(_ section: KSSection) -> [(CGRect, String)] {
        
        var yAxisToDraw              = [(CGRect, String)]()
        var valueToDraw              = Set<CGFloat>()

        var startX: CGFloat          = 0, startY: CGFloat = 0, extrude: CGFloat = 0
        var showYAxisLabel: Bool     = true
        var showYAxisReference: Bool = true

        //分区中各个y轴虚线和y轴的label
        //控制y轴的label在左还是右显示
        switch self.showYAxisLabel {
        case .left:
            startX  = section.frame.origin.x - 3 * (self.isInnerYAxis ? -1 : 1)
            extrude = section.frame.origin.x + section.padding.left - 2
        case .right:
            startX  = section.frame.maxX - self.yAxisLabelWidth + 3 * (self.isInnerYAxis ? -1 : 1)
            extrude = section.frame.origin.x + section.padding.left + section.frame.size.width - section.padding.right
        case .none:
            showYAxisLabel = false
        }
        
        let yaxis = section.yAxis
        
        //保持Y轴标签个数偶数显示
        //        if (yaxis.tickInterval % 2 == 1) {
        //            yaxis.tickInterval += 1
        //        }
        
        //计算y轴的标签及虚线分几段
        let step = (yaxis.max - yaxis.min) / CGFloat(yaxis.tickInterval)
        
        //从base值绘制Y轴标签到最大值
        var i = 0
        var yVal = yaxis.baseValue + CGFloat(i) * step
        while yVal <= yaxis.max && i <= yaxis.tickInterval {
            valueToDraw.insert(yVal)
            //递增下一个
            i =  i + 1
            yVal = yaxis.baseValue + CGFloat(i) * step
        }
        
        i = 0
        yVal = yaxis.baseValue - CGFloat(i) * step
        while yVal >= yaxis.min && i <= yaxis.tickInterval {
            
            valueToDraw.insert(yVal)
            
            //递增下一个
            i =  i + 1
            yVal = yaxis.baseValue - CGFloat(i) * step
        }
        
        for (i, yVal) in valueToDraw.enumerated() {
            
            //画虚线和Y标签值
            let iy = section.getLocalY(yVal)
            
            if self.isInnerYAxis {
                //y轴标签向内显示，为了不挡住辅助线，所以把y轴的数值位置向上移一些
                startY = iy - 14
            } else {
                startY = iy - 7
            }
            
            let referencePath = UIBezierPath()
            let referenceLayer = KSShapeLayer()
            referenceLayer.lineWidth = self.lineWidth
            
            //处理辅助线样式
            switch section.yAxis.referenceStyle {
            case let .dash(color: dashColor, pattern: pattern):
                referenceLayer.strokeColor = dashColor.cgColor
                referenceLayer.lineDashPattern = pattern
                showYAxisReference = true
            case let .solid(color: solidColor):
                referenceLayer.strokeColor = solidColor.cgColor
                showYAxisReference = true
            default:
                showYAxisReference = false
                startY = iy - 7
            }
            
            if showYAxisReference {
                
                //突出的线段，y轴向外显示才划突出线段
                if !self.isInnerYAxis {
                    referencePath.move(to: CGPoint(x: extrude, y: iy))
                    referencePath.addLine(to: CGPoint(x: extrude + 2, y: iy))
                }
                
                referencePath.move(to: CGPoint(x: section.frame.origin.x + section.padding.left, y: iy))
                referencePath.addLine(to: CGPoint(x: section.frame.origin.x + section.frame.size.width - section.padding.right, y: iy))
                
                referenceLayer.path = referencePath.cgPath
                self.drawLayer.addSublayer(referenceLayer)
            }
            
            if showYAxisLabel {
                
                //获取调用者回调的label字符串值
                let strValue = self.delegate?.kLineChart(chart: self, labelOnYAxisForValue: yVal, atIndex: i, section: section) ?? ""
                
                let yLabelRect = CGRect(x: startX,
                                        y: startY,
                                        width: yAxisLabelWidth,
                                        height: 12
                )
                
                yAxisToDraw.append((yLabelRect, strValue))
            }
        }
        return yAxisToDraw
    }
    
    /// 绘制y轴坐标上的标签
    ///
    /// - Parameter yAxisToDraw:
    func drawYAxisLabel(_ yAxisToDraw: [(CGRect, String)]) {
        
        var alignmentMode = CATextLayerAlignmentMode.left
        //分区中各个y轴虚线和y轴的label
        //控制y轴的label在左还是右显示
        switch self.showYAxisLabel {
        case .left:
            alignmentMode = self.isInnerYAxis ? CATextLayerAlignmentMode.left : CATextLayerAlignmentMode.right
        case .right:
            alignmentMode = self.isInnerYAxis ? CATextLayerAlignmentMode.right : CATextLayerAlignmentMode.left
        case .none:
            alignmentMode = CATextLayerAlignmentMode.left
        }
        
        for (yLabelRect, strValue) in yAxisToDraw {

            let yAxisLabel             = KSTextLayer()
            yAxisLabel.frame           = yLabelRect
            yAxisLabel.string          = strValue
            yAxisLabel.fontSize        = self.labelFont.pointSize
            yAxisLabel.foregroundColor = self.textColor.cgColor
            yAxisLabel.backgroundColor = UIColor.clear.cgColor
            yAxisLabel.alignmentMode   = alignmentMode
            yAxisLabel.contentsScale   = UIScreen.main.scale

            self.drawLayer.addSublayer(yAxisLabel)
            //NSString(string: strValue).draw(in: yLabelRect, withAttributes: fontAttributes)
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
                let serieLayer = model.drawSerie(self.rangeFrom, endIndex: self.rangeTo)
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
        self.scrollToPosition = toPosition
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
            hideSections = self.sections
        } else {
            if inSection >= self.sections.count {
                return //超过界限
            }
            hideSections.append(self.sections[inSection])
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
        for section in self.sections {
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
        guard let section = self.sections[safe: index], section.valueType == .assistant else {
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
            newRangeTo   = self.rangeTo - interval
            newRangeFrom = self.rangeFrom + interval
            newRange     = self.rangeTo - self.rangeFrom
            if newRange >= kMinRange {
                
                if self.plotCount > self.rangeTo - self.rangeFrom {
                    if newRangeFrom < self.rangeTo {
                        self.rangeFrom = newRangeFrom
                    }
                    if newRangeTo > self.rangeFrom {
                        self.rangeTo = newRangeTo
                    }
                }else{
                    if newRangeTo > self.rangeFrom {
                        self.rangeTo = newRangeTo
                    }
                }
                self.range = self.rangeTo - self.rangeFrom
                self.drawLayerView()
            }
            
        } else {
            //双指合拢
            newRangeTo   = self.rangeTo + interval
            newRangeFrom = self.rangeFrom - interval
            newRange     = self.rangeTo - self.rangeFrom
            if newRange <= kMaxRange {
                
                if newRangeFrom >= 0 {
                    self.rangeFrom = newRangeFrom
                } else {
                    self.rangeFrom = 0
                    newRangeTo = newRangeTo - newRangeFrom //补充负数位到头部
                }
                if newRangeTo <= self.plotCount {
                    self.rangeTo = newRangeTo
                    
                } else {
                    self.rangeTo = self.plotCount
                    newRangeFrom = newRangeFrom - (newRangeTo - self.plotCount)
                    if newRangeFrom < 0 {
                        self.rangeFrom = 0
                    } else {
                        self.rangeFrom = newRangeFrom
                    }
                }
                self.range = self.rangeTo - self.rangeFrom
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
                if self.plotCount > (self.rangeTo-self.rangeFrom) {
                    if self.rangeFrom - interval >= 0 {
                        self.rangeFrom -= interval
                        self.rangeTo   -= interval
                        
                    } else {
                        self.rangeFrom = 0
                        self.rangeTo   -= self.rangeFrom
                    }
                    self.drawLayerView()
                }
            } else {
                //单指向左拖，往前查看数据
                if self.plotCount > (self.rangeTo-self.rangeFrom) {
                    if self.rangeTo + interval <= self.plotCount {
                        self.rangeFrom += interval
                        self.rangeTo += interval
                        
                    } else {
                        self.rangeFrom += self.plotCount - self.rangeTo
                        self.rangeTo  = self.plotCount
                    }
                    self.drawLayerView()
                }
            }
        }
        self.range = self.rangeTo - self.rangeFrom
    }
    
    /*
    /// 生成截图
    var image: UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return capturedImage!
    }
    */
    
    /// 手动设置分区头部文本显示内容
    ///
    /// - Parameters:
    ///   - titles: 文本内容及颜色元组
    ///   - section: 分区位置
    func setHeader(titles: [(title: String, color: UIColor)], inSection section: Int)  {
        guard let section = self.sections[safe: section] else {
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
        guard let section = self.sections[safe: section] else {
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
        guard let section = self.sections[safe: section] else {
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
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        switch gestureRecognizer {
        case is UITapGestureRecognizer:
            return self.enableTap
        case is UIPanGestureRecognizer:
            return self.enablePan
        case is UIPinchGestureRecognizer:
            return self.enablePinch
        default:
            return false
        }
    }
   
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is UITableView{
            return true
        }
        return false
    }
    
    /// 平移拖动操作
    ///
    /// - Parameter sender: 手势
    @objc func doPanAction(_ sender: UIPanGestureRecognizer) {
        
        if self.datas.count < minCandleCount {
            return
        }
        
        if self.enablePan == false {
            return
        }
        
        self.showSelection  = false

        //手指滑动总平移量
        let translation     = sender.translation(in: self)
        //滑动力度，用于释放手指时完成惯性滚动的效果
        let velocity        = sender.velocity(in: self)

        //获取可见的其中一个分区
        let visiableSection = self.sections.filter { !$0.hidden }
        guard let section = visiableSection.first else {
            return
        }
        
        //该分区每个点的间隔宽度
        let plotWidth = (section.frame.size.width - section.padding.left - section.padding.right) / CGFloat(self.rangeTo - self.rangeFrom)
        
        switch sender.state {
        case .began:
            self.animator.removeAllBehaviors()
        case .changed:
            
            //计算移动距离的绝对值，距离满足超过线条宽度就进行图表平移刷新
            let distance = abs(translation.x)
            //print("translation.x = \(translation.x)")
            //print("distance = \(distance)")
            if distance > plotWidth {
                let isRight = translation.x > 0 ? true : false
                let interval = lroundf(abs(Float(distance / plotWidth)))
                self.moveChart(by: interval, direction: isRight)
                //重新计算起始位
                sender.setTranslation(CGPoint(x: 0, y: 0), in: self)
            }
            
        case .ended, .cancelled:
            
            //重置减速开始
            self.decelerationStartX         = 0
            //添加减速行为
            self.dynamicItem.center         = self.bounds.origin
            let decelerationBehavior        = UIDynamicItemBehavior(items: [self.dynamicItem])
            decelerationBehavior.addLinearVelocity(velocity, for: self.dynamicItem)
            decelerationBehavior.resistance = 2.0
            decelerationBehavior.action = {[weak self]() -> Void in
                //print("self.dynamicItem.x = \(self?.dynamicItem.center.x ?? 0)")
                
                //到边界不执行移动
                if self?.rangeFrom == 0 || self?.rangeTo == self?.plotCount{
                    return
                }
                
                let itemX = self?.dynamicItem.center.x ?? 0
                let startX = self?.decelerationStartX ?? 0
                //计算移动距离的绝对值，距离满足超过线条宽度就进行图表平移刷新
                let distance = abs(itemX - startX)
                //print("distance = \(distance)")
                if distance > plotWidth {
                    let isRight              = itemX > 0 ? true : false
                    let interval             = lroundf(abs(Float(distance / plotWidth)))
                    self?.moveChart(by: interval, direction: isRight)
                    //重新计算起始位
                    self?.decelerationStartX = itemX
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
        
        guard self.enableTap else {
            return
        }
        
        let point = sender.location(in: self)
        let tuple = self.getSectionByTouchPoint(point)
        if let section = tuple.1 {
            if section.paging {
                section.nextPage()
                updateSerie(hidden: false, key: section.tai, isMasterCandle: false, index: section.index)
                refreshChart(isAll: true, isDraw: true, isChangeTai: true)
                self.delegate?.kLineChart?(chart: self, didFlipPageSeries: section, series: section.series[section.selectedIndex], seriesIndex: section.selectedIndex)
            }
            else{
                //显示点击选中的内容
                self.setSelectedIndexByPoint(point)
            }
        }
        
        self.delegate?.kLineChartTapAction?(chart: self)
    }
    
    /// 双指手势缩放图表
    ///
    /// - Parameter sender: 手势
    @objc func doPinchAction(_ sender: UIPinchGestureRecognizer) {
        //防止数量较少时,显示异常
        if self.datas.count < minCandleCount {
            return
        }
        
        if self.enablePinch == false {
            return
        }
        
        //获取可见的其中一个分区
        let visiableSection = self.sections.filter { !$0.hidden }
        guard let section = visiableSection.first else {
            return
        }
        
        //该分区每个点的间隔宽度
        let plotWidth = (section.frame.size.width - section.padding.left - section.padding.right) / CGFloat(self.rangeTo - self.rangeFrom)

        //双指合拢或张开
        let scale = sender.scale
        var newRange = 0
        
        //根据放大比例计算一个新的列宽
        let newPlotWidth = plotWidth * scale
        
        let newRangeF = (section.frame.size.width - section.padding.left - section.padding.right) / newPlotWidth
        newRange = scale > 1 ? Int(newRangeF + 1) : Int(newRangeF)
        let distance = abs(self.range - newRange)
        //放大缩小的距离为偶数
        if distance % 2 == 0 && distance > 0 {
            //print("scale = \(scale)")
            let enlarge = scale > 1 ? true : false
            self.zoomChart(by: distance / 2, enlarge: enlarge)
            sender.scale = 1 //恢复比例
        }
    }
    
    /// 处理长按操作
    ///
    /// - Parameter sender:
    @objc func doLongPressAction(_ sender: UILongPressGestureRecognizer) {
        
        if self.rangeFrom >= self.rangeTo {
            return
        }
        
        let point = sender.location(in: self)
        let (_, section) = self.getSectionByTouchPoint(point)
        if section != nil {
            if section?.valueType == .assistant {//测试
                return
            }
            if !section!.paging {
                //显示点击选中的内容
                self.setSelectedIndexByPoint(point)
            }
        }
    }
}
