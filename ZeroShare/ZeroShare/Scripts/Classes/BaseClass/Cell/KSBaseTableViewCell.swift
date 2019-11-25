//
//  KSBaseTableViewCell.swift
//  ZeroShare
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

@objc protocol KSTableViewCellDelegate: class {
    @objc optional func tableViewCellCallback(tableViewCell: Any, value: Any?)
}

class KSBaseTableViewCell: UITableViewCell {
    
    /// 代理
    weak var theDelegate: KSTableViewCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //     class func initialize(tableView:UITableView) -> UITableViewCell {
    //        var cell = tableView.dequeueReusableCell(withIdentifier: KSTableViewCellIdentifier)
    //        if cell == nil {
    //            cell = WonBaseTableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: KSTableViewCellIdentifier)
    //        }
    //        return cell as! WonBaseTableViewCell
    //    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeKit()
    }

    /// 初始化数据和视图
    func initializeKit() {
        defaultValue()
        createChildViews()
    }
    
    /// 初始化默认值
    func defaultValue() {
        
    }
    
    /// 创建子控件
    func createChildViews() {
        
    }
    
    /// 配置视图数据
    ///
    /// - Parameter contents: 数据
    func configureContents(contents: Any?) {
        /*
         guard let _contents = contents else {
         return
         }
         */
    }
    
}
