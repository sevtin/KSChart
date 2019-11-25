//
//  KSTaiPickerView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

protocol TaiPickerViewDelegate : NSObjectProtocol {
    func taiPickerViewCallback(taiPickerView: Any, menuGroup: KSTaiMenuGroup, isOpeneye: Bool)
    func taiPickerViewCallback(taiPickerView: Any, menuInfo: KSChartMenuInfo, groupType: KSSectionValueType)
}
class KSTaiPickerView: KSBubbleMenuView {

    var configure: KSTaiMenuConfigure?
    private var tableView: KSTableView!
    weak var delegate: TaiPickerViewDelegate?

    override func createChildViews() {
        tableView                 = KSTableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.dataSource      = self
        tableView.delegate        = self
        tableView.separatorStyle  = UITableViewCell.SeparatorStyle.none
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        if #available(iOS 11.0, *){
            tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        self.addSubview(tableView)
        /*
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
         */
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(9)
            make.bottom.equalToSuperview().offset(-4)
        }
    }
}


extension KSTaiPickerView: UITableViewDataSource, UITableViewDelegate, TaiPickerCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.configure?.groups.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell               = KSTaiPickerCell.initialize(tableView: tableView)
        cell.delegate          = self
        cell.update(menuGroup: self.configure?.groups[indexPath.row])
        cell.lineView.isHidden = (indexPath.row == ((self.configure?.groups.count ?? 0) - 1))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.configure?.groups[indexPath.row].kitHeight ?? 0
    }
    
    // MARK: - KSTableViewCellDelegate
    func taiPickerCellCallback(taiPickerCell: Any, menuGroup: KSTaiMenuGroup, isOpeneye: Bool) {
        self.delegate?.taiPickerViewCallback(taiPickerView: self, menuGroup: menuGroup, isOpeneye: isOpeneye)
    }
    func taiPickerCellCallback(taiPickerView: Any, menuInfo: KSChartMenuInfo, groupType: KSSectionValueType) {
        self.delegate?.taiPickerViewCallback(taiPickerView: self, menuInfo: menuInfo, groupType: groupType)
    }
}

protocol TaiPickerCellDelegate : NSObjectProtocol {
    func taiPickerCellCallback(taiPickerCell: Any, menuGroup: KSTaiMenuGroup, isOpeneye: Bool)
    func taiPickerCellCallback(taiPickerView: Any, menuInfo: KSChartMenuInfo, groupType: KSSectionValueType)
}
let taiPickerCellIdentifier = "KSTaiPickerCellIdentifier"
class KSTaiPickerCell: KSBaseTableViewCell {
    
    var menuGroup: KSTaiMenuGroup?
    private var collectionView: UICollectionView!
    
    private var eyeBtn: UIButton!
    var lineView: UIView!
    weak var delegate: TaiPickerCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func initialize(tableView:UITableView) -> KSTaiPickerCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: taiPickerCellIdentifier)
        if cell == nil {
            cell                  = KSTaiPickerCell.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: taiPickerCellIdentifier)
            cell?.selectionStyle  = .none
            cell?.backgroundColor = UIColor.clear
        }
        return cell as! KSTaiPickerCell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    /// 初始化数据和视图
    override func createChildViews() {
        let flowLayout                     = UICollectionViewFlowLayout.init()
        let CW                             = self.ks_screenWidth() - KS_Const_Point32 - KS_Const_Point24
        let IW                             = CW / 5
        let IH: CGFloat                    = 40

        flowLayout.itemSize                = CGSize(width: IW, height: IH)
        flowLayout.minimumLineSpacing      = 0//同一组当中，行与行之间的最小行间距，但是不同组之间的不同行cell不受这个值影响。
        flowLayout.minimumInteritemSpacing = 0//同一行的cell中互相之间的最小间隔，设置这个值之后，那么cell与cell之间至少为这个值
        flowLayout.scrollDirection         = .vertical

        collectionView                     = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.delegate            = self
        collectionView.dataSource          = self
        collectionView.backgroundColor     = UIColor.clear
        collectionView.isScrollEnabled     = false
        self.addSubview(collectionView)

        collectionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(KS_Const_Point24)
            make.width.equalTo(CW - IW)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        collectionView.register(KSChartMenuCell.self, forCellWithReuseIdentifier: taiPickerCellIdentifier)

        eyeBtn                             = UIButton.init(normalImage: "ic_chart_closed_eyes", selectedImage: "ic_chart_open_eyes")
        self.addSubview(eyeBtn)
        eyeBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.width.equalTo(IW)
            make.height.equalTo(IH)
            make.centerY.equalToSuperview()
        }
        eyeBtn.ks_addTarget(self, action: #selector(onEyeClick(button:)))

        lineView                           = UIView.init(color: UIColor.ks_rgba(235, 236, 237))
        self.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(KS_Const_Point16)
            make.right.equalToSuperview().offset(-KS_Const_Point16)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc func onEyeClick(button: UIButton) {
        if button.isSelected == false {
            return
        }
        button.isSelected      = false
        self.menuGroup?.isOpen = false

        guard let _menuGroup = menuGroup else {
            return
        }
        
        for item in _menuGroup.datas {
            item.isSelectd = false
        }
        collectionView.reloadData()
        
        self.delegate?.taiPickerCellCallback(taiPickerCell: self, menuGroup: _menuGroup, isOpeneye: button.isSelected)
    }
    
    func update(menuGroup: KSTaiMenuGroup?) {
        self.menuGroup = menuGroup
        eyeBtn.isSelected = menuGroup?.isOpen ?? false
        self.collectionView.reloadData()
    }
}

extension KSTaiPickerCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuGroup?.datas.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = self.menuGroup?.datas[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: taiPickerCellIdentifier, for: indexPath)
        if let _cell = cell as? KSChartMenuCell {
            _cell.updateMenu(info: data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                guard let _menuGroup = menuGroup else {
            return
        }
        for item in _menuGroup.datas {
            item.isSelectd = false
        }
        let selectItem         = _menuGroup.datas[indexPath.item]
        selectItem.isSelectd   = true
        self.eyeBtn.isSelected = true;
        self.delegate?.taiPickerCellCallback(taiPickerView: self, menuInfo: selectItem, groupType: _menuGroup.type)
        collectionView.reloadData()
    }
}

class KSTaiMenuConfigure: NSObject {
    var groups            = [KSTaiMenuGroup]()
    var kitHeight:CGFloat = 0
    
    class func defaultConfigure() -> KSTaiMenuConfigure {
        let configure       = KSTaiMenuConfigure.init()
        configure.groups    += KSTaiMenuGroup.defaultGroup()
        for group in configure.groups {
            configure.kitHeight += group.kitHeight
        }
        configure.kitHeight += 13
        return configure
    }
}

class KSTaiMenuGroup: NSObject {
    var datas                   = [KSChartMenuInfo]()
    var kitHeight:CGFloat       = 0
    var type:KSSectionValueType = KSSectionValueType.master
    var isOpen: Bool            = false

    class func defaultGroup() -> [KSTaiMenuGroup] {
        let group1           = KSTaiMenuGroup.init()

        let go_info1         = KSChartMenuInfo.init()
        go_info1.displayText = "MA"
        go_info1.textAlignment = .left
        go_info1.identifier  = KSSeriesKey.ma
        
        let go_info2         = KSChartMenuInfo.init()
        go_info2.displayText = "EMA"
        go_info2.textAlignment = .left
        go_info2.identifier  = KSSeriesKey.ema

        let go_info3         = KSChartMenuInfo.init()
        go_info3.displayText = "BOOL"
        go_info3.textAlignment = .left
        go_info3.identifier  = KSSeriesKey.boll
        group1.datas         += [go_info1, go_info2, go_info3]
        group1.kitHeight     = ceil(CGFloat(group1.datas.count) / 4.0) * 40

        let group2           = KSTaiMenuGroup.init()
        group2.type          = KSSectionValueType.assistant
        let gt_info1         = KSChartMenuInfo.init()
        gt_info1.displayText = "MACD"
        gt_info1.textAlignment = .left
        gt_info1.identifier  = KSSeriesKey.macd
        
        let gt_info2         = KSChartMenuInfo.init()
        gt_info2.displayText = "KDJ"
        gt_info2.textAlignment = .left
        gt_info2.identifier  = KSSeriesKey.kdj
        
        let gt_info3         = KSChartMenuInfo.init()
        gt_info3.displayText = "RSI"
        gt_info3.textAlignment = .left
        gt_info3.identifier  = KSSeriesKey.rsi
        
        let gt_info4         = KSChartMenuInfo.init()
        gt_info4.displayText = "BOOL"
        gt_info4.textAlignment = .left
        gt_info4.identifier  = KSSeriesKey.boll
        
        group2.datas         += [gt_info1, gt_info2, gt_info3, gt_info4]
        group2.kitHeight     = ceil(CGFloat(group2.datas.count) / 4.0) * 40
        
        let masterTai = KSSingleton.shared.indexConfigure.masterTai
        if let _masterTai = masterTai {
            for data in group1.datas {
                if _masterTai == data.identifier {
                    data.isSelectd = true
                    group1.isOpen  = true
                }
                else{
                    data.isSelectd = false
                }
            }
        }
        
        let assistTai = KSSingleton.shared.indexConfigure.assistTai
        for data in group2.datas {
            if assistTai == data.identifier {
                data.isSelectd = true
                group2.isOpen  = true
            }
            else{
                data.isSelectd = false
            }
        }
        return [group1, group2]
    }
}
