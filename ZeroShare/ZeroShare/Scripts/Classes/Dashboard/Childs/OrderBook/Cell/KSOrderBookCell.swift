//
//  KSBaseTableViewCell.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/26.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit
import SwiftyJSON

let orderBookCellIdentifier = "KSOrderBookCellIdentifier"
//KSRealtimeOrderCell
class KSOrderBookCell: KSBaseTableViewCell {
    
    var leftBarView:KSBarChartView!
    var rightBarView:KSBarChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func initialize(tableView:UITableView) -> KSOrderBookCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: orderBookCellIdentifier)
        if cell == nil {
            cell                 = KSOrderBookCell.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: orderBookCellIdentifier)
            cell?.selectionStyle = .none
        }
        return cell as! KSOrderBookCell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    /// 初始化默认值
    override func defaultValue() {
        
    }
    
    /// 创建子控件
    override func createChildViews() {
        leftBarView = KSBarChartView.init(isBuy: true)
        rightBarView = KSBarChartView.init(isBuy: false)
        self.addSubview(leftBarView)
        self.addSubview(rightBarView)
        
        leftBarView.snp.makeConstraints { (make) in
            make.top.bottom.left.equalToSuperview()
            make.right.equalTo(self.snp.centerX).offset(-0.5)
        }
        rightBarView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(self.snp.centerX).offset(0.5)
        }
    }
    
    func update(info:KSOrderBookInfo?) {
        leftBarView.update(info: info)
        rightBarView.update(info: info?.otherInfo)
    }
}

class KSOrderBookInfo: NSObject {
    var isBuy: Bool         = false
    var barX: CGFloat       = 0
    var barY: CGFloat       = 1
    var barHeight: CGFloat  = 26
    var barWidth: CGFloat   = 0
    var proportion: CGFloat = 0
    var amountValue: Double = 0
    var attributedPrice: NSMutableAttributedString!
    var attributedAmount: NSMutableAttributedString!

    var price: String?
    var amount: String? {
        didSet {
            amountValue       = Double(oldValue ?? "0") ?? 0
            amountDisplay     = oldValue?.ks_volume()
            let space: CGFloat = -0.8
  
            let color        = isBuy ? KS_Const_Color_Chart_Up: KS_Const_Color_Chart_Down
            var font         = KS_Const_Font_Normal_14
            if let _font     = KS_Const_Font_HelveticaNeue_14 {
                font = _font
            }
            attributedAmount = String.ks_changeSpace(text: amountDisplay!, space: space, font: font, color: nil)
            attributedPrice  = String.ks_changeSpace(text: price!, space: space, font: font, color: color)
        }
    }
    var amountDisplay: String?
    
    
    var otherInfo:KSOrderBookInfo?
    
    private func updateBar(maxWidth: CGFloat) {
        barWidth = maxWidth * proportion
        if isBuy {
            barX  = maxWidth - barWidth
        }
        else{
            barX = 0
        }
    }
    
    func updateBar(maxAmount: Double, deviation: Double, maxAmountLog: Double, maxWidth: CGFloat) {
        if (maxAmount > 50){
            let amountOffNumbet:Double = amountValue / deviation
            let amountLog:Double       = log(amountOffNumbet + 1)
            proportion                 = CGFloat(amountLog / maxAmountLog)
            updateBar(maxWidth: maxWidth)
        }else{
            let amountLog:Double = log(amountValue + 1)
            proportion           = CGFloat(amountLog * maxAmountLog)
            updateBar(maxWidth: maxWidth)
        }
    }
    
    
    private func updateBar(model: KSOrderBookInfo, maxAmount: Double, deviation: Double, maxAmountLog: Double) {
        if (maxAmount > 50){
            let amountOffNumbet:Double = model.amountValue / deviation
            let amountLog:Double       = log(amountOffNumbet + 1)
            model.proportion           = CGFloat(amountLog / maxAmountLog)
        }else{
            let amountLog:Double = log(model.amountValue + 1)
            model.proportion     = CGFloat(amountLog * maxAmountLog)
        }
    }
}

extension KSOrderBookInfo {
    class func formatMessage(json: JSON) -> [KSOrderBookInfo] {
        var buys                = [KSOrderBookInfo]()
        var buyMaxAmount:Double = 0
        for i in stride(from: 0, to: json["b"]["bi"].arrayValue.count, by: 2) {
            let info    = KSOrderBookInfo.init()
            info.isBuy  = true
            info.price  = json["b"]["bi"][i].stringValue
            info.amount = json["b"]["bi"][i+1].stringValue
            if buyMaxAmount < info.amountValue {
                buyMaxAmount = info.amountValue
            }
            buys.append(info)
        }
        
        var sells                = [KSOrderBookInfo]()
        var sellMaxAmount:Double = 0
        for i in stride(from: 0, to: json["b"]["ak"].arrayValue.count, by: 2) {
            let info    = KSOrderBookInfo.init()
            info.isBuy  = false
            info.price  = json["b"]["ak"][i].stringValue
            info.amount = json["b"]["ak"][i+1].stringValue
            
            if sellMaxAmount < info.amountValue {
                sellMaxAmount = info.amountValue
            }
            sells.append(info)
        }
        
        if buys.count > sells.count {
            for _ in sells.count..<buys.count {
                let info              = KSOrderBookInfo.init()
                info.isBuy            = false
                info.attributedAmount = String.ks_attributed(text: "--", color: KS_Const_Color_Chart_Ink)
                info.attributedPrice  = String.ks_attributed(text: "--", color: KS_Const_Color_Chart_Ink)
                sells.append(info)
            }
        }
        else if buys.count < sells.count {
            for _ in buys.count..<sells.count {
                let info              = KSOrderBookInfo.init()
                info.isBuy            = true
                info.attributedAmount = String.ks_attributed(text: "--", color: KS_Const_Color_Chart_Ink)
                info.attributedPrice  = String.ks_attributed(text: "--", color: KS_Const_Color_Chart_Ink)
                buys.append(info)
            }
        }
        
        let maxAmount = buyMaxAmount > sellMaxAmount ? buyMaxAmount : sellMaxAmount
        var deviation: Double = 0
        var maxAmountLog: Double = 0;
        if(maxAmount > 50) {
            deviation = maxAmount / 50
            maxAmountLog = log(51);
        }else{
            maxAmountLog = log(maxAmount + 1);
        }
        let maxWidth = (self.ks_screenWidth()-2)/2
        for i in 0..<buys.count {
            let sellItem = sells[i]
            let buyItem = buys[i]
            sellItem.updateBar(maxAmount: maxAmount, deviation: deviation, maxAmountLog: maxAmountLog, maxWidth: maxWidth)
            buyItem.updateBar(maxAmount: maxAmount, deviation: deviation, maxAmountLog: maxAmountLog, maxWidth: maxWidth)
            buyItem.otherInfo = sellItem
        }
        
        //let outerArray = jsonData["ch"].stringValue.components(separatedBy:",")
        //let market     = outerArray[0].components(separatedBy:":")[1]
        //let side       = outerArray[1].components(separatedBy:":")[1]
        
        return buys
    }
}

class KSBarChartView: UIView {
    
    var barLayer:KSShapeLayer!
    var priceLabel:UILabel!
    var amountLabel:UILabel!
    var isBuy:Bool = false
    
    convenience init(isBuy: Bool) {
        self.init()
        self.isBuy = isBuy
        self.createChildViews()
    }
    
    func createChildViews() {
        barLayer                 = KSShapeLayer.init()
        var font                 = KS_Const_Font_Normal_14
        if let _font = KS_Const_Font_HelveticaNeue_14 {
            font = _font
        }
        priceLabel               = UILabel.init(textFont: font, alignment: isBuy ? .right : .left)
        amountLabel              = UILabel.init(textFont: font, alignment: isBuy ? .left : .right)
        self.layer.addSublayer(barLayer)
        self.addSubview(priceLabel)
        self.addSubview(amountLabel)
        
        let leftOffset           = isBuy ? KS_Const_Point10 : KS_Const_Point04
        let rightOffset          = isBuy ? -KS_Const_Point04 : -KS_Const_Point10
        priceLabel.textColor     = isBuy ? KS_Const_Color_Chart_Up : KS_Const_Color_Chart_Down
        amountLabel.textColor    = KS_Const_Color_Chart_Ink
        barLayer.backgroundColor = isBuy ? KS_Const_Color_Chart_Up_Fill.cgColor : KS_Const_Color_Chart_Down_Fill.cgColor
        
        if isBuy {
            amountLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(leftOffset)
                make.right.equalToSuperview().offset(-KS_Const_Point60)
                make.top.bottom.equalToSuperview()
            }
            priceLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(KS_Const_Point60)
                make.right.equalToSuperview().offset(rightOffset)
                make.top.bottom.equalToSuperview()
            }
        }
        else{
            priceLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(leftOffset)
                make.right.equalToSuperview().offset(-KS_Const_Point60)
                make.top.bottom.equalToSuperview()
            }
            amountLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(KS_Const_Point60)
                make.right.equalToSuperview().offset(rightOffset)
                make.top.bottom.equalToSuperview()
            }
        }
    }
    
    func update(info: KSOrderBookInfo?) {
        if let _info = info {
            barLayer.frame   = CGRect.init(x: _info.barX, y: _info.barY, width: _info.barWidth, height: _info.barHeight)
            priceLabel.attributedText          = _info.attributedPrice
            amountLabel.attributedText         = _info.attributedAmount
            //priceLabel.text  = _info.price
            //amountLabel.text = _info.amountDisplay
        }
    }
}
