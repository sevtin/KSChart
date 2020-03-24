//
//  KSChartValueView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/27.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSChartValueView: KSBaseView {

    private var openLabel: UILabel!
    private var highLabel: UILabel!
    private var lowLabel: UILabel!
    private var closeLabel: UILabel!
    private var chgLabel: UILabel!
    private var dateLabel: UILabel!
    var dateFormart:String = "yyyy-MM-dd HH:mm:ss"
    
    override func configureDefaultValue() {
        self.backgroundColor = KS_Const_Color_Menu_Background
    }
    
    override func createChildViews() {
        openLabel  = UILabel.init(textFont: KS_Const_Font_Normal_12, alignment: NSTextAlignment.left)
        highLabel  = UILabel.init(textFont: KS_Const_Font_Normal_12, alignment: NSTextAlignment.left)
        lowLabel   = UILabel.init(textFont: KS_Const_Font_Normal_12, alignment: NSTextAlignment.left)
        closeLabel = UILabel.init(textFont: KS_Const_Font_Normal_12, alignment: NSTextAlignment.left)
        chgLabel   = UILabel.init(textFont: KS_Const_Font_Normal_12, alignment: NSTextAlignment.left)
        dateLabel  = UILabel.init(textColor: KS_Const_Color_Chart_Ink, textFont: KS_Const_Font_Normal_12, alignment: NSTextAlignment.left)

        self.addSubview(openLabel)
        self.addSubview(highLabel)
        self.addSubview(lowLabel)
        self.addSubview(closeLabel)
        self.addSubview(chgLabel)
        self.addSubview(dateLabel)
        
        let margin:CGFloat = 8
        let LS             = (self.frame.width - margin * 4.0) / 3
        let LH             = 22
        
        openLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(margin)
            make.width.equalTo(LS)
            make.height.equalTo(LH)
            make.bottom.equalTo(self.snp.centerY).offset(2)
        }
        closeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(openLabel.snp.left)
            make.width.equalTo(LS)
            make.height.equalTo(LH)
            make.top.equalTo(self.snp.centerY).offset(-2)
        }
        highLabel.snp.makeConstraints { (make) in
            make.left.equalTo(openLabel.snp.right).offset(margin)
            make.width.equalTo(LS)
            make.height.equalTo(LH)
            make.top.equalTo(openLabel.snp.top)
        }
        chgLabel.snp.makeConstraints { (make) in
            make.left.equalTo(highLabel.snp.left)
            make.width.equalTo(LS)
            make.height.equalTo(LH)
            make.top.equalTo(closeLabel.snp.top)
        }
        lowLabel.snp.makeConstraints { (make) in
            make.left.equalTo(highLabel.snp.right).offset(margin)
            make.width.equalTo(LS)
            make.height.equalTo(LH)
            make.top.equalTo(openLabel.snp.top)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(lowLabel.snp.left)
            make.width.equalTo(LS)
            make.height.equalTo(LH)
            make.top.equalTo(closeLabel.snp.top)
        }
    }
    
    let openTitle = String.ks_localizde("ks_app_global_text_open") + ": "
    let closeTitle = String.ks_localizde("ks_app_global_text_close") + ": "
    let highTitle = String.ks_localizde("ks_app_global_text_maxhigh") + ": "
    let lowTitle = String.ks_localizde("ks_app_global_text_maxlow") + ": "
    let changeTitle = String.ks_localizde("ks_app_global_text_chg") + ": "
    
    
    func update(value: KSChartItem) {
        self.showKit()
        value.setOpenValue(textLabel: openLabel,extra: openTitle)
        value.setCloseValue(textLabel: closeLabel,extra: closeTitle)
        value.setHighValue(textLabel: highLabel,extra: highTitle)
        value.setLowValue(textLabel: lowLabel,extra: lowTitle)
        value.setChangePercentValue(textLabel: chgLabel, extra: changeTitle)
        dateLabel.text = Date.ks_formatTimeStamp(timeStamp: value.time, format: dateFormart)
    }
}
