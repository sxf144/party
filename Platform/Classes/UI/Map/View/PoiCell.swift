//
//  RecommendController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AMapSearchKit


class PoiCell: UITableViewCell {
    
    var RightToolWidth = 44
    var item: AMapPOI?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.selectionStyle = .none
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 名称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium16
        label.textColor = UIColor.ls_color("#333333")
        label.text = String(item?.name ?? "")
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    // 地址
    fileprivate lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = String(item?.address ?? "")
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    
}

extension PoiCell {
    
    func configure(with citem: AMapPOI!) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 名称
        nameLabel.text = item?.name
        nameLabel.sizeToFit()
        
        // 地址
        addressLabel.text = item?.address
        addressLabel.sizeToFit()
    }
    
}

extension PoiCell{
    fileprivate func setupUI(){
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(addressLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        addressLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.left.equalTo(nameLabel)
            make.right.equalTo(nameLabel)
        }
        
    }
}

