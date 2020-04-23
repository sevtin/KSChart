//
//  KSMarketTradeCell.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/28.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

let KSMarketTradeCellIdentifier = "KSMarketTradeCellIdentifier"

class KSMarketTradeCell: KSBaseTableViewCell {
    var labelView: KSMultipleLabelView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func initialize(tableView:UITableView) -> KSMarketTradeCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: KSMarketTradeCellIdentifier)
        if cell == nil {
            cell                 = KSMarketTradeCell.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: KSMarketTradeCellIdentifier)
            cell?.selectionStyle = .none
        }
        return cell as! KSMarketTradeCell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    /// 初始化默认值
    override func defaultValue() {
        
    }
    
    /// 创建子控件
    override func createChildViews() {
        labelView = KSMultipleLabelView.init(textColor: UIColor.ks_rgba(41, 44, 51),
                                             textFont: KS_Const_Font_Normal_14,
                                             alignments: [NSTextAlignment.left,NSTextAlignment.center,NSTextAlignment.right,NSTextAlignment.right],
                                             count: 4,
                                             widthScales: [0.23,0.13,0.32,0.32],
                                             margin: KS_Const_Point16,
                                             padding: KS_Const_Point04)
        if let _font = KS_Const_Font_HelveticaNeue_14 {
            labelView.update(font: _font)
        }
        self.addSubview(labelView)
        
        labelView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    func update(detail: KSTradeDetail) {
        labelView.update(attributedTexts: detail.displayTexts)
        //labelView.update(texts: detail.displayTexts)
        //labelView.update(textColor: detail.textColor, index: 1)
        //labelView.update(textColor: detail.textColor, index: 2)
    }
}
