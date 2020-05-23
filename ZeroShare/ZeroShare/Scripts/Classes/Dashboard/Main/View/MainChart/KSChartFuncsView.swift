//
//  KSChartFuncsView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSChartFuncsView: KSBaseView {
   
    var timeBtn: KSButton!
    var taiBtn: KSButton!
    var timeInfo: KSChartMenuInfo!

    var masterSeriesKey: String = "" {
        didSet {
            KSSingleton.shared.indexConfigure.masterTai = oldValue
        }
    }
    
    var assistSeriesKey: String = "" {
        didSet {
            KSSingleton.shared.indexConfigure.assistTai = oldValue
        }
    }

    override func configureDefaultValue() {
        self.backgroundColor = KS_Const_Color_Menu_Background
    }
    
    override func createChildViews() {
        timeBtn = KSButton.init(textColor: KS_Const_Color_Menu_Text_Selectd,
                                textFont: KS_Const_Font_Normal_16,
                                alignment: NSTextAlignment.center,
                                imgName: "ic_chart_arrow",
                                imgIsLeft: false,
                                offset: KS_Const_Point04,
                                imgWidth: 10,
                                imgHeight: 5)
        timeBtn.frame = CGRect.init(x: KS_Const_Point16, y: 0, width: KS_Const_Point80, height: KS_Const_Point44)
        timeBtn.update(text: "ks_app_global_text_1d",isCenter: false)
        self.addSubview(timeBtn)

        taiBtn    = KSButton.init(textColor: KS_Const_Color_Chart_Ink,
                                  textFont: KS_Const_Font_Normal_14,
                                  alignment: NSTextAlignment.center,
                                  imgName: "ic_chart_arrow_gray",
                                  imgIsLeft: false,
                                  offset: KS_Const_Point04,
                                  imgWidth: 10,
                                  imgHeight: 5)
        taiBtn.frame = CGRect.init(x: 96, y: 0, width: 120, height: KS_Const_Point44)
        self.addSubview(taiBtn)
        
        self.masterSeriesKey = KSSingleton.shared.indexConfigure.masterTai ?? ""
        self.assistSeriesKey = KSSingleton.shared.indexConfigure.assistTai
        updateTaiDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.theDelegate?.ksviewTouche?(view: self,identifier: nil)
    }
}

// MARK: - UI更新
extension KSChartFuncsView {
    func updateTime(menuInfo:KSChartMenuInfo) {
        timeInfo = menuInfo
        self.timeBtn.update(text: menuInfo.displayText,isCenter: false)
    }
    
    func updateTai(menuInfo:KSChartMenuInfo) {
        self.taiBtn.update(text: menuInfo.displayText,isCenter: false)
    }
    
    func updateTai(menuGroup: KSTaiMenuGroup, isOpeneye: Bool) {
        if isOpeneye == false {
            if menuGroup.type == .master {
                self.masterSeriesKey = ""
            }
            else {
                self.assistSeriesKey = KSSeriesKey.volume
            }
        }
        updateTaiDisplay()
    }
    
    func updateTai(menuInfo: KSChartMenuInfo, groupType: KSSectionValueType) {
        if groupType == .master {
            self.masterSeriesKey = menuInfo.identifier
        }
        else{
            self.assistSeriesKey = menuInfo.identifier
        }
        updateTaiDisplay()
    }
    
    private func updateTaiDisplay() {
        let masterTai = self.masterSeriesKey
        var assistTai = self.assistSeriesKey
        if  assistTai == KSSeriesKey.volume {
            assistTai = ""
        }
        if masterTai.isEmpty && assistTai.isEmpty {
            taiBtn.update(text: "ks_app_global_text_indicator",isCenter: false)
        }
        else if masterTai.isEmpty == false && assistTai.isEmpty == false {
            taiBtn.update(text: masterTai + "-" + assistTai,isCenter: false)
        }
        else if masterTai.isEmpty == false  {
            taiBtn.update(text: masterTai,isCenter: false)
        }
        else if assistTai.isEmpty == false {
            taiBtn.update(text: assistTai,isCenter: false)
        }
    }
    
    func updateTai(isEnabled: Bool) {
        taiBtn.isEnabled = isEnabled
        if isEnabled == false {
            taiBtn.updatea(textColor: KS_Const_Color_Chart_Ink, imgName: "ic_chart_arrow_gray", imgWidth: 10, imgHeight: 5, isCenter: false)
            //taiBtn.frame = CGRect.init(x: 96, y: 0, width: 120, height: KS_Const_Point44)
            //taiBtn.updatea(textColor: KS_Const_Color_Menu_Text_Normal, textFont: KS_Const_Font_Normal_12, imgWidth: 13*0.75, imgHeight: 11*0.75, isCenter: false)
        }
        else{
            //taiBtn.frame = CGRect.init(x: 96, y: 0, width: 120, height: KS_Const_Point44)
            //taiBtn.updatea(textColor: KS_Const_Color_Menu_Text_Selectd, textFont: KS_Const_Font_Normal_16, imgWidth: 13, imgHeight: 11, isCenter: false)
            //taiBtn.updatea(textColor: KS_Const_Color_Menu_Text_Selectd, imgName: "ic_chart_arrow", imgWidth: 10, imgHeight: 5, isCenter: false)
        }
    }
    
    func updateTai(isSelectd: Bool) {
        if isSelectd {
            taiBtn.updatea(textColor: KS_Const_Color_Menu_Text_Selectd, imgName: "ic_chart_arrow", imgWidth: 10, imgHeight: 5, isCenter: false)
        }
        else{
            taiBtn.updatea(textColor: KS_Const_Color_Chart_Ink, imgName: "ic_chart_arrow_gray", imgWidth: 10, imgHeight: 5, isCenter: false)
        }
        taiBtn.isSelected = isSelectd
    }
    
}
