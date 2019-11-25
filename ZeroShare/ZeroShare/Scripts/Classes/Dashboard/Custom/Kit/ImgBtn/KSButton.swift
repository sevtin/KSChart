//
//  KSButton.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/28.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSButton: UIControl {
    var titleLabel: UILabel!
    var imgView: UIImageView!
    var imgIsLeft: Bool    = false
    var offset: CGFloat    = 0
    var imgWidth: CGFloat  = 0
    var imgHeight: CGFloat = 0
    var isRotate: Bool     = false


//    convenience init(title: String, textColor: UIColor, textFont: UIFont, alignment: NSTextAlignment, imgName: String, imgIsLeft: Bool, offset: CGFloat, imgWidth: CGFloat, imgHeight: CGFloat) {
//        self.init()
//        titleLabel = UILabel.init(textColor: textColor, textFont: textFont, alignment: alignment)
//        addSubview(titleLabel)
//
//        let imgView = UIImageView.init(image: UIImage.init(named: imgName))
//        addSubview(imgView)
//
//        if imgIsLeft {
//            imgView.snp.makeConstraints { (make) in
//                make.height.equalTo(imgHeight)
//                make.width.equalTo(imgWidth)
//                make.left.centerY.equalToSuperview()
//            }
//            titleLabel.snp.makeConstraints { (make) in
//                make.left.equalTo(imgView.snp.right).offset(offset)
//                make.top.bottom.right.equalToSuperview()
//            }
//        } else {
//            titleLabel.snp.makeConstraints { (make) in
//                make.top.bottom.left.equalToSuperview()
//                make.right.equalToSuperview().offset(-(imgWidth + offset))
//            }
//
//            imgView.snp.makeConstraints { (make) in
//                make.height.equalTo(imgHeight)
//                make.width.equalTo(imgWidth)
//                make.centerY.equalToSuperview()
//                make.left.equalTo(titleLabel.snp.right).offset(offset)
//            }
//        }
//    }
}

extension KSButton {
    convenience init(textColor: UIColor, textFont: UIFont, alignment: NSTextAlignment, imgName: String, imgIsLeft: Bool, offset: CGFloat, imgWidth: CGFloat, imgHeight: CGFloat) {
        self.init()
        titleLabel               = UILabel.init(textColor: textColor, textFont: textFont, alignment: alignment)
        titleLabel.numberOfLines = 1
        addSubview(titleLabel)

        imgView                  = UIImageView.init(image: UIImage.init(named: imgName))
        addSubview(imgView)

        self.imgIsLeft           = imgIsLeft
        self.offset              = offset
        self.imgWidth            = imgWidth
        self.imgHeight           = imgHeight
    }
    /*
    func update(text:String) {
        let SH           = self.frame.height
        let SW           = self.frame.width
        let textSize     = text.ks_sizeWithConstrained(titleLabel.font, constraintRect: CGSize.init(width: (SW - offset - imgWidth), height: SH))
        let SX           = (SW - (textSize.width + offset + imgWidth)) / 2
        let LX           = self.imgIsLeft ? (SX + imgWidth + offset) : SX
        let IX           = self.imgIsLeft ? SX : (SX + textSize.width + offset)
        titleLabel.frame = CGRect.init(x: LX, y: 0, width: textSize.width, height: SH)
        imgView.frame    = CGRect.init(x: IX, y: (SH - imgHeight) / 2, width: imgWidth, height: imgHeight)
        titleLabel.text  = text
    }
     */
    
    func update(text: String, isCenter: Bool = true) {
        let SH          = self.frame.height
        let SW          = self.frame.width
        let title       = String.ks_localizde(text)
        let textSize    = title.ks_sizeWithConstrained(titleLabel.font, constraintRect: CGSize.init(width: (SW - offset - imgWidth), height: SH))
        let SX          = (SW - (textSize.width + offset + imgWidth)) / 2
        var LX: CGFloat = 0
        var IX: CGFloat = 0
        if isCenter {
            LX           = self.imgIsLeft ? (SX + imgWidth + offset) : SX
            IX           = self.imgIsLeft ? SX : (SX + textSize.width + offset)
        }
        else{
            LX           = self.imgIsLeft ? imgWidth + offset : 0
            IX           = self.imgIsLeft ? 0 : textSize.width + offset
        }
        titleLabel.frame = CGRect.init(x: LX, y: 0, width: textSize.width, height: SH)
        imgView.frame    = CGRect.init(x: IX, y: (SH - imgHeight) / 2, width: imgWidth, height: imgHeight)
        titleLabel.text  = title
    }
    
    func updatea(textColor: UIColor, textFont: UIFont, imgWidth: CGFloat, imgHeight: CGFloat, isCenter: Bool = true) {
        titleLabel.textColor = textColor
        titleLabel.font      = textFont
        self.imgWidth        = imgWidth
        self.imgHeight       = imgHeight
        self.update(text: titleLabel.text ?? "", isCenter: isCenter)
    }
    
    func update(textColor: UIColor) {
        titleLabel.textColor = textColor
    }
    
    func updatea(textColor: UIColor, imgName: String, imgWidth: CGFloat, imgHeight: CGFloat, isCenter: Bool = true) {
        titleLabel.textColor = textColor
        self.imgView.image   = UIImage.init(named: imgName)
        self.imgWidth        = imgWidth
        self.imgHeight       = imgHeight
        self.update(text: titleLabel.text ?? "", isCenter: isCenter)
    }
    
    override var isSelected: Bool {
        didSet {
            if isRotate {
                updateRotate()
            }
        }
    }
    
    func updateRotate(){
        if isSelected {
            UIView.animate(withDuration: 0.5) {
                self.imgView.transform = CGAffineTransform(rotationAngle: .pi * (10000.0 / 9999.0))
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.imgView.transform = CGAffineTransform(rotationAngle: 0)
            }
        }
    }
}
