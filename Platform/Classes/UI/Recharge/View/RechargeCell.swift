//
//  RechargeCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import StoreKit

class RechargeCell: UICollectionViewCell {
    
    /// 回调闭包
    public var sendBlock: ((_ sendItem:GiftItem) -> ())?
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 10.0
    var item: RechargeItem = RechargeItem()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 背景框
    fileprivate lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.ls_color("#F2F2F2").cgColor
        view.clipsToBounds = true
        return view
    }()
    
    // 桔子币图标
    fileprivate lazy var coinIV: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_coin")
        return imageView
    }()
    
    // 当前代币
    fileprivate lazy var coinLabel: UILabel = {
        let label = UILabel()
        label.font = kFontBold18
        label.textColor = UIColor.ls_color("#333333")
        label.text = "0"
        label.sizeToFit()
        return label
    }()
    
    // 购买所需货币
    fileprivate lazy var cashLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = ""
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
}

extension RechargeCell {
    
    func configure(with citem: RechargeItem) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        if (item.selected) {
            bgView.layer.borderColor = UIColor.ls_color("#FE9C5B").cgColor
        } else {
            bgView.layer.borderColor = UIColor.ls_color("#F2F2F2").cgColor
        }
        
        // 代币价值
        coinLabel.text = String(item.coinAmount/100)
        coinLabel.sizeToFit()
        
        // 购买所需货币
        cashLabel.text = item.product.price.stringValue + "元"
        cashLabel.sizeToFit()
    }
}

extension RechargeCell {
    
    fileprivate func setupUI() {
        
        contentView.addSubview(bgView)
        bgView.addSubview(coinIV)
        bgView.addSubview(coinLabel)
        bgView.addSubview(cashLabel)
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        coinLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.centerY.equalTo(coinIV)
            make.centerX.equalToSuperview().offset(10)
        }
        
        coinIV.snp.makeConstraints { (make) in
            make.centerY.equalTo(coinLabel)
            make.right.equalTo(coinLabel.snp.left).offset(-4)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        
        cashLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
            make.centerX.equalToSuperview()
        }
    }
}

