//
//  KSChartMenuCell.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSChartMenuCell: UICollectionViewCell {

    var textLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createChildViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 创建子控件
    private func createChildViews() {
        self.backgroundColor = UIColor.clear
        textLabel            = UILabel.init(textFont: KS_Const_Font_Normal_14, alignment: NSTextAlignment.center)
        self.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func updateMenu(info: KSChartMenuInfo?) {
        textLabel.text = info?.title
        if info?.isSelectd ?? false {
            textLabel.textColor = KS_Const_Color_Menu_Text_Selectd
        }
        else{
            textLabel.textColor = KS_Const_Color_Chart_Ink
        }
        textLabel.textAlignment = info?.textAlignment ?? .center
    }
}

class KSChartMenuInfo: NSObject {
    var displayText: String = "" {
        didSet {
            title = String.ks_localizde(oldValue)
        }
    }
    var title: String                  = ""
    var identifier: String             = ""
    var ID: Int                        = 0
    var textAlignment: NSTextAlignment = .center
    var isSelectd: Bool                = false
    var section: Int                   = 0
    var isFlag: Bool                   = false
}
