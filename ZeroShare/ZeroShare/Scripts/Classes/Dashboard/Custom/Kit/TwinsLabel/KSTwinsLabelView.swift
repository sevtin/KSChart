//
//  KSTwinsLabelView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/28.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSTwinsLabelView: UIView {

    var leftLabel:UILabel!
    var rightLabel:UILabel!
    
    convenience init(leftText: String?, rightText: String?, leftColor: UIColor, rightColor: UIColor, leftFont: UIFont, rightFont: UIFont, leftMargin: CGFloat = 0, rightMargin: CGFloat = 0, leftAlignment: NSTextAlignment = .left, rightAlignment: NSTextAlignment = .right, leftWidth: CGFloat = 143, rightWidth: CGFloat = 143) {
        
        self.init()
        
        leftLabel       = UILabel.init(textColor: leftColor, textFont: leftFont, alignment: leftAlignment)
        rightLabel      = UILabel.init(textColor: rightColor, textFont: rightFont, alignment: rightAlignment)
        
        if let _leftText = leftText {
            leftLabel.text = String.ks_localizde(_leftText)
        }
        if let _rightText = rightText {
            rightLabel.text = _rightText
        }
        
        self.addSubview(leftLabel)
        self.addSubview(rightLabel)
        
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.width.equalTo(leftWidth)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(rightMargin)
            make.width.equalTo(rightWidth)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    convenience init(leftText: String?, textColor: UIColor, textFont: UIFont, leftMargin: CGFloat = 0, rightMargin: CGFloat = 0, leftAlignment: NSTextAlignment = .left, rightAlignment: NSTextAlignment = .right, leftWidth: CGFloat = 143, rightWidth: CGFloat = 143) {
        
        self.init()
        
        leftLabel       = UILabel.init(textColor: textColor, textFont: textFont, alignment: leftAlignment)
        rightLabel      = UILabel.init(textColor: textColor, textFont: textFont, alignment: rightAlignment)
        
        if let _leftText = leftText {
            leftLabel.text = _leftText
        }
        
        self.addSubview(leftLabel)
        self.addSubview(rightLabel)
        
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.width.equalTo(leftWidth)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(rightMargin)
            make.width.equalTo(rightWidth)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func update(textColor: UIColor) {
        leftLabel.textColor  = textColor
        rightLabel.textColor = textColor
    }
    
    func updateLeftLabel(rightOffset:CGFloat) {
        leftLabel.snp.updateConstraints { (make) in
            make.width.equalTo(self.frame.width - rightOffset)
        }
    }
}
