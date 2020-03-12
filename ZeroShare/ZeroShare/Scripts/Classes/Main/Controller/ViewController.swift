//
//  ViewController.swift
//  ZeroShare
//
//  Created by saeipi on 2019/9/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

//======================================================================
// MARK: - 1、常量/静态变量
//======================================================================

class ViewController: KSBaseViewController, UITableViewDataSource, UITableViewDelegate {

    //======================================================================
    // MARK: - 2、属性
    //======================================================================
    // MARK: - 2.1、引用类型/值类型
    
    // MARK: - 2.2、UIKit
    var tableView: KSTableView?
    
    //======================================================================
    // MARK: - 3、系统初始化方法/系统生命周期方法
    //======================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCtrl()
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
    func initializeCtrl() {
        defaultValue()
        createChildViews()
    }
    
    /// 初始化默认值
    func defaultValue() {
        
    }
    //======================================================================
    // MARK: - 7、系统代理方法
    //======================================================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = KSLineChartCell.initialize(tableView: tableView)
        cell.textLabel?.text = self.datas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        enterBinanceController()
        return
        /*
        switch indexPath.row {
        case 0:
            //enterLineChartController()
        case 1:
            enterBinanceController()
        case 2:
            //enterShareController()
            break
        default:
            break
        }
         */
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    //======================================================================
    // MARK: - 8、自定义代理方法
    //======================================================================
    
    //======================================================================
    // MARK: - 9、创建视图方法
    //======================================================================
    /// 创建子控件
    func createChildViews() {
        tableView        = self.createTableView(target: self, separatorStyle: UITableViewCell.SeparatorStyle.none)
        tableView?.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().offset(self.navigationHeight())
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.tabBarHeight())
        })
    }
    //======================================================================
    // MARK: - 10、按钮点击事件
    //======================================================================
    
    //======================================================================
    // MARK: - 11、辅助方法
    //======================================================================
    
    //======================================================================
    // MARK: - 12、控制器跳转
    //======================================================================
    
    func enterLineChartController() {
        let ctrl = KSDashboardController.init()
        ctrl.update(market: "eth/btc")
        self.pushViewController(ctrl: ctrl)
    }
    
    func enterBinanceController() {
        let ctrl = KSBinanceController.init()
        ctrl.update(market: "eth/btc")
        self.pushViewController(ctrl: ctrl)
    }
    func enterShareController() {
        let ctrl = KSMyShareController.init()
        self.pushViewController(ctrl: ctrl)
    }
    //======================================================================
    // MARK: - 13、网络请求
    //======================================================================
    
    //======================================================================
    // MARK: - 14、懒加载
    //======================================================================
    lazy var datas : [String] = {
        //let datas = ["MyChart","Binance","Share"]
        return ["Binance"]
    }()
    //======================================================================
    // MARK: - 15、TEST
    //======================================================================

}

