//
//  KSMarketTradeController.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/28.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

//======================================================================
// MARK: - 1、常量/静态变量
//======================================================================

class KSMarketTradeController: KSDashboardChildController {

    //======================================================================
    // MARK: - 2、属性
    //======================================================================
    // MARK: - 2.1、引用类型/值类型
    var configure: KSDashboardChildConfigure!
    var details: [KSTradeDetail]?

    // MARK: - 2.2、UIKit
    var tableView: UITableView!
    var headerView: KSDoubleLabelView!
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
        tableView = self.createTableView(target: self, separatorStyle: UITableViewCell.SeparatorStyle.none)
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if isBar {
                make.bottom.equalToSuperview()//.offset(-KS_Const_Point70)
            }
            else{
                make.bottom.equalToSuperview()
            }
        })
        
        headerView = KSDoubleLabelView.init(textColor: UIColor.ks_rgba(218, 225, 237),
                                            textFont: KS_Const_Font_Normal_12,
                                            alignments: [NSTextAlignment.left, NSTextAlignment.center, NSTextAlignment.right, NSTextAlignment.right],
                                            count: 4,
                                            widthScales: [0.23,0.13,0.32,0.32],
                                            margin: KS_Const_Point16,
                                            padding: KS_Const_Point04)
        headerView.frame = CGRect.init(x: 0, y: 0, width: self.ks_screenWidth(), height: KS_Const_Point40)
        updateHeader()
        
        headerView.backgroundColor = KS_Const_Color_White
        tableView?.tableHeaderView = headerView
    }
    //======================================================================
    // MARK: - 10、按钮点击事件
    //======================================================================
    
    //======================================================================
    // MARK: - 11、辅助方法
    //======================================================================
    private func updateHeader() {
        headerView.update(texts: [String.ks_localizde("ks_app_global_text_time"),
                                  String.ks_localizde("ks_app_global_text_type"),
                                  String.init(format: String.ks_localizde("ks_app_global_text_price_currency_unit"), configure.bid_currency.uppercased()),
                                  String.init(format: String.ks_localizde("ks_app_global_text_amount_currency_unit"), configure.ask_currency.uppercased())])
    }
    
    func reloadData() {
        tableView.reloadData()
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
    
    //======================================================================
    // MARK: - 15、TEST
    //======================================================================

}

extension KSMarketTradeController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = KSMarketTradeCell.initialize(tableView: tableView)
        cell.update(detail: details![indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 28
    }
}

extension KSMarketTradeController {
    //更新数据
    func update(details: [KSTradeDetail], configure: KSDashboardConfigure) {
        if (self.configure.ask_currency != configure.ask_currency) || (self.configure.bid_currency != configure.bid_currency) {
            self.configure.ask_currency = configure.ask_currency
            self.configure.bid_currency = configure.bid_currency
            updateHeader()
        }
        self.details?.removeAll()
        self.details = details
        if configure.pagerIndex != 1 {
            return
        }
        self.tableView.reloadData()
    }
    
    func resetKit() {
        self.details?.removeAll()
        self.tableView.reloadData()
    }
}
