//
//  Date+KSExtensions.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/27.
//  Copyright © 2019 saeipi. All rights reserved.
//

import Foundation

let KS_Date_Formatter                    = DateFormatter()

extension Date {
    
    static func ks_formatTimeStamp(timeStamp:Int,format:String) -> String {
        let confromTimesp            = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        KS_Date_Formatter.dateFormat = format
        return KS_Date_Formatter.string(from: confromTimesp)
    }
    
    static func ks_update(format:String) {
        KS_Date_Formatter.dateFormat = format
    }
    
    static func ks_formatTimeStamp(timeStamp:Int) -> String {
        let confromTimesp = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        return KS_Date_Formatter.string(from: confromTimesp)
    }
    
    /// 把时间戳转换为用户格式时间
    ///
    /// - Parameters:
    ///   - timestamp: 时间戳
    ///   - format: 格式
    /// - Returns: 时间
    static func ks_getTimeByStamp(_ timestamp: Int, format: String) -> String {
        var time = ""
        if (timestamp == 0) {
            return ""
        }
        let confromTimesp            = Date(timeIntervalSince1970: TimeInterval(timestamp))
        //let formatter = DateFormatter()
        KS_Date_Formatter.dateFormat = format
        time                         = KS_Date_Formatter.string(from: confromTimesp)
        return time;
    }
    
    static func ks_toTimeStamp(time: String ,format:String) -> Int {
        KS_Date_Formatter.dateFormat = format
        let last = KS_Date_Formatter.date(from: time)
        let timeStamp = last?.timeIntervalSince1970
        return Int(timeStamp!)
    }
}
