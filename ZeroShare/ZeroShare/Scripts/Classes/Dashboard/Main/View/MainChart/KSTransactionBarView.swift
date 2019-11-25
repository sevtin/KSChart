//
//  KSTransactionBarView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/9/9.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSTransactionBarView: KSBaseView {
    var buyBtn: UIButton!
    var sellBtn: UIButton!
    override func configureDefaultValue() {
        self.backgroundColor     = KS_Const_Color_White
        self.layer.shadowColor   = UIColor.black.cgColor
        self.layer.shadowOffset  = CGSize.init(width: 0, height: 0)
        self.layer.shadowOpacity = 0.2
    }
    
    override func createChildViews() {
        buyBtn  = UIButton.init(title: "ks_app_global_text_buy", font: KS_Const_Font_Normal_18, normalColor: KS_Const_Color_White, highlightedColor: KS_Const_Color_White, bgNormalColor: KS_Const_Color_Chart_Up, bgHighlightedColor: UIColor.ks_hex(0x2F996B))

        sellBtn = UIButton.init(title: "ks_app_global_text_sell", font: KS_Const_Font_Normal_18, normalColor: KS_Const_Color_White, highlightedColor: KS_Const_Color_White, bgNormalColor: KS_Const_Color_Chart_Down, bgHighlightedColor: UIColor.ks_hex(0xCC3B58))
        
        self.addSubview(buyBtn)
        self.addSubview(sellBtn)
        
        buyBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(KS_Const_Point20)
            make.height.equalTo(44)
            make.right.equalTo(self.snp.centerX).offset(-8)
            make.centerY.equalToSuperview()
        }
        sellBtn.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-KS_Const_Point20)
            make.height.equalTo(44)
            make.left.equalTo(self.snp.centerX).offset(8)
            make.centerY.equalToSuperview()
        }
    }

}
