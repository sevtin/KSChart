//
//  KSListMenuView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/26.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSListMenuView: KSBaseView {
    var tableView: UITableView!
    var configure: KSListMenuConfigure?

    /*
     override init(frame: CGRect) {
     super.init(frame: frame)
     initializeView()
     }
     
     func initializeView() {
     configureDefaultValue()
     createChildViews()
     }
     
     required init?(coder aDecoder: NSCoder) {
     fatalError("init(coder:) has not been implemented")
     }
     */
    
    override func configureDefaultValue() {
        
    }
    
    override func createChildViews() {
        
        tableView = self.ks_createTableView(target: self, separatorStyle: UITableViewCell.SeparatorStyle.none)
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(10)
           
        }
    }
}

extension KSListMenuView: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.configure?.menus?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = KSListMenuCell.initialize(tableView: tableView)
        cell.update(menu: self.configure?.menus?[indexPath.row])
        return UITableViewCell.init()
    }
}

let listMenuCellIdentifier = "KSListMenuCellIdentifier"
class KSListMenuCell: KSBaseTableViewCell {
    var menuLabel:UILabel!
    class func initialize(tableView:UITableView) -> KSListMenuCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: listMenuCellIdentifier)
        if cell == nil {
            cell = KSListMenuCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: listMenuCellIdentifier)
        }
        return cell as! KSListMenuCell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 创建子控件
    override func createChildViews() {
        menuLabel = UILabel.init(textFont: KS_Const_Font_Normal_14, alignment: NSTextAlignment.center)
        self.addSubview(menuLabel)
        menuLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func update(menu:KSListMenuInfo?) {
        menuLabel.text = menu?.displayText
        if menu?.isSelectd ?? false {
            menuLabel.textColor = KS_Const_Color_Menu_Text_Selectd
        }
        else{
            menuLabel.textColor = KS_Const_Color_Chart_Ink
        }
    }
    
    /// 配置视图数据
    ///
    /// - Parameter contents: 数据
    override func configureContents(contents: Any?) {
        /*
         guard let _contents = contents else {
         return
         }
         */
    }
    
}


class KSListMenuConfigure: NSObject {
    var cellHeight: CGFloat = 40
    var menus: [KSListMenuInfo]?
}

class KSListMenuInfo: NSObject {
    var displayText: String = ""
    var identifier: String  = ""
    var isSelectd: Bool     = false
}
