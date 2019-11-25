//
//  KSMenuBarView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/9/12.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSMenuBarView: KSBaseView {
    
    var orderbookBtn: KSPageButton!
    var marketTradeBtn: KSPageButton!
    var infoBtn: KSPageButton!
    var lineView: UIView!

    override func configureDefaultValue() {
        
    }
    
    override func createChildViews() {
        let orderbookText        = String.ks_localizde("ks_app_global_text_orderbook")
        let marketTradeText      = String.ks_localizde("ks_app_global_text_market_trade")
        let infoText             = String.ks_localizde("ks_app_global_text_info")

        orderbookBtn             = KSPageButton.init(title: orderbookText, font: KS_Const_Font_Normal_16, normalColor: KS_Const_Color_Chart_Ink, selectedColor: KS_Const_Color_Menu_Text_Selectd)
        orderbookBtn.textWidth   = orderbookText.ks_sizeWithConstrained(KS_Const_Font_Normal_16).width
        orderbookBtn.tag         = 0

        marketTradeBtn           = KSPageButton.init(title: marketTradeText, font: KS_Const_Font_Normal_16, normalColor: KS_Const_Color_Chart_Ink, selectedColor: KS_Const_Color_Menu_Text_Selectd)
        marketTradeBtn.textWidth = marketTradeText.ks_sizeWithConstrained(KS_Const_Font_Normal_16).width
        marketTradeBtn.tag       = 1

        infoBtn                  = KSPageButton.init(title: infoText, font: KS_Const_Font_Normal_16, normalColor: KS_Const_Color_Chart_Ink, selectedColor: KS_Const_Color_Menu_Text_Selectd)
        infoBtn.textWidth        = infoText.ks_sizeWithConstrained(KS_Const_Font_Normal_16).width
        infoBtn.tag              = 2

        lineView                 = UIView.init(color: KS_Const_Color_Menu_Text_Selectd)

        self.addSubview(orderbookBtn)
        self.addSubview(marketTradeBtn)
        self.addSubview(infoBtn)
        self.addSubview(lineView)

        orderbookBtn.ks_addTarget(self, action: #selector(onOrderbookClick))
        marketTradeBtn.ks_addTarget(self, action: #selector(onMarketTradeClick))
        infoBtn.ks_addTarget(self, action: #selector(onInfoClick))

        let BH: CGFloat          = 32
        let BY: CGFloat          = 8
        let offset: CGFloat      = 64
        orderbookBtn.frame       = CGRect.init(x: 0, y: BY, width: orderbookBtn.textWidth + offset, height: BH)
        marketTradeBtn.frame     = CGRect.init(x: (self.frame.width / 2) - ((marketTradeBtn.textWidth + offset) / 2), y: BY, width: marketTradeBtn.textWidth  + offset, height: BH)
        infoBtn.frame            = CGRect.init(x: self.frame.width - infoBtn.textWidth - offset, y: BY, width: infoBtn.textWidth + offset, height: BH)
        lineView.frame           = CGRect.init(x: orderbookBtn.center.x - ((orderbookBtn.textWidth + 20) / 2), y: orderbookBtn.frame.maxY, width: (orderbookBtn.textWidth + 20), height: 2)
        
        _ = KSSpeedy.addHorizontalLine(toView: self, color: KS_Const_Color_Ctrl_Background, leftOffset: 0, rightOffset: 0, height: 8, isTop: true)
    }
    
    @objc func onOrderbookClick(button: KSPageButton) {
        moveLine(button: button)
        self.theDelegate?.ksviewCallback?(view: self, data: button.tag, identifier: "KSMenuBarView")
        
    }
    
    @objc func onMarketTradeClick(button: KSPageButton) {
        moveLine(button: button)
        self.theDelegate?.ksviewCallback?(view: self, data: button.tag, identifier: "KSMenuBarView")
    }
    
    @objc func onInfoClick(button: KSPageButton) {
        moveLine(button: button)
        self.theDelegate?.ksviewCallback?(view: self, data: button.tag, identifier: "KSMenuBarView")
    }
    
    private func moveLine(button: KSPageButton) {
        UIView.animate(withDuration: 0.15) {
            self.lineView.frame = CGRect.init(x: button.center.x - ((button.textWidth + 20) / 2), y: button.frame.maxY-2, width: (button.textWidth + 20), height: 2)
        }
    }
    
    func updateSelected(index: Int) {
        switch index {
        case 0:
            moveLine(button: orderbookBtn)
        case 1:
            moveLine(button: marketTradeBtn)
        case 2:
            moveLine(button: infoBtn)
        default:
            break
        }
    }

}
