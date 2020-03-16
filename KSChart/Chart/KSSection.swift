//
//  ZeroShare
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

/// 分区图类型
///
/// - master: 主图
/// - assistant: 副图
enum KSSectionValueType {
    case master
    case assistant
}

/// K线的区域
class KSSection: NSObject {
    /// MARK: - 成员变量
    var upColor: UIColor              = UIColor.green//升的颜色
    var downColor: UIColor            = UIColor.red//跌的颜色
    var titleColor: UIColor           = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)//文字颜色
    var labelFont                     = UIFont.systemFont(ofSize: 10)
    var valueType: KSSectionValueType = KSSectionValueType.master
    var key                           = ""
    var name: String                  = ""//区域的名称
    var hidden: Bool                  = false
    var paging: Bool                  = false
    var selectedIndex: Int            = 0//选择的指标下标
    var padding: UIEdgeInsets         = UIEdgeInsets.zero
    var series                        = [KSSeries]()//每个分区包含多组系列，每个系列包含多个点线模型
    var title: String                 = ""//标题
    var titleShowOutSide: Bool        = false//标题是否显示在外面
    var showTitle: Bool               = true//是否显示标题文本
    var decimal: Int                  = 2//小数位的长度
    var ratios: Int                   = 0//所占区域比例
    var fixHeight: CGFloat            = 0//固定高度，为0则通过ratio计算高度
    var frame: CGRect                 = CGRect.zero
    var yAxis: KSYAxis                = KSYAxis()//Y轴参数
    var xAxis: KSXAxis                = KSXAxis()//X轴参数
    var backgroundColor: UIColor      = UIColor.black
    var index: Int                    = 0//分组
    var titleLayer: KSShapeLayer      = KSShapeLayer()//显示顶部标题内容的层
    var sectionLayer: KSShapeLayer    = KSShapeLayer()//分区的绘图层
    var titleView: UIView? //用户自定义的View
    var tai: String                   = ""//当前技术指标

    /// 初始化分区
    ///
    /// - Parameters:
    ///   - valueType: 分区类型
    ///   - key:
    convenience init(valueType: KSSectionValueType, key: String = "") {
        self.init()
        self.valueType = valueType
        self.key       = key
    }
}

// MARK: - 内部方法
extension KSSection {
    
    /// 清空图表的子图层
    func removeLayerView() {
        _ = self.sectionLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.sectionLayer.sublayers?.removeAll()
        
        _ = self.titleLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.titleLayer.sublayers?.removeAll()
    }
    
    /// 建立Y轴左边对象，由起始位到结束位
    ///
    /// - Parameters:
    ///   - model:
    ///   - startIndex:
    ///   - endIndex:
    func buildYAxisPerModel(_ model: KSChartModel, startIndex: Int, endIndex: Int) {
        let datas = model.datas
        if datas.count == 0 {
            return//没有数据返回
        }
        
        if !self.yAxis.isUsed {
            self.yAxis.decimal = self.decimal
            self.yAxis.max     = 0
            self.yAxis.min     = CGFloat.greatestFiniteMagnitude
            self.yAxis.isUsed  = true
        }
        
        for i in stride(from: startIndex, to: endIndex, by: 1) {
            
            let item = datas[i]
            
            switch model {
            case is KSCandleModel://蜡烛图
                
                let high = item.highPrice
                let low = item.lowPrice
                
                //判断数据集合的每个价格，把最大值和最少设置到y轴对象中
                if high > self.yAxis.max {
                    self.yAxis.max = high
                }
                if low < self.yAxis.min {
                    self.yAxis.min = low
                }
                
            case is KSLineModel, is KSBarModel:
                
                let value = model[i].value
                
                if value == nil{
                    continue//无法计算的值不绘画
                }
                
                //判断数据集合的每个价格，把最大值和最少设置到y轴对象中
                if value! > self.yAxis.max {
                    self.yAxis.max = value!
                }
                if value! < self.yAxis.min {
                    self.yAxis.min = value!
                }
                
            case is KSColumnModel://成交量
                
                let value = item.vol
                
                //判断数据集合的每个价格，把最大值和最少设置到y轴对象中
                if value > self.yAxis.max {
                    self.yAxis.max = value
                }
                if value < self.yAxis.min {
                    self.yAxis.min = value
                }
            case is KSBollModel, is KSTimeChartModel: //新增is KSBollModel[20190807],新增is KSTimeChartModel[20190829]
                let high = item.highPrice
                let low = item.lowPrice
                
                //判断数据集合的每个价格，把最大值和最少设置到y轴对象中
                if high > self.yAxis.max {
                    self.yAxis.max = high
                }
                if low < self.yAxis.min {
                    self.yAxis.min = low
                }
            case is KSRoundModel:
                let value = model[i].value
                
                if value == nil{
                    continue//无法计算的值不绘画
                }
                //判断数据集合的每个价格，把最大值和最少设置到y轴对象中
                if value! > self.yAxis.max {
                    self.yAxis.max = value!
                }
                if value! < self.yAxis.min {
                    self.yAxis.min = value!
                }
            default:
                let value = model[i].value
                
                if value == nil{
                    continue//无法计算的值不绘画
                }
                //判断数据集合的每个价格，把最大值和最少设置到y轴对象中
                if value! > self.yAxis.max {
                    self.yAxis.max = value!
                }
                if value! < self.yAxis.min {
                    self.yAxis.min = value!
                }
            }
        }
    }
    
    /// 绘制header上的标题信息
    ///
    /// - Parameter title: 标题内容
    func drawTitleForHeader(title: NSAttributedString) {

        if self.showTitle == false {
            return
        }
        
        _ = self.titleLayer.sublayers?.map { $0.removeFromSuperlayer() }
        self.titleLayer.sublayers?.removeAll()

        var yPos: CGFloat           = 0
        var containerWidth: CGFloat = 0
        let textSize                = title.string.ks_sizeWithConstrained(self.labelFont, constraintRect: CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))

        if titleShowOutSide {
            yPos           = self.frame.origin.y - textSize.height - 4
            containerWidth = self.frame.width
        } else {
            yPos           = self.frame.origin.y + 2
            containerWidth = self.frame.width - self.padding.left - self.padding.right
        }

        let startX                = self.frame.origin.x + self.padding.left + 2

        let point                 = CGPoint(x: startX, y: yPos)

        let titleText             = KSTextLayer()
        titleText.frame           = CGRect(origin: point, size: CGSize(width: containerWidth, height: textSize.height + 20))
        titleText.string          = title
        titleText.fontSize        = self.labelFont.pointSize
        //titleText.foregroundColor =  self.titleColor.cgColor
        titleText.backgroundColor = UIColor.clear.cgColor
        titleText.contentsScale   = UIScreen.main.scale
        titleText.isWrapped       = true

        self.titleLayer.addSublayer(titleText)
    }
    
    //切换到下一个系列显示
    func nextPage() {
        if(self.selectedIndex < self.series.count - 1){
            self.selectedIndex += 1
        } else {
            self.selectedIndex = 0
        }
        tai = series[self.selectedIndex].key
    }
    
    func updateTai(_tai: String) {
        self.tai = _tai
        for i in 0 ..< series.count{
            if _tai == series[i].key {
                self.selectedIndex = i
            }
        }
    }
}

// MARK: - 公开方法
extension KSSection {
    
    /// 建立Y轴的数值范围
    ///
    /// - Parameters:
    ///   - startIndex: 计算范围的开始数据点
    ///   - endIndex: 计算范围的结束数据点
    ///   - datas: 数据集合
    func buildYAxis(startIndex: Int, endIndex: Int, datas: [KSChartItem]) {
        self.yAxis.isUsed   = false
        var baseValueSticky = false
        var symmetrical     = false
        if self.paging {//如果分页，计算当前选中的系列作为坐标系的数据源
            //建立分区每条线的坐标系
            let serie       = self.series[self.selectedIndex]
            baseValueSticky = serie.baseValueSticky
            symmetrical     = serie.symmetrical
            for serieModel in serie.chartModels {
                serieModel.datas = datas
                self.buildYAxisPerModel(serieModel,
                                        startIndex: startIndex,
                                        endIndex: endIndex)
            }
        } else {
            for serie in self.series {//不分页，计算所有系列作为坐标系的数据源
                //隐藏的不计算
                if serie.hidden {
                    continue
                }
                
                baseValueSticky = serie.baseValueSticky
                symmetrical     = serie.symmetrical
                for serieModel in serie.chartModels {
                    serieModel.datas = datas
                    self.buildYAxisPerModel(serieModel,
                                            startIndex: startIndex,
                                            endIndex: endIndex)
                }
            }
        }
        
        //让边界溢出些，这样图表不会占满屏幕
        //self.yAxis.max += (self.yAxis.max - self.yAxis.min) * self.yAxis.ext
        //self.yAxis.min -= (self.yAxis.max - self.yAxis.min) * self.yAxis.ext
        
        if !baseValueSticky {//不使用固定基值
            if self.yAxis.max >= 0 && self.yAxis.min >= 0 {
                self.yAxis.baseValue = self.yAxis.min
            } else if self.yAxis.max < 0 && self.yAxis.min < 0 {
                self.yAxis.baseValue = self.yAxis.max
            } else {
                self.yAxis.baseValue = 0
            }
        } else {//使用固定基值
            if self.yAxis.baseValue < self.yAxis.min {
                self.yAxis.min = self.yAxis.baseValue
            }
            
            if self.yAxis.baseValue > self.yAxis.max {
                self.yAxis.max = self.yAxis.baseValue
            }
        }
        
        //如果使用水平对称显示y轴，基本基值计算上下的边界值
        if symmetrical {
            if self.yAxis.baseValue > self.yAxis.max {
                self.yAxis.max = self.yAxis.baseValue + (self.yAxis.baseValue - self.yAxis.min)
            } else if self.yAxis.baseValue < self.yAxis.min {
                self.yAxis.min =  self.yAxis.baseValue - (self.yAxis.max - self.yAxis.baseValue)
            } else {
                if (self.yAxis.max - self.yAxis.baseValue) > (self.yAxis.baseValue - self.yAxis.min) {
                    self.yAxis.min = self.yAxis.baseValue - (self.yAxis.max - self.yAxis.baseValue)
                } else {
                    self.yAxis.max = self.yAxis.baseValue + (self.yAxis.baseValue - self.yAxis.min)
                }
            }
        }
    }
    
    /// 获取y轴上标签数值对应在坐标系中的y值
    ///
    /// - Parameter val: 标签值
    /// - Returns: 坐标系中实际的y值
    func getLocalY(_ val: CGFloat) -> CGFloat {
        /*
        //SAR容错
        if val > self.yAxis.max {
            self.yAxis.max = val
        }
        if val < self.yAxis.min {
            self.yAxis.min = val
        }
        */
        
        let max = self.yAxis.max
        let min = self.yAxis.min
        if (max == min) {
            return self.frame.size.height + self.frame.origin.y - self.padding.bottom
        }
        
        /*
         计算公式：
         1、y轴有值的区间高度 = 整个分区高度-（paddingTop+paddingBottom）:self.frame.size.height - self.padding.top - self.padding.bottom
         2、当前y值所在位置的比例 =（当前值 - y最小值）/（y最大值 - y最小值）:(val - min) / (max - min)
         3、当前y值的实际的相对y轴有值的区间的高度 = 当前y值所在位置的比例 * y轴有值的区间高度:2 * 1
         4、当前y值的实际坐标 = 分区高度 + 分区y坐标 - paddingBottom - 当前y值的实际的相对y轴有值的区间的高度:
         */
        let baseY = self.frame.size.height + self.frame.origin.y - self.padding.bottom - (self.frame.size.height - self.padding.top - self.padding.bottom) * (val - min) / (max - min)
        return baseY
    }
    
    /// 获取坐标系中y坐标对应的y值
    ///
    /// - Parameter y:
    /// - Returns:
    func getRawValue(_ y: CGFloat) -> CGFloat {
        let max = self.yAxis.max
        let min = self.yAxis.min
        
        let ymax = self.getLocalY(self.yAxis.min)       //y最大值对应y轴上的最高点，则最小值
        let ymin = self.getLocalY(self.yAxis.max)       //y最小值对应y轴上的最低点，则最大值
        
        if (max == min) {
            return 0
        }
        
        let value = (y - ymax) / (ymin - ymax) * (max - min) + min
        
        return value
    }
    
    /// 画分区的标题
    ///
    /// - Parameter chartSelectedIndex:
    func drawTitle(_ chartSelectedIndex: Int) {
        
        guard self.showTitle else {
            return
        }
        
        if chartSelectedIndex == -1 {
            return//没有数据返回
        }
        
        if self.paging {//如果分页
            let series = self.series[self.selectedIndex]
            if let attributes = self.getTitleAttributesByIndex(chartSelectedIndex, series: series) {
                self.setHeader(titles: attributes)
            }
        } else {
            var titleAttr = [(title: String, color: UIColor)]()
            for serie in self.series {//不分页
                if let attributes = self.getTitleAttributesByIndex(chartSelectedIndex, series: serie) {
                    titleAttr.append(contentsOf: attributes)
                }
            }
            self.setHeader(titles: titleAttr)
        }
    }
    
    
    /// 添加用户自定义的View层到主页面
    ///
    /// - Parameter view: 用户自定义view
    func addCustomView(_ view: UIView, inView mainView: UIView) {
        
        if self.titleView !== view {
            
            //移除以前的view
            self.titleView?.removeFromSuperview()
            self.titleView              = nil

            var yPos: CGFloat           = 0
            var containerWidth: CGFloat = 0
            if titleShowOutSide {
                yPos           = self.frame.origin.y - self.padding.top
                containerWidth = self.frame.width
            } else {
                yPos           = self.frame.origin.y
                containerWidth = self.frame.width - self.padding.left - self.padding.right
            }
            
            let startX       = self.frame.origin.x + self.padding.left
            containerWidth   = self.frame.width - self.padding.left - self.padding.right

            var frame        = view.frame
            frame.origin.x   = startX
            frame.origin.y   = yPos
            frame.size.width = containerWidth
            view.frame       = frame

            self.titleView   = view
            mainView.addSubview(view)
        }
        mainView.bringSubviewToFront(self.titleView!)
    }
    
    /// 设置分区头部文本显示内容
    ///
    /// - Parameters:
    ///   - titles: 文本内容及颜色元组
    func setHeader(titles: [(title: String, color: UIColor)])  {
        
        var start = 0
        let titleString = NSMutableAttributedString()
        for (title, color) in titles {
            titleString.append(NSAttributedString(string: title))
            let range          = NSMakeRange(start, title.ks_length)
            let colorAttribute = [NSAttributedString.Key.foregroundColor: color]
            titleString.addAttributes(colorAttribute, range: range)
            start              += title.ks_length
        }
        self.drawTitleForHeader(title: titleString)
    }
    
    /// 根据seriesKey获取线段的数值标题
    ///
    func getTitleAttributesByIndex(_ chartSelectedIndex: Int, seriesKey: String) -> [(title: String, color: UIColor)]? {
        guard let series = self.getSeries(key: seriesKey) else {
            return nil
        }
        return self.getTitleAttributesByIndex(chartSelectedIndex, series: series)
    }
    
    /// 获取标题属性元组
    ///
    /// - Parameters:
    ///   - chartSelectedIndex: 图表选中位置
    ///   - series: 线
    /// - Returns: 标题属性
    func getTitleAttributesByIndex(_ chartSelectedIndex: Int, series: KSSeries) -> [(title: String, color: UIColor)]? {
        
        if series.hidden {
            return nil
        }
        
        guard series.showTitle else {
            return nil
        }
        
        if chartSelectedIndex == -1 {
            return nil//没有数据返回
        }
        
        var titleAttr = [(title: String, color: UIColor)]()
        
        if !series.title.isEmpty {
            let seriesTitle = series.title + "  "
            titleAttr.append((title: seriesTitle, color: self.titleColor))
        }
        
        for model in series.chartModels {
            var title = ""
            var textColor: UIColor
            let item  = model[chartSelectedIndex]
            switch model {
            case is KSCandleModel:
                if model.key != KSSeriesKey.candle {
                    continue//不限蜡烛柱
                }
                
                //振幅
                var amplitude: CGFloat = 0
                if item.openPrice > 0 {
                    amplitude = (item.closePrice - item.openPrice) / item.openPrice * 100
                }
                
                title += NSLocalizedString("O", comment: "") + ": " +
                    item.openPrice.ks_toString(maximum: self.decimal) + "  "   //开始
                title += NSLocalizedString("H", comment: "") + ": " +
                    item.highPrice.ks_toString(maximum: self.decimal) + "  "   //最高
                title += NSLocalizedString("L", comment: "") + ": " +
                    item.lowPrice.ks_toString(maximum: self.decimal) + "  "    //最低
                title += NSLocalizedString("C", comment: "") + ": " +
                    item.closePrice.ks_toString(maximum: self.decimal) + "  "  //收市
                title += NSLocalizedString("R", comment: "") + ": " +
                    amplitude.ks_toString(maximum: self.decimal) + "%   "      //振幅
                
            case is KSColumnModel:
                if model.key != KSSeriesKey.volume {
                    continue  //不是量线
                }
                title += model.title + ": " + item.vol.ks_toString(maximum: self.decimal) + "  "
            case is KSBollModel: break
            case is KSTimeChartModel: break
            default:
                if item.value != nil {
                    title += model.title + ": " + item.value!.ks_toString(maximum: self.decimal) + "  "
                }  else {
                    title += model.title + ": --  "
                }
            }
            
            if model.useTitleColor {    //是否用标题颜色
                textColor = model.titleColor
            } else {
                switch item.trend {
                case .up, .equal:
                    textColor = model.upStyle.color
                case .down:
                    textColor = model.downStyle.color
                }
            }
            titleAttr.append((title: title, color: textColor))
        }
        return titleAttr
    }
    
    /// 查找线段对象
    ///
    /// - Parameter key: 线段唯一key
    /// - Returns: 线段对象
    func getSeries(key: String) -> KSSeries? {
        var series: KSSeries?
        for s in self.series {
            if s.key == key {
                series = s
                break
            }
        }
        return series
    }
    
    /// 删除线段
    ///
    /// - Parameter key: 线段主键名
    func removeSeries(key: String) {
        for (index, s) in self.series.enumerated() {
            if s.key == key {
                self.series.remove(at: index)
                break
            }
        }
    }
}
