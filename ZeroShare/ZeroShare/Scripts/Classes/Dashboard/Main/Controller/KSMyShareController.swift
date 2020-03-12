//
//  KSMyShareController.swift
//  ZeroShare
//
//  Created by saeipi on 2019/9/24.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit
import SwiftyJSON

//======================================================================
// MARK: - 1、常量/静态变量
//======================================================================

class KSMyShareController: KSBaseViewController {

    //======================================================================
    // MARK: - 2、属性
    //======================================================================
    // MARK: - 2.1、引用类型/值类型
    private var timer: Timer?
    private var currentIndex: Int = 0
    private var candles: [KSChartItem] = [KSChartItem]()
    // MARK: - 2.2、UIKit
    
    //======================================================================
    // MARK: - 3、系统初始化方法/系统生命周期方法
    //======================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCtrl()
        
        readCandles()
        startTimer()
    }
    
    deinit {
        timerInvalidate()
        print("------ KSMyShareController deinit ------")
    }
    //======================================================================
    // MARK: - 4、虚方法
    //======================================================================
    
    //======================================================================
    // MARK: - 5、重写/调用父类方法
    //======================================================================
    
    //======================================================================
    // MARK: - 6、功能初始化方法
    //======================================================================
    /// 初始化数据和视图
    private func initializeCtrl() {
        defaultValue()
        createChildViews()
    }
    
    /// 初始化默认值
    private func defaultValue() {
        
    }
    //======================================================================
    // MARK: - 7、系统代理方法
    //======================================================================
    
    //======================================================================
    // MARK: - 8、自定义代理方法
    //======================================================================
    
    //======================================================================
    // MARK: - 9、创建视图方法
    //======================================================================
    /// 创建子控件
    private func createChildViews() {
        
    }
    //======================================================================
    // MARK: - 10、按钮点击事件
    //======================================================================
    
    //======================================================================
    // MARK: - 11、辅助方法
    //======================================================================
    private func readCandles() {

        let fileData = KSFileMgr.readLocalData(fileName: "ethbtc_minute", type: "txt")
        let jsons    = JSON(fileData!)
        
        var candles: [KSChartItem] = [KSChartItem]()
        for json in jsons.arrayValue {
            let info        = KSChartItem()
            info.time       = json[0].intValue/1000// 开盘时间
            //json["k"]["T"]// 这根K线的结束时间
            info.open   = json[1].stringValue// 开盘价
            info.high   = json[2].stringValue// 最高价
            info.low    = json[3].stringValue// 最低价
            info.close  = json[4].stringValue// 收盘价(当前K线未结束的即为最新价)
            info.volume = json[5].stringValue// 成交量
            candles.append(info)
        }

        self.chartView.klineData.removeAll()
        self.candles = candles
        //self.chartView.klineData = candles
        //self.chartView.chartView.refreshChart(isAll: true, isDraw: true)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(updataChartData), userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    func timerInvalidate() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updataChartData() {
        if currentIndex > 100 {
            timerInvalidate()
            return
        }
        if currentIndex < self.candles.count {
            self.chartView.klineData.append(self.candles[currentIndex])
            currentIndex += 1
            self.chartView.chartView.refreshChart(isAll: false, isDraw: true)
        }
        else{
            currentIndex = 0
        }
    }
    
    //======================================================================
    // MARK: - 12、控制器跳转
    //======================================================================
    
    //======================================================================
    // MARK: - 13、网络请求
    //======================================================================
    
    //======================================================================
    // MARK: - 14、懒加载
    //======================================================================
    lazy var chartView: KSKChartView = {
        let chartView = KSKChartView.init(frame: CGRect.init(x: 0, y: 100, width: ks_screenWidth(), height: 360))
        self.view.addSubview(chartView)
        chartView.chartView.updateSerie(hidden: false, key: KSSeriesKey.ma, isMasterCandle: true)
        chartView.chartView.updateSerie(hidden: false, key: KSSeriesKey.boll, isMasterCandle: false, index: 1)
        chartView.backgroundColor = UIColor.white
        return chartView
    }()
    //======================================================================
    // MARK: - 15、TEST
    //======================================================================

}
