//
//  UIViewController+KSExtensions.swift
//  WonWallet
//
//  Created by saeipi on 2019/9/5.
//  Copyright © 2019 worldopennetwork. All rights reserved.
//

import UIKit

extension UIViewController {
    func ks_navigationHeight() -> CGFloat {
        if let _height = self.navigationController?.navigationBar.frame.size.height {
            return UIApplication.shared.statusBarFrame.height + _height
        }
        return 64
    }
    
    func ks_tabBarHeight() -> CGFloat {
        if let _height = self.tabBarController?.tabBar.frame.size.height {
            return _height
        }
        return 49
    }
}
