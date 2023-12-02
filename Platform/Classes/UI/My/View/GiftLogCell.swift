//
//  GiftLogCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation


class GiftLogCell: UITableViewCell {
    
    let xMargin: CGFloat = 14.0
    let yMargin: CGFloat = 14.0
    var item: GiftItem = GiftItem()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .white
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 礼物图标
    fileprivate lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderSmall)
        return imageView
    }()
    
    // 礼物名称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#333333")
        label.text = ""
        label.sizeToFit()
        return label
    }()
    
    // 时间
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#999999")
        label.text = ""
        label.sizeToFit()
        return label
    }()
}

extension GiftLogCell {
    
    func configure(with citem: GiftItem) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 图标
        icon.kf.setImage(with: URL(string: item.icon), placeholder: PlaceHolderSmall)
        
        // 名称
        nameLabel.text = item.name
        nameLabel.sizeToFit()
        
        // 时间
        timeLabel.text = item.time
        timeLabel.sizeToFit()
    }
}

extension GiftLogCell {
    fileprivate func setupUI() {
        
        contentView.addSubview(icon)
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        
        icon.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(icon.snp.right).offset(10)
            make.top.equalToSuperview().offset(yMargin)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(icon.snp.right).offset(10)
            make.bottom.equalToSuperview().offset(-yMargin)
        }
    }
}

