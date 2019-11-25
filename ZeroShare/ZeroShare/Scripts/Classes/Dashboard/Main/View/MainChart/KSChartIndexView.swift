//
//  KSChartIndexView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSChartIndexView: KSBaseView {

    var priceLabel: UILabel!
    var priceChangeLabel: UILabel!
    //var summary: KSSummaryInfo?
    
    //var changePercentLabel: UILabel!

    override func createChildViews() {
        priceLabel               = UILabel.init()
        priceLabel.numberOfLines = 1
        priceLabel.text          = "--"
        priceChangeLabel         = UILabel.init(textFont: KS_Const_Font_Normal_14, alignment: NSTextAlignment.left)
        priceChangeLabel.text    = "--"
        //changePercentLabel      = UILabel.init(textFont: KS_Const_Font_Normal_14, alignment: NSTextAlignment.left)
        //changePercentLabel.text = "--"
        self.addSubview(priceLabel)
        self.addSubview(priceChangeLabel)
        //self.addSubview(changePercentLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(KS_Const_Point10)
            make.left.equalToSuperview().offset(KS_Const_Point16)
            make.right.equalToSuperview().offset(-146)
            make.height.equalTo(38)
        }
        priceChangeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel.snp.left)
            make.right.equalTo(priceLabel.snp.right)
            make.top.equalTo(priceLabel.snp.bottom)
            make.height.equalTo(KS_Const_Point18)
            make.width.equalTo(KS_Const_Point100)
        }
        /*
        changePercentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceChangeLabel.snp.right)
            make.top.equalTo(priceLabel.snp.bottom)
            make.height.equalTo(KS_Const_Point18)
            make.width.equalTo(KS_Const_Point60)
        }
        */
        self.priceIndexView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-KS_Const_Point16)
            make.height.equalTo(KS_Const_Point60)
            make.width.equalTo(130)
            make.centerY.equalToSuperview()
        }
    }
    
    lazy var priceIndexView: KSPriceIndexView = {
        let priceIndexView = KSPriceIndexView.init()
        self.addSubview(priceIndexView)
        return priceIndexView
    }()
}

// MARK: - 更新数据
extension KSChartIndexView {
    func update(summary: KSSummaryInfo) {
        let textColor = summary.displayColor(current: summary.closePrice, yester: summary.openPrice)
        var font      = KS_Const_Font_Normal_27
        let textCount = summary.close.count + summary.localPrice.count
        if textCount >= 20 {
            font = KS_Const_Font_Normal_14
        }
        else if textCount > 16 {
            font = KS_Const_Font_Normal_18
        }
        priceLabel.attributedText  = String.ks_attribute(frontText: summary.close, frontFont: font, frontColor: textColor, behindText: "≈$"+summary.localPrice, behindFont: KS_Const_Font_Normal_14, behindColor: KS_Const_Color_Chart_Ink)
        priceChangeLabel.text      = summary.differencePrice + "  " + summary.percentage
        if summary.change >= 0  {
            priceChangeLabel.text = "+" + (priceChangeLabel.text ?? "")
        }
        priceChangeLabel.textColor = (summary.change >= 0) ? KS_Const_Color_Chart_Up : KS_Const_Color_Chart_Down
        priceIndexView.update(summary: summary)
    }
    
    func resetKit() {
        priceLabel.attributedText       = String.ks_attributed(text: "--", color: KS_Const_Color_Chart_Ink)
        priceChangeLabel.attributedText = String.ks_attributed(text: "--", color: KS_Const_Color_Chart_Ink)
        priceIndexView.resetKit()
    }
}
