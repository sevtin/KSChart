//
//  KSLanguageHelper.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/29.
//  Copyright © 2019 saeipi. All rights reserved.
//

import Foundation

class KSLanguageHelper: NSObject {

    let def = UserDefaults.standard
    var bundle : Bundle?
    
    class func localizable(key: String) -> String {
        return KSSingleton.shared.languageHelper.getUserStr(key: key)
    }
    
    ///根据用户设置的语言类型获取字符串
    func getUserStr(key: String) -> String {
        // 获取本地化字符串，字符串根据手机系统语言自动切换
        let str = NSLocalizedString(key, comment: "default")
        return str
    }
    
    ///根据app内部设置的语言类型获取字符串
    func getAppStr(key: String) -> String {
        // 获取本地化字符串，字符串会根据app系统语言自动切换
        let str = NSLocalizedString(key, tableName: "Localizable", bundle: KSSingleton.shared.languageHelper.bundle!, value: "default", comment: "default")
        return str
    }
    
    ///设置app语言环境
    func setLanguage(langeuage: String) {
        var str = langeuage
        //如果获取不到系统语言，就把app语言设置为首选语言
        if langeuage == "" {
            //获取系统首选语言顺序
            let languages:[String] = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
            let str2:String = languages[0]
            //如果首选语言是中文，则设置APP语言为中文，否则设置成英文
            if ((str2=="zh-Hans-CN")||(str2=="zh-Hans"))
            {
                str = "zh-Hans"
            }else
            {
                str="en"
            }
        }
        //语言设置
        def.set(str, forKey: "langeuage")
        def.synchronize()
        //根据str获取语言数据（因为设置了本地化，所以项目中有en.lproj和zn-Hans.lproj）
        let path = Bundle.main.path(forResource:str , ofType: "lproj")
        bundle = Bundle(path: path!)
    }
}
