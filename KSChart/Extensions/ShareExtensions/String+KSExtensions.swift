//
//  String+KSExtensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/28.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

extension String {
    
    static func ks_localizde(_ text: String) -> String {
        return NSLocalizedString(text, comment: "")
        //return KSLanguageHelper.localizable(key: text)
        //return String.localizde(text)
    }
    
    static func ks_attribute(frontText: String?, frontFont: UIFont, frontColor: UIColor, behindText: String?, behindFont: UIFont, behindColor: UIColor) -> NSMutableAttributedString? {
        let text            = "\(frontText ?? "")\(behindText ?? "")"
        let attributeString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(.foregroundColor, value: frontColor, range: NSRange(location: 0, length: frontText?.count ?? 0))
        attributeString.addAttribute(.font, value: frontFont, range: NSRange(location: 0, length: frontText?.count ?? 0))

        attributeString.addAttribute(.foregroundColor, value: behindColor, range: NSRange(location: frontText?.count ?? 0, length: behindText?.count ?? 0))
        attributeString.addAttribute(.font, value: behindFont, range: NSRange(location: frontText?.count ?? 0, length: behindText?.count ?? 0))
        return attributeString
    }
    
    func dictionary() -> [String: Any]? {
        let data    = self.data(using: String.Encoding.utf8)
        if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
            return dict
        }
        return nil
    }
    
    static func ks_changeSpace(text: String, space: CGFloat, font: UIFont, color: UIColor?) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString.init(string: text)
        attributedString.addAttributes([NSAttributedString.Key.kern: space], range: NSRange(location: 0, length: text.count))
        attributedString.addAttributes([NSAttributedString.Key.font: font], range: NSRange(location: 0, length: text.count))
        if color != nil  {
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: color!], range: NSRange(location: 0, length: text.count))
        }
        return attributedString
    }
    
    static func ks_attributed(text: String, color: UIColor?) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString.init(string: text)
        if color != nil  {
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: color!], range: NSRange(location: 0, length: text.count))
        }
        return attributedString
    }
    
    func ks_floatValue() -> CGFloat {
        return CGFloat((Double(self) ?? 0))
    }
    
    /// 计算文字的宽高
    ///
    /// - Parameters:
    ///   - font: 字体大小
    ///   - constraintRect: 大小范围
    /// - Returns: 宽高
    func ks_sizeWithConstrained(_ font: UIFont,
                                constraintRect: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)) -> CGSize {
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil)
        return boundingBox.size
    }
    
    /// 字符串长度
    var ks_length: Int {
        return self.count;
    }
    
    ///成交量
    func ks_volume() -> String {
        let vol = Double(self) ?? 0
        if vol >= 1000000.0 {
            return String.init(format: "%.2fM", vol/1000000.0)
        }
        else if vol >= 1000.0 {
            return String.init(format: "%.2fK", vol/1000.0)
        }
        else {
            return self
        }
    }
}
