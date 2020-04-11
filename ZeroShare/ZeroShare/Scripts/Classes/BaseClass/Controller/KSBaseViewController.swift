//
//  KSBaseViewController.swift
//  ZeroShare
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit
import SwiftyJSON

class KSBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 249 / 255.0, green: 249 / 255.0, blue: 249 / 255.0, alpha: 1.0)
        self.title = NSStringFromClass(type(of: self))
    }
    
    func getChartCandles() -> [KSChartItem] {
        let fileData = KSFileMgr.readLocalData(fileName: "candles", type: "txt")
        guard let _array = fileData as? Array<Array<Any>> else {
            return [KSChartItem]()
        }
        var candles: [KSChartItem] = [KSChartItem]()
        for array in _array {
            let info        = KSChartItem()
            info.time       = (array[0] as! NSNumber).intValue
            info.lowPrice   = CGFloat((array[1] as! NSNumber).floatValue)
            info.highPrice  = CGFloat((array[2] as! NSNumber).floatValue)
            info.openPrice  = CGFloat((array[3] as! NSNumber).floatValue)
            info.closePrice = CGFloat((array[4] as! NSNumber).floatValue)
            info.vol        = CGFloat((array[5] as! NSNumber).floatValue)
            candles.append(info)
        }
        return candles
    }
}
