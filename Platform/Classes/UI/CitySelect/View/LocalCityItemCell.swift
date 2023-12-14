//
//  LocalCityItemCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit


class LocalCityItemCell: UITableViewCell {
    
    /// 回调闭包
    public var citySelectBlock: ((_ cityItem:CityItem) -> ())?
    var item: CityItem = CityItem()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        self.selectionStyle = .none
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 当前城市
    fileprivate lazy var cityBtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(clickCityBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 图标
    fileprivate lazy var locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "icon_location4")
        return imageView
    }()
    
    // 名称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#333333")
        label.text = item.name
        label.sizeToFit()
        return label
    }()
    
    // 重新定位
    fileprivate lazy var relocationBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_relocation"), for: .normal)
        button.ls_layout(.imageLeft, padding: 4)
        button.setTitle("重新定位", for: .normal)
        button.setTitleColor(UIColor.ls_color("#FE9C5B"), for: .normal)
        button.titleLabel?.font = kFontRegualer12
        button.addTarget(self, action: #selector(clickRelocationBtn(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
}

extension LocalCityItemCell {
    
    func configure(_ item: CityItem) {
        
        LSLog("configure")
        self.item = item
        
        // 名称
        nameLabel.text = item.name
        nameLabel.sizeToFit()
    }
    
    @objc func clickCityBtn(_ sender: UIButton) {
        LSLog("clickCityBtn")
        if let citySelectBlock = citySelectBlock {
            citySelectBlock(item)
        }
    }
    
    @objc func clickRelocationBtn(_ sender: UIButton) {
        LSLog("clickRelocationBtn")
        
    }
}

extension LocalCityItemCell {
    
    fileprivate func setupUI() {
        contentView.addSubview(cityBtn)
        cityBtn.addSubview(locationIcon)
        cityBtn.addSubview(nameLabel)
        contentView.addSubview(relocationBtn)
        
        cityBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        locationIcon.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(22)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-4)
        }
        
        relocationBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalToSuperview()
        }
    }
}

