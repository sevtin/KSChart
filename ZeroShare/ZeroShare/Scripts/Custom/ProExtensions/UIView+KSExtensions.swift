//
//  UIView+KSExtensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/26.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

extension UIView {
    func ks_createTableView(target: Any, separatorStyle: UITableViewCell.SeparatorStyle) -> KSTableView {
        let tableView             = KSTableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.dataSource      = target as? UITableViewDataSource
        tableView.delegate        = target as? UITableViewDelegate
        tableView.separatorStyle  = separatorStyle//UITableViewCell.SeparatorStyle.none
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)

        if #available(iOS 11.0, *){
            tableView.contentInsetAdjustmentBehavior  = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
 
        self.addSubview(tableView)
        return tableView
    }
    
    convenience init(color: UIColor?) {
        self.init()
        backgroundColor = color
    }
}
