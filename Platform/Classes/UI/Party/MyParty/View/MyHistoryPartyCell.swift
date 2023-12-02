//
//  MyPartyCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation


class MyHistoryPartyCell: UITableViewCell {
    
    let itemHeight = 130
    let leftMargin: CGFloat = 16.0
    var item: PartyItem = PartyItem()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = UIColor.ls_color("#F8F8F8")
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // split
    fileprivate lazy var splitLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer14
        label.textColor = UIColor.ls_color("#d6d6d6")
        label.text = "———— 以下以为历史 ————"
        label.sizeToFit()
        return label
    }()
    
    // bg
    fileprivate lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    // 桔封面
    fileprivate lazy var cover: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderSmall)
        return imageView
    }()
    
    // 蒙层
    fileprivate lazy var coverMask: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ls_color("#000000", alpha: 0.6)
        view.isHidden = true
        return view
    }()
    
    // 蒙层内容
    fileprivate lazy var maskLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer14
        label.textColor = .white
        label.text = "已解散"
        label.sizeToFit()
        return label
    }()
    
    // 桔名称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium16
        label.textColor = UIColor.ls_color("#333333")
        label.text = " "
        label.sizeToFit()
        return label
    }()
    
    // 桔人数
    fileprivate lazy var personLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#FE9C5B")
        label.text = " "
        label.sizeToFit()
        return label
    }()
    
    // 桔时间
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#333333")
        label.text = " "
        label.sizeToFit()
        return label
    }()
    
    // 桔地址
    fileprivate lazy var localIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_location1")
        return imageView
    }()
    
    fileprivate lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = ""
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
}

extension MyHistoryPartyCell {
    
    func configure(with citem: PartyItem) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 桔封面
        cover.kf.setImage(with: URL(string: item.cover), placeholder: PlaceHolderSmall)

        // 桔名称
        nameLabel.text = item.name
        nameLabel.sizeToFit()
        
        // 桔人数
        personLabel.text = "\(item.maleCnt + item.femaleCnt - item.maleRemainCount - item.femaleRemainCount)/\(item.maleCnt + item.femaleCnt)"
        personLabel.sizeToFit()
        
        // 桔时间
        timeLabel.text = Date.formatDate(startTime: item.startTime, endTime: item.endTime)
        timeLabel.sizeToFit()

        // 桔地址
        addressLabel.text = item.address
        addressLabel.sizeToFit()
        
        // 展示状态
        if (item.state == 2 || item.state == 3) {
            coverMask.isHidden = false
            maskLabel.text = item.state == 2 ? "已解散" : "已结束"
            maskLabel.sizeToFit()
        } else {
            coverMask.isHidden = true
        }
    }
}

extension MyHistoryPartyCell {
    
    fileprivate func setupUI() {
        
        contentView.addSubview(splitLabel)
        contentView.addSubview(bgView)
        bgView.addSubview(cover)
        cover.addSubview(coverMask)
        coverMask.addSubview(maskLabel)
        bgView.addSubview(nameLabel)
        bgView.addSubview(personLabel)
        bgView.addSubview(timeLabel)
        bgView.addSubview(localIcon)
        bgView.addSubview(addressLabel)
        
        splitLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        bgView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(splitLabel.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(itemHeight)
        }
        
        cover.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSizeMake(75, 100))
        }
        
        coverMask.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        maskLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cover.snp.right).offset(10)
            make.top.equalTo(cover)
            make.right.equalTo(personLabel.snp.left).offset(-10)
        }
        
        personLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-10)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cover.snp.right).offset(10)
            make.top.equalTo(nameLabel.snp.bottom).offset(30)
            make.right.equalToSuperview().offset(-10)
        }
        
        localIcon.snp.makeConstraints { (make) in
            make.left.equalTo(cover.snp.right).offset(10)
            make.bottom.equalTo(cover)
            make.size.equalTo(CGSize(width: 14, height: 14))
        }
        
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(localIcon.snp.right).offset(2)
            make.centerY.equalTo(localIcon)
            make.right.equalToSuperview().offset(-10)
        }
    }
}

