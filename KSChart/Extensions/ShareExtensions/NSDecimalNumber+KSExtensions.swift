//
//  NSDecimalNumber+KSExtensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/30.
//  Copyright © 2019 saeipi. All rights reserved.
//

import Foundation
extension NSDecimalNumber {
    class func ks_format(amount: String?, maxDigits: Int = 8, minDigits: Int = 2) -> String {
        var unit: String                      = ""
        var digits                            = 0
        var number                            = NSDecimalNumber.init(string: (amount?.isEmpty ?? false) ? "0" : amount)
        
        if number.doubleValue >= 1000000 {
            //如果大于等于100万
            digits                            = 1
            number                            = number.dividing(by: NSDecimalNumber(string: "1000000"))
            unit                              = "M"
        } else if number.doubleValue >= 1000 {
            //如果大于1000
            number                            = number.dividing(by: NSDecimalNumber(string: "1000"))
            digits                            = 1
            unit                              = "K"
        } else {
            digits                            = maxDigits
        }
        
        let numberFormatter                   = NumberFormatter()
        numberFormatter.formatterBehavior     = .behavior10_4
        numberFormatter.numberStyle           = .decimal
        numberFormatter.maximumFractionDigits = digits
        numberFormatter.minimumFractionDigits = minDigits
        numberFormatter.roundingMode          = NumberFormatter.RoundingMode.down
        if let numberString                   = numberFormatter.string(from: number) {
            return numberString + unit
        }
        return ""
    }
    
    class func ks_format(value: String?, maxDigits: Int, minDigits: Int = 2, roundingMode: NumberFormatter.RoundingMode = .down) -> String {
        let number                            = NSDecimalNumber.init(string: value)
        let numberFormatter                   = NumberFormatter()
        numberFormatter.formatterBehavior     = .behavior10_4
        numberFormatter.numberStyle           = .decimal
        numberFormatter.maximumFractionDigits = maxDigits
        numberFormatter.minimumFractionDigits = minDigits
        numberFormatter.roundingMode          = roundingMode
        if let numberString                   = numberFormatter.string(from: number) {
            return numberString
        }
        return ""
    }
    
    //.plain：四色五入
    class func ks_format(value: String?, maxDigits: Int16, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> String {
        let number        = NSDecimalNumber.init(string: value)
        let numberHandler = NSDecimalNumberHandler(roundingMode: roundingMode, scale: maxDigits, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        return number.rounding(accordingToBehavior: numberHandler).stringValue
    }
    
    /// 加法
    ///
    /// - Parameters:
    ///   - summand: 被加数
    ///   - addend: 加数
    ///   - maxDigits: 最大小数点位数
    ///   - minDigits: 最少小数点位数
    ///   - roundingMode: 舍入模式
    /// - Returns: 结果
    class func ks_adding(summand: String?, addend: String?, maxDigits: Int = 8, minDigits: Int = 2, roundingMode: NumberFormatter.RoundingMode = .down) -> String {
        var summandValue = summand
        var addendValue  = addend

        if summandValue?.isEmpty ?? false {
            summandValue = "0"
        }
        if addendValue?.isEmpty ?? false  {
            addendValue = "0"
        }

        let summandMumber = NSDecimalNumber.init(string: summandValue)
        let addendMumber  = NSDecimalNumber.init(string: addendValue)
        let result        = summandMumber.adding(addendMumber)
        return ks_format(value: result.stringValue, maxDigits: maxDigits, minDigits: minDigits, roundingMode: roundingMode)
    }
    
    /// 减法
    ///
    /// - Parameters:
    ///   - minuend: 被减数
    ///   - subtracted: 减数
    ///   - maxDigits: 最大小数点位数
    ///   - minDigits: 最少小数点位数
    ///   - roundingMode:舍入模式
    /// - Returns: 结果
    class func ks_subtracting(minuend: String?,subtracted: String?, maxDigits: Int = 8, minDigits: Int = 2, roundingMode: NumberFormatter.RoundingMode = .down) -> String {
        var minuendValue = minuend
        var subtractedValue = subtracted
        
        if minuendValue?.isEmpty ?? false {
            minuendValue = "0"
        }
        if subtractedValue?.isEmpty ?? false {
            subtractedValue = "0"
        }
        
        let minuendMumber    = NSDecimalNumber.init(string: minuendValue)
        let subtractedMumber = NSDecimalNumber.init(string: subtractedValue)
        let result           = minuendMumber.subtracting(subtractedMumber)
        return ks_format(value: result.stringValue, maxDigits: maxDigits, minDigits: minDigits, roundingMode: roundingMode)
    }
    
    /// 除法
    ///
    /// - Parameters:
    ///   - dividend: 被除数
    ///   - divisor: 除数
    ///   - maxDigits: 最大小数点位数
    ///   - minDigits: 最少小数点位数
    ///   - roundingMode: 舍入模式
    /// - Returns: 结果
    class func ks_dividing(dividend: String?, divisor: String?, maxDigits: Int = 8, minDigits: Int = 2, roundingMode: NumberFormatter.RoundingMode = .down) -> String {
        var dividendValue = dividend
        var divisorValue  = divisor
        
        if dividendValue?.isEmpty ?? false{
            dividendValue = "0"
        }
        
        if Double(divisorValue ?? "1") == 0 {
            divisorValue = "1"
        }
    
        let dividendMumber = NSDecimalNumber.init(string: dividendValue)
        let divisorMumber  = NSDecimalNumber.init(string: divisorValue)
        let result         = dividendMumber.dividing(by: divisorMumber)
        return ks_format(value: result.stringValue, maxDigits: maxDigits, minDigits: minDigits, roundingMode: roundingMode)
    }
    
    ///乘法
    class func ks_multiplying(multiplicand: String?,multiplier: String?, maxDigits: Int = 8, minDigits: Int = 2, roundingMode: NumberFormatter.RoundingMode = .down) -> String {
        var multiplicandValue = multiplicand
        var multiplierValue   = multiplier
        
        if multiplicandValue?.isEmpty ?? false {
            multiplicandValue = "0"
        }
        if multiplierValue?.isEmpty ?? false {
            multiplierValue = "0"
        }
        
        let multiplicandMumber = NSDecimalNumber.init(string: multiplicandValue)
        let multiplierMumber   = NSDecimalNumber.init(string: multiplierValue)
        let result             = multiplicandMumber.dividing(by: multiplierMumber)
        return ks_format(value: result.stringValue, maxDigits: maxDigits, minDigits: minDigits, roundingMode: roundingMode)
    }
}
