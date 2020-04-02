//
//  KSSpeedy.swift
//  ZeroShare
//
//  Created by saeipi on 2019/9/16.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSSpeedy: NSObject {
    
    /// 添加横线
    ///
    /// - Parameters:
    ///   - toView: 添加到的父视图
    ///   - color: 颜色
    ///   - leftOffset: 左边偏移,例如10
    ///   - rightOffset: 右边边偏移,例如-10
    ///   - height: 线条高度
    ///   - isTop: 是否是顶部线
    class func ks_addHorizontalLine(toView: UIView, color: UIColor, leftOffset: CGFloat, rightOffset: CGFloat, height: CGFloat, isTop: Bool, verticalOffset: CGFloat = 0) -> UIView {
        let underline             = UIView.init(color: color)
        toView.addSubview(underline)
        underline.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftOffset)
            make.right.equalToSuperview().offset(rightOffset)
            make.height.equalTo(height)
            if isTop {
                make.top.equalToSuperview().offset(verticalOffset)
            }
            else{
                make.bottom.equalToSuperview().offset(verticalOffset)
            }
        }
        return underline
    }
}
