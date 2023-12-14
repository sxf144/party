//
//  HotCityItemCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit


class HotCityItemCell: UITableViewCell {
    
    /// 回调闭包
    public var citySelectBlock: ((_ cityItem:CityItem) -> ())?
    let btnTagStart: Int = 1011
    let btnWidth: CGFloat = (kScreenW - 16*2 - 8*2)/3
    let btnHeight: CGFloat = 34
    let MaxCount: Int = 6
    var items: [CityItem] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        self.selectionStyle = .none
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HotCityItemCell {
    
    func configure(_ items: [CityItem]) {
        
        LSLog("configure items count:\(items.count)")
        self.items = items
        
        for i in 0 ..< MaxCount {
            let button: UIButton = contentView.viewWithTag(btnTagStart+i) as! UIButton
            if i < self.items.count {
                let item = self.items[i]
                button.isHidden = false
                button.setTitle(item.name, for: .normal)
            } else {
                button.isHidden = true
            }
        }
    }
    
    @objc func clickCityBtn(_ sender: UIButton) {
        LSLog("clickCityBtn")
        let index = sender.tag - btnTagStart
        if let citySelectBlock = citySelectBlock, index >= 0, index < items.count {
            citySelectBlock(items[index])
        }
    }
}

extension HotCityItemCell {
    
    fileprivate func setupUI() {
        
        // 创建city
        setupCityItems()
    }
    
    fileprivate func setupCityItems() {
        
        for i in 0 ..< MaxCount {
            let button = UIButton()
            button.backgroundColor = UIColor.ls_color("#F8F8F8")
            button.titleLabel?.font = kFontRegualer14
            button.setTitleColor(UIColor.ls_color("#333333"), for: .normal)
            button.layer.cornerRadius = 2
            button.tag = btnTagStart + i
            button.addTarget(self, action: #selector(clickCityBtn(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            
            let y = i/3*40
            let x = (i%3)*(Int(btnWidth)+8)+16
            button.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: btnWidth, height: btnHeight))
                make.top.equalToSuperview().offset(y)
                make.left.equalToSuperview().offset(x)
            }
        }
    }
}

