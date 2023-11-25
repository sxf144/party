//
//  CoinItemCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation


class CoinItemCell: UITableViewCell {
    
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 14.0
    var item: CoinItem = CoinItem()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .white
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 收支名称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#333333")
        label.text = item.description
        label.sizeToFit()
        return label
    }()
    
    // 收支时间
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#999999")
        label.text = item.time
        label.sizeToFit()
        return label
    }()
    
    // 收支金额
    fileprivate lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = kFontBold18
        label.textColor = UIColor.ls_color("#FE5B5B")
        label.text = String(item.amount)
        label.sizeToFit()
        return label
    }()
}

extension CoinItemCell {
    
    func configure(with citem: CoinItem) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        if item.amount > 0 {
            amountLabel.textColor = UIColor.ls_color("#FE5B5B")
        } else {
            amountLabel.textColor = UIColor.ls_color("#333333")
        }
        
        // 收支名称
        nameLabel.text = item.description
        nameLabel.sizeToFit()
        
        // 收支时间
        timeLabel.text = item.time
        timeLabel.sizeToFit()
        
        // 收支金额
        amountLabel.text = String(item.amount)
        amountLabel.sizeToFit()
    }
}

extension CoinItemCell {
    fileprivate func setupUI(){
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(amountLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.top.equalToSuperview().offset(yMargin)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.bottom.equalToSuperview().offset(-yMargin)
        }
        
        amountLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-xMargin)
            make.centerY.equalToSuperview()
        }
    }
}

