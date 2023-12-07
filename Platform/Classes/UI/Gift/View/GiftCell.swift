//
//  GiftCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation

class GiftCell: UICollectionViewCell {
    
    /// 回调闭包
    public var sendBlock: ((_ sendItem:GiftItem) -> ())?
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 10.0
    var item: GiftItem = GiftItem()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 选中状态背景
    fileprivate lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ls_color("#F6F6F6")
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    // 发送按钮
    fileprivate lazy var sendBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.clipsToBounds = true
        button.setTitle("发送", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = kFontRegualer12
        button.addTarget(self, action: #selector(clickSendBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var giftIV: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderSmall)
        return imageView
    }()
    
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium12
        label.textColor = UIColor.ls_color("#333333")
        label.text = ""
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer10
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = ""
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
}

extension GiftCell {
    
    func configure(with citem: GiftItem) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        bgView.isHidden = !item.selected
        
        // 图片
        giftIV.kf.setImage(with: URL(string: item.icon), placeholder: PlaceHolderSmall)
        
        // 名称
        nameLabel.text = item.name
        nameLabel.sizeToFit()
        
        // 价格
        amountLabel.text = String(item.amount/100) + " JZ币"
        amountLabel.sizeToFit()
    }
    
    // 点击发送
    @objc func clickSendBtn(_ sender:UIButton) {
        LSLog("clickSendBtn")
        if let sendBlock = sendBlock {
            sendBlock(item)
        }
    }
}

extension GiftCell {
    
    fileprivate func setupUI() {
        
        contentView.addSubview(bgView)
        bgView.addSubview(sendBtn)
        contentView.addSubview(giftIV)
        contentView.addSubview(nameLabel)
        contentView.addSubview(amountLabel)
        
        bgView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(78)
            make.height.equalToSuperview()
        }
        
        sendBtn.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(28)
            make.bottom.equalToSuperview()
        }
        
        giftIV.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 76, height: 86))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(giftIV.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        amountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }
}

