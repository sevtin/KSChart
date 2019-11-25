//
//  KSTimePickerView.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/23.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

@objc protocol TimePickerViewDelegate : NSObjectProtocol {
    @objc optional func timePickerViewCallback(timePickerView: Any, value: KSChartMenuInfo)
}
/// 时间选择
class KSTimePickerView: KSBubbleMenuView {
    
    private let timeMenuCellIdentifier = "KSTimeMenuCellIdentifier"
    private var collectionView: UICollectionView!
    
    var configure: KSTimeMenuConfigure?
    weak var delegate: TimePickerViewDelegate?

    override func createChildViews() {
        let flowLayout                     = UICollectionViewFlowLayout.init()
        flowLayout.itemSize                = CGSize(width: (self.frame.size.width - 32)/5, height: 40)
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
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(9)
            make.bottom.equalToSuperview().offset(-4)
        }
        collectionView.register(KSChartMenuCell.self, forCellWithReuseIdentifier: timeMenuCellIdentifier)
    }
}

extension KSTimePickerView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return configure?.datas.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = self.configure?.datas[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timeMenuCellIdentifier, for: indexPath)
        if let _cell = cell as? KSChartMenuCell {
            _cell.updateMenu(info: data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.hiddenKit()
        guard let _datas = configure?.datas else {
            return
        }
        for item in _datas {
            item.isSelectd = false
        }
        let item                                 = _datas[indexPath.item]
        item.isSelectd                           = true
        KSSingleton.shared.indexConfigure.timeID = item.ID
        self.delegate?.timePickerViewCallback?(timePickerView: self, value: item)
        collectionView.reloadData()
    }
}

class KSTimeMenuConfigure: NSObject {
    var datas              = [KSChartMenuInfo]()
    var kitHeight: CGFloat = 0
    var selectdInfo: KSChartMenuInfo!

    class func defaultConfigure() -> KSTimeMenuConfigure {
        let configure      = KSTimeMenuConfigure.init()
        let timeID         = KSSingleton.shared.indexConfigure.timeID
        for i in 1...12 {
            let dict = KSSingleton.shared.indexConfigure.timeDict
            let info          = KSChartMenuInfo.init()
            info.identifier   = dict[i]?.0 ?? ""
            info.displayText  = dict[i]?.1 ?? ""
            info.ID           = i
            if i == 0 {
                info.isFlag       = true
            }
            
            if info.ID == timeID {
                info.isSelectd        = true
                configure.selectdInfo = info
            }
            else{
                info.isSelectd = false
            }
            configure.datas.append(info)
        }
        configure.kitHeight = ceil(CGFloat(configure.datas.count)/5.0) * 40 + 13
        return configure
    }
}

