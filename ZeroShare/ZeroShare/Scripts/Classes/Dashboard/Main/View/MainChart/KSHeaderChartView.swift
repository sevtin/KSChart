//
//  KSHeaderChartView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/21.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSHeaderChartView: KSBaseView {
    
    var timeConfigure: KSTimeMenuConfigure!
    var menuBarView: KSMenuBarView!
    
    override func configureDefaultValue() {
        self.backgroundColor = KS_Const_Color_White
    }
    
    override func createChildViews() {
        self.addSubview(self.indexView)
        self.addSubview(self.funcsView)
        self.addSubview(self.valueView)
        self.valueView.isHidden = true
        self.addSubview(self.chartView)
        
        timeConfigure           = KSTimeMenuConfigure.defaultConfigure()
        
        funcsView.timeBtn.addTarget(self, action: #selector(onTimeBtnClick), for: UIControl.Event.touchUpInside)
        funcsView.taiBtn.addTarget(self, action: #selector(onTaiBtnClick), for: UIControl.Event.touchUpInside)
        funcsView.updateTime(menuInfo: timeConfigure.selectdInfo)
        
        updateDate(timeId: timeConfigure.selectdInfo.ID)
        
        menuBarView             = KSMenuBarView.init(frame: CGRect.init(x: 0, y: 390, width: self.ks_screenWidth(), height: 44))
        self.addSubview(menuBarView)
    }
    //1、顶部数据
    lazy var indexView: KSChartIndexView = {
        let indexView = KSChartIndexView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: 75))
        return indexView
    }()
    //2、功能菜单
    lazy var funcsView: KSChartFuncsView = {
        let funcsView         = KSChartFuncsView.init(frame: CGRect.init(x: 0, y: 70, width: self.frame.width, height: 44))
        funcsView.theDelegate = self
        return funcsView
    }()
    //3、点击k线指标显示
    lazy var valueView: KSChartValueView = {
        let valueView = KSChartValueView.init(frame: CGRect.init(x: 0, y: 70, width: self.frame.width, height: 44))
        return valueView
    }()
    //4、k线图
    lazy var chartView: KSKChartView = {
        let chartView      = KSKChartView.init(frame: CGRect.init(x: 0, y: 114, width: self.frame.width, height: 278))
        chartView.delegate = self
        return chartView
    }()
    //5、时间菜单
    lazy var timeMenuView: KSTimePickerView = {
        let timeMenuView             = KSTimePickerView.init(frame: CGRect.init(x: KS_Const_Point16, y: 114, width: self.frame.width - KS_Const_Point32, height: timeConfigure.kitHeight))
        timeMenuView.delegate        = self
        timeMenuView.triangleCenterX = self.funcsView.convert(self.funcsView.timeBtn.center, to: timeMenuView).x
        timeMenuView.configure       = timeConfigure
        timeMenuView.fillColor       = KS_Const_Color_Menu_Background
        timeMenuView.strokeColor     = UIColor.ks_rgba(192, 192, 192, 1)
        timeMenuView.drawBubble()
        self.addSubview(timeMenuView)
        return timeMenuView
    }()
    //6、指标菜单
    lazy var taiMenuView: KSTaiPickerView = {
        let configure               = KSTaiMenuConfigure.defaultConfigure()
        let taiMenuView             = KSTaiPickerView.init(frame: CGRect.init(x: KS_Const_Point16, y: 114, width: (self.frame.width - KS_Const_Point32), height: configure.kitHeight))
        taiMenuView.delegate        = self
        taiMenuView.triangleCenterX = self.funcsView.convert(self.funcsView.taiBtn.center, to: taiMenuView).x
        taiMenuView.configure       = configure
        taiMenuView.fillColor       = KS_Const_Color_Menu_Background
        taiMenuView.strokeColor     = UIColor.ks_rgba(192, 192, 192, 1)
        taiMenuView.drawBubble()
        self.addSubview(taiMenuView)
        return taiMenuView
    }()
    //7、指标显示和影藏
    @objc func onTimeBtnClick(button: KSButton) {
        if !button.isSelected {
            self.showTimeKit()
        }
        else{
            self.hiddenTimeKit()
        }
    }
    
    @objc func onTaiBtnClick(button: KSButton) {
        if !button.isSelected {
            self.showTaiKit()
        }
        else{
            self.hiddenTaiKit()
        }
    }
    
    func hiddenTaiKit() {
        self.funcsView.updateTai(isSelectd: false)
        self.taiMenuView.hiddenKit()
        
    }
    
    func showTaiKit() {
        self.hiddenTimeKit()
        
        self.taiMenuView.showKit()
        self.funcsView.updateTai(isSelectd: true)
        
    }
    
    func hiddenTimeKit() {
        self.funcsView.timeBtn.isSelected = false
        self.timeMenuView.hiddenKit()
    }
    
    func showTimeKit() {
        self.hiddenTaiKit()
        
        self.timeMenuView.showKit()
        self.funcsView.timeBtn.isSelected = true
    }
    
    func updateDate(timeId:Int) {
        if timeId >= 11 {
            self.chartView.configure.dateFormat = "yyyy-MM-dd"
        }
        else{
            self.chartView.configure.dateFormat = "MM-dd HH:mm"
        }
    }
}

// MARK: - 回调方法
extension KSHeaderChartView: KSKChartViewDelegate, TimePickerViewDelegate, TaiPickerViewDelegate, KSViewDelegate {
    
    // MARK: - KSKChartViewDelegate
    //显示对应数据
    func kchartView(chart: KSKChartView, didSelectAt index: Int, item: KSChartItem) {
        self.valueView.update(value: item)
    }
    
    func kchartViewTouch(chart: KSKChartView) {
        self.hiddenTimeKit()
        self.hiddenTaiKit()
    }
    //十字架影藏显示回调
    func kchartView(chart: KSKChartView, displayCross: Bool) {
        if displayCross {
            self.valueView.showKit()
        }
        else{
            self.valueView.hiddenKit()
        }
    }
    // MARK: - TimePickerViewDelegate
    //切换时间回调
    func timePickerViewCallback(timePickerView: Any, value: KSChartMenuInfo) {
        self.funcsView.updateTime(menuInfo: value)
        KSSingleton.shared.indexConfigure.timeID = value.ID
        self.funcsView.timeBtn.isSelected = false
        updateDate(timeId: value.ID)
        //resetDrawChart()
        self.funcsView.updateTai(isEnabled: KSSingleton.shared.indexConfigure.isChart)
        self.theDelegate?.ksviewCallback?(view: self, data: value, identifier: "KSTimePickerView")
    }
    
    // MARK: - TaiPickerViewDelegate
    //眼睛回调
    func taiPickerViewCallback(taiPickerView: Any, menuGroup: KSTaiMenuGroup, isOpeneye: Bool) {
        self.funcsView.updateTai(menuGroup: menuGroup, isOpeneye: isOpeneye)
        if isOpeneye == false {
            resetDrawChart()
        }
    }
    
    //指标回调
    func taiPickerViewCallback(taiPickerView: Any, menuInfo: KSChartMenuInfo, groupType: KSSectionValueType) {
        self.funcsView.updateTai(menuInfo: menuInfo, groupType: groupType)
        resetDrawChart(groupType: groupType,isAll: true)
    }
    
    //更新K线
    func resetDrawChart(groupType: KSSectionValueType = .assistant, isAll: Bool = false) {
        self.funcsView.updateTai(isEnabled: KSSingleton.shared.indexConfigure.isChart)
        if KSSingleton.shared.indexConfigure.isChart == false {
            self.chartView.chartView.updateSerie(hidden: false, key: KSSeriesKey.timeline, isMasterCandle: false)
        }else{
            self.chartView.chartView.updateSerie(hidden: false, key: self.funcsView.masterSeriesKey, isMasterCandle: KSSingleton.shared.indexConfigure.isChart)
        }
        self.chartView.chartView.updateSerie(hidden: false, key: self.funcsView.assistSeriesKey, isMasterCandle: false, index: 1)
        self.chartView.chartView.refreshChart(isAll: isAll, isDraw: true, isChangeTai: true)
    }
    
    // MARK: - KSViewDelegate
    func ksviewTouche(view: UIView, identifier: String?) {
        self.hiddenTimeKit()
        self.hiddenTaiKit()
    }
}

// MARK: - 更新数据
extension KSHeaderChartView {
    func update(summary: KSSummaryInfo) {
        indexView.update(summary: summary)
    }
    
    func resetKit() {
        indexView.resetKit()
    }
}
