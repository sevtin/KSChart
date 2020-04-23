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
            info.time       = array[0] as! Int
            info.lowPrice   = array[1] as! CGFloat
            info.highPrice  = array[2] as! CGFloat
            info.openPrice  = array[3] as! CGFloat
            info.closePrice = array[4] as! CGFloat
            info.vol        = array[5] as! CGFloat
            candles.append(info)
        }
        return candles
    }
}
