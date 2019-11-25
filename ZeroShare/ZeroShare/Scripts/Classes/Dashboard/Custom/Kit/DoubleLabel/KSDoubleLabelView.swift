//
//  KSDoubleLabelView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/28.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSDoubleLabelView: UIView {
    
    private var items                  = [UILabel]()
    private var padding: CGFloat       = 0.0
    private var contentsCount: Int     = 0
    private var isCustomLayout: Bool   = false
    
    private var widthScales: [CGFloat] = [CGFloat]()
    private var margin: CGFloat        = 0.0
    
    convenience init(textColor: UIColor, textFont: UIFont, maxCount: Int, padding: CGFloat) {
        self.init()
        self.padding = padding
        for _ in 0..<maxCount {
            let itemLabel           = UILabel.init(textColor: textColor, textFont: textFont, alignment: NSTextAlignment.center)
            itemLabel.numberOfLines = 1
            self.items.append(itemLabel)
            self.addSubview(itemLabel)
        }
    }
    
    /// alignments.count == count
    convenience init(textColor: UIColor, textFont: UIFont, alignments: [NSTextAlignment], count: Int, padding: CGFloat) {
        self.init()
        self.padding = padding
        for i in 0..<count {
            let itemLabel           = UILabel.init(textColor: textColor, textFont: textFont, alignment: alignments[i])
            itemLabel.numberOfLines = 1
            self.items.append(itemLabel)
            self.addSubview(itemLabel)
        }
    }
    
    /// alignments.count == count == widthScales.count
    convenience init(textColor: UIColor, textFont: UIFont, alignments: [NSTextAlignment], count: Int, widthScales: [CGFloat], margin: CGFloat, padding: CGFloat) {
        self.init()
        self.widthScales    += widthScales
        self.margin         = margin
        self.padding        = padding
        self.isCustomLayout = true
        for i in 0..<count {
            let itemLabel           = UILabel.init(textColor: textColor, textFont: textFont, alignment: alignments[i])
            itemLabel.numberOfLines = 1
            self.items.append(itemLabel)
            self.addSubview(itemLabel)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let SW = self.frame.width
        let SH = self.frame.height
        if isCustomLayout {
            let LSW        = SW - (self.margin * 2.0) - (CGFloat(self.contentsCount - 1) * self.padding)
            var LX:CGFloat = 0
            for i in 0..<contentsCount {
                let itemLabel = items[i]
                let LW        = LSW * self.widthScales[i]
                if i == 0 {
                    LX = self.margin
                }
                itemLabel.frame = CGRect(x: LX, y: 0, width: LW, height: SH)
                LX = LX + LW + self.padding
            }
        }
        else{
            let LW = (SW - (padding * CGFloat((contentsCount + 1)))) / CGFloat(contentsCount)
            for i in 0..<contentsCount {
                let itemLabel = items[i]
                itemLabel.frame = CGRect(x: (padding * CGFloat(i) + padding) + (LW * CGFloat(i)), y: 0, width: LW, height: SH)
            }
        }
    }
    
    func update(texts: [String]) {
        if items.count < texts.count {
            return
        }
        contentsCount = texts.count
        for i in 0..<texts.count {
            let itemLabel = items[i]
            itemLabel.text = texts[i]
            itemLabel.isHidden = false
        }
        for i in texts.count..<items.count {
            let itemLabel = items[i]
            itemLabel.isHidden = true
        }
    }
    
    func update(attributedTexts: [NSMutableAttributedString]) {
        if items.count < attributedTexts.count {
            return
        }
        contentsCount = attributedTexts.count
        for i in 0..<attributedTexts.count {
            let itemLabel            = items[i]
            itemLabel.attributedText = attributedTexts[i]
            itemLabel.isHidden       = false
        }
        for i in attributedTexts.count..<items.count {
            let itemLabel = items[i]
            itemLabel.isHidden = true
        }
    }
    
    func update(alignments: [NSTextAlignment]) {
        if contentsCount != alignments.count {
            return
        }
        for i in 0..<items.count {
            let itemLabel           = items[i]
            itemLabel.textAlignment = alignments[i]
        }
    }
    
    func update(fonts: [UIFont]) {
        if contentsCount != fonts.count {
            return
        }
        for i in 0..<items.count {
            let itemLabel  = items[i]
            itemLabel.font = fonts[i]
        }
    }
    
    func update(font: UIFont) {
        for i in 0..<items.count {
            let itemLabel  = items[i]
            itemLabel.font = font
        }
    }
    
    func update(alignment: NSTextAlignment, index: Int) {
        if items.count > index {
            items[index].textAlignment = alignment
        }
    }
    
    func update(attributedText: NSMutableAttributedString, index: Int) {
        if items.count > index {
            items[index].attributedText = attributedText
        }
    }
    
    func update(text: String, index: Int) {
        if items.count > index {
            items[index].text = text
        }
    }
    
    func update(textColor: UIColor, index: Int) {
        if items.count > index {
            items[index].textColor = textColor
        }
    }
}

