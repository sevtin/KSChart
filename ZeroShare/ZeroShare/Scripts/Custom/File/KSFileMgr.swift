//
//  KSFileMgr.swift
//  ZeroShare
//
//  Created by saeipi on 2019/5/31.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit
import SwiftyJSON

class KSFileMgr: NSObject {
    
    /// 读取本地的文件
    ///
    /// - Parameters:
    ///   - fileName: 文件名称
    ///   - type: 文件类型
    /// - Returns: 文件的数据
    static func readLocalData(fileName:String,type:String) ->Any? {
        //读取本地的文件
        let path = Bundle.main.path(forResource: fileName, ofType: type);
        let url = URL(fileURLWithPath: path!)
        
        do {
            /*
             * try 和 try! 的区别
             * try 发生异常会跳到catch代码中
             * try! 发生异常程序会直接crash
             */
            let data = try Data.init(contentsOf: url, options: .alwaysMapped)
            let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            return jsonData;
        } catch let error {
            return error.localizedDescription;
        }
    }
    
    static func readJsonData(fileName:String,type:String) ->JSON {
        //读取本地的文件
        let path        = Bundle.main.path(forResource: fileName, ofType: type);
        let content     = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        do {
            return try JSON(data: jsonContent)

        } catch {
            return JSON()
        }
    }
}
