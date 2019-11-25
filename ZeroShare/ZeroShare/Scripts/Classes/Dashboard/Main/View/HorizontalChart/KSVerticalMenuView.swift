//
//  KSVerticalMenuView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/26.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSVerticalMenuView: KSBaseView {
    var masterTableView:KSTableView!
    var assistTableView:KSTableView!
    
    var masterConfigure: KSListMenuConfigure?
    var assistConfigure: KSListMenuConfigure?
    
    override func configureDefaultValue() {
        
    }
    
    override func createChildViews() {
        masterTableView     = self.ks_createTableView(target: self, separatorStyle: UITableViewCell.SeparatorStyle.none)
        masterTableView.tag = 0
        assistTableView     = self.ks_createTableView(target: self, separatorStyle: UITableViewCell.SeparatorStyle.none)
        assistTableView.tag = 1
        
        masterTableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(KS_Const_Point04)
            make.bottom.equalTo(self.snp.center).offset(-KS_Const_Point40)
            make.left.equalToSuperview().offset(KS_Const_Point04)
            make.right.equalToSuperview().offset(-KS_Const_Point04)
        }
        
        assistTableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.center).offset(KS_Const_Point40)
            make.bottom.equalToSuperview().offset(-KS_Const_Point04)
            make.left.equalToSuperview().offset(KS_Const_Point04)
            make.right.equalToSuperview().offset(-KS_Const_Point04)
        }
    }
}

extension KSVerticalMenuView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return self.masterConfigure?.menus?.count ?? 0
        }
        return self.assistConfigure?.menus?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = KSListMenuCell.initialize(tableView: tableView)
        if tableView.tag == 0 {
            cell.update(menu: self.masterConfigure?.menus?[indexPath.row])
        }
        else{
            cell.update(menu: self.assistConfigure?.menus?[indexPath.row])
        }
        return cell
    }
}
