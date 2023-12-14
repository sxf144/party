//
//  CityItemCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit


class CityItemCell: UITableViewCell {
    
    let leftMargin: CGFloat = 16
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
    
    // 名称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer14
        label.textColor = UIColor.ls_color("#333333")
        label.text = ""
        label.sizeToFit()
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        return label
    }()
}

extension CityItemCell {
    
    func configure(_ item: CityItem) {
        LSLog("configure item:\(String(describing: item))")
        self.item = item
        
        // 名称
        nameLabel.text = item.name
        nameLabel.sizeToFit()
    }
}

extension CityItemCell {
    
    fileprivate func setupUI() {
        
        contentView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }
}

