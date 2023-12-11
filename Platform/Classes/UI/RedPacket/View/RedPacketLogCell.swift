//
//  RedPacketLogCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation


class RedPacketLogCell: UITableViewCell {
    
    let leftMargin: CGFloat = 16.0
    let avatarHeight: CGFloat = 40
    var item: RedPacketFetchItem = RedPacketFetchItem()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 头像
    fileprivate lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = avatarHeight/2
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderAvatar)
        return imageView
    }()
    
    // 昵称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#333333")
        label.text = ""
        label.sizeToFit()
        return label
    }()
    
    // 金额
    fileprivate lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
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
    
    // 手气最佳
    fileprivate lazy var maxTipLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer10
        label.textColor = UIColor.ls_color("#FE9C5B")
        label.text = "手气最佳"
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
}

extension RedPacketLogCell {
    
    func configure(with citem: RedPacketFetchItem) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 头像
        avatar.kf.setImage(with: URL(string: item.portrait), placeholder: PlaceHolderAvatar)
        
        // 昵称
        nameLabel.text = item.nick
        nameLabel.sizeToFit()
        
        // 金额
        amountLabel.text = String(format: "%.2f元", Double(item.amount)/100)
        amountLabel.sizeToFit()
        
        // 时间
        timeLabel.text = item.fetchTime
        timeLabel.sizeToFit()
        
        // 判断手气最佳是否展示
        maxTipLabel.isHidden = !item.isMax
    }
}

extension RedPacketLogCell {
    
    fileprivate func setupUI(){
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(maxTipLabel)
        
        avatar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: avatarHeight, height: avatarHeight))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(10)
            make.top.equalToSuperview().offset(10)
        }
        
        amountLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftMargin)
            make.centerY.equalTo(nameLabel)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        maxTipLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftMargin)
            make.centerY.equalTo(timeLabel)
        }
    }
}

