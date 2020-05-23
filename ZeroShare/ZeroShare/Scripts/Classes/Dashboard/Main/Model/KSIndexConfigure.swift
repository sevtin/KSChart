//
//  KSIndexConfigure.swift
//  WonWallet
//
//  Created by saeipi on 2019/9/9.
//  Copyright © 2019 worldopennetwork. All rights reserved.
//

import UIKit

struct KSUserDefault {
    static let master = "ks_key_master"
    static let assist = "ks_key_assist"
    static let time   = "ks_key_timeID"
}

class KSIndexConfigure: NSObject {
    var masterTai: String? {
        didSet {
            if masterTai == nil {
                KSIndexConfigure.removeString(key: KSUserDefault.master)
            }
            else{
                KSIndexConfigure.writeString(text: masterTai!, key: KSUserDefault.master)
            }
        }
    }
    var assistTai: String = KSSeriesKey.volume {
        didSet{
            KSIndexConfigure.writeString(text: assistTai, key: KSUserDefault.assist)
        }
    }

    var timeID: Int = 0 {
        didSet {
            KSIndexConfigure.writeInt(num: timeID, key: KSUserDefault.time)
        }
    }
    
    var isChart:Bool {
        get {
            return (timeID != 1)
        }
    }
    
    var chartType: String {
        get {
            return timeDict[timeID]?.0 ?? "1d"
        }
    }
    
    override init() {
        super.init()
        self.masterTai = KSIndexConfigure.readString(key: KSUserDefault.master)
        self.assistTai = KSIndexConfigure.readString(key: KSUserDefault.assist) ?? KSSeriesKey.volume
        self.timeID    = KSIndexConfigure.readInt(key: KSUserDefault.time)
        if self.timeID == 0 {
            self.timeID = 11
        }
    }
    
    lazy var timeDict:[Int:(String,String,Int)] = {
        let timeDict = [1:("1m","ks_app_global_text_line",60),
                        2:("1m","ks_app_global_text_1m",60),
                        3:("5m","ks_app_global_text_5m",60*5),
                        4:("15m","ks_app_global_text_15m",60*15),
                        5:("30m","ks_app_global_text_30m",60*30),
                        6:("1h","ks_app_global_text_1h",60*60),
                        7:("2h","ks_app_global_text_2h",60*120),
                        8:("4h","ks_app_global_text_4h",60*240),
                        9:("6h","ks_app_global_text_6h",60*360),
                        10:("12h","ks_app_global_text_12h",60*720),
                        11:("1d","ks_app_global_text_1d",60*1440),
                        12:("1w","ks_app_global_text_1w",60*10080)]
        return timeDict
    }()
}

extension KSIndexConfigure {
    class func writeString(text: String, key: String) {
        UserDefaults.standard.setValue(text, forKey: self.userKey(key: key))
    }
    
    class func readString(key: String) -> String? {
        return UserDefaults.standard.object(forKey: self.userKey(key: key)) as? String
    }
    
    class func removeString(key: String){
        UserDefaults.standard.removeObject(forKey: self.userKey(key: key))
    }
    
    class func writeBool(isTrue: Bool, key: String) {
        UserDefaults.standard.set(isTrue, forKey: self.userKey(key: key))
    }
    
    class func readBool(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: self.userKey(key: key))
    }
    
    class func writeInt(num: Int, key: String) {
        UserDefaults.standard.set(num, forKey: self.userKey(key: key))
    }
    
    class func readInt(key: String) -> Int {
        return UserDefaults.standard.integer(forKey: self.userKey(key: key))
    }
    
    class func userKey(key: String) -> String {
        return "userid" + key
    }
}
