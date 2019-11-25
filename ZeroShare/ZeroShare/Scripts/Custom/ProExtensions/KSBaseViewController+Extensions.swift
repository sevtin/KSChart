//
//  KSBaseViewController+Extensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import Foundation
import UIKit
extension KSBaseViewController {
    func presentViewController(ctrl: Any) {
        self.present(ctrl as! UIViewController, animated: true, completion: nil)
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func pushViewController(ctrl: Any) {
        self.navigationController?.pushViewController(ctrl as! UIViewController, animated: true)
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func popToRoot() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func createTableView(target: UIViewController, separatorStyle: UITableViewCell.SeparatorStyle) -> KSTableView {
        let tableView                             = KSTableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.dataSource                      = target as? UITableViewDataSource
        tableView.delegate                        = target as? UITableViewDelegate
        tableView.separatorStyle                  = separatorStyle//UITableViewCell.SeparatorStyle.none
        tableView.backgroundColor                 = UIColor.clear
        
        tableView.tableFooterView                 = UIView.init(frame: CGRect.zero)
        //tableView.separatorInset                  = UIEdgeInsets.init(top: 0, left: 15, bottom: 0, right: 0)
        //tableView.separatorColor                  = UIColor.lightGray
        
        if #available(iOS 11.0, *){
            tableView.contentInsetAdjustmentBehavior  = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        else{
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.addSubview(tableView)
        return tableView
    }
}
