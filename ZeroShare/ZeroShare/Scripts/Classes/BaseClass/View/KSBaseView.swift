//
//  KSBaseView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/6/10.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

@objc public protocol KSViewDelegate : NSObjectProtocol {
    @objc optional func ksviewTouche(view: UIView, identifier: String?)
    @objc optional func ksviewCallback(view: UIView, data: Any?, identifier: String?)
}
class KSBaseView: UIView {
    
    weak var theDelegate:KSViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }
    
    private func initializeView() {
        configureDefaultValue()
        createChildViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureDefaultValue() {
        
    }
    
    func createChildViews() {
        
    }
    
    @objc func showKit() {
        if self.isHidden {
            self.isHidden = false
        }
    }
    
    @objc func hiddenKit() {
        if self.isHidden == false {
            self.isHidden = true
        }
    }
    
}
