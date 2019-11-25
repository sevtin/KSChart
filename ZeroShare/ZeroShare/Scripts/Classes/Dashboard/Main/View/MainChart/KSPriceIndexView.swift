//
//  KSPriceIndexView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/28.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSPriceIndexView: KSBaseView {
    private var highView:KSTwinsLabelView!
    private var lowView:KSTwinsLabelView!
    private var volView:KSTwinsLabelView!
    override func createChildViews() {
        let leftColor  = KS_Const_Color_Chart_LightBlack_Text
        let rightColor = KS_Const_Color_Chart_DarkBlack_Text
        
        highView       = KSTwinsLabelView.init(leftText: "ks_app_global_text_24h_high",
                                               rightText: "--",
                                               leftColor: leftColor,
                                               rightColor: rightColor,
                                               leftFont: KS_Const_Font_Normal_12,
                                               rightFont: KS_Const_Font_Normal_12,
                                               leftMargin: 0,
                                               rightMargin: 0,
                                               leftAlignment: NSTextAlignment.right,
                                               rightAlignment: NSTextAlignment.right,
                                               leftWidth: KS_Const_Point50,
                                               rightWidth: KS_Const_Point100)
        
        lowView        = KSTwinsLabelView.init(leftText: "ks_app_global_text_24h_low",
                                               rightText: "--",
                                               leftColor: leftColor,
                                               rightColor: rightColor,
                                               leftFont: KS_Const_Font_Normal_12,
                                               rightFont: KS_Const_Font_Normal_12,
                                               leftMargin: 0,
                                               rightMargin: 0,
                                               leftAlignment: NSTextAlignment.right,
                                               rightAlignment: NSTextAlignment.right,
                                               leftWidth: KS_Const_Point50,
                                               rightWidth: KS_Const_Point100)
        
        volView        = KSTwinsLabelView.init(leftText: "ks_app_global_text_24h_vol",
                                               rightText: "--",
                                               leftColor: leftColor,
                                               rightColor: rightColor,
                                               leftFont: KS_Const_Font_Normal_12,
                                               rightFont: KS_Const_Font_Normal_12,
                                               leftMargin: 0,
                                               rightMargin: 0,
                                               leftAlignment: NSTextAlignment.right,
                                               rightAlignment: NSTextAlignment.right,
                                               leftWidth: KS_Const_Point50,
                                               rightWidth:KS_Const_Point100)
        
        self.addSubview(highView)
        self.addSubview(lowView)
        self.addSubview(volView)
        
        let LH = 20

        highView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(LH)
        }
        
        lowView.snp.makeConstraints { (make) in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(LH)
        }
        
        volView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(LH)
        }
    }

}

// MARK: - 更新数据
extension KSPriceIndexView {
//    func update(chartItem: KSChartItem) {
//        highView.rightLabel.text = chartItem.high
//        lowView.rightLabel.text  = chartItem.low
//        volView.rightLabel.text  = chartItem.volumeDisplay
//        //chartItem.setHighValue(textLabel: highView.rightLabel,extra: nil)
//        //chartItem.setLowValue(textLabel: lowView.rightLabel,extra: nil)
//        //chartItem.setVolValue(textLabel: volView.rightLabel,extra: nil)
//    }
    
    func update(summary: KSSummaryInfo) {
        var maxValue = summary.high
        var maxCount = summary.high.count
        if summary.low.count > maxCount {
            maxCount = summary.low.count
            maxValue = summary.low
        }
        if summary.volumeDisplay.count > maxCount {
            maxCount = summary.volumeDisplay.count
            maxValue = summary.volumeDisplay
        }
        
        let offset               = maxValue.ks_sizeWithConstrained(highView.rightLabel.font).width + 4
        highView.updateLeftLabel(rightOffset: offset)
        lowView.updateLeftLabel(rightOffset: offset)
        volView.updateLeftLabel(rightOffset: offset)

        highView.rightLabel.text = summary.high
        lowView.rightLabel.text  = summary.low
        volView.rightLabel.text  = summary.volumeDisplay
    }
    
    func resetKit() {
        highView.rightLabel.text = "--"
        lowView.rightLabel.text  = "--"
        volView.rightLabel.text  = "--"
    }
}
