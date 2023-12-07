//
//  CashOutLogCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation


class CashOutLogCell: UITableViewCell {
    
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 14.0
    var item: CashOutItem = CashOutItem()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .white
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 提现名称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium16
        label.textColor = UIColor.ls_color("#333333")
        label.text = "等待提现"
        label.sizeToFit()
        return label
    }()
    
    // 提现时间
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#999999")
        label.text = ""
        label.sizeToFit()
        return label
    }()
    
    // 提现金额
    fileprivate lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = kFontBold18
        label.textColor = UIColor.ls_color("#333333")
        label.text = ""
        label.sizeToFit()
        return label
    }()
}

extension CashOutLogCell {
    
    func configure(with citem: CashOutItem) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        
        // 提现描述，0 等待提现 1提现成功 2提现不通过
        if item.state == 0 {
            nameLabel.textColor = UIColor.ls_color("#333333")
            nameLabel.text = "等待提现"
        } else if item.state == 1 {
            nameLabel.textColor = UIColor.ls_color("#333333")
            nameLabel.text = "提现成功"
        } else if item.state == 2 {
            nameLabel.textColor = UIColor.ls_color("#FE5B5B")
            nameLabel.text = item.detailStatus
        } else {
            nameLabel.textColor = UIColor.ls_color("#FE5B5B")
            nameLabel.text = item.detailStatus
        }
        
        // 提现时间
        timeLabel.text = item.createTime
        timeLabel.sizeToFit()
        
        // 提现金额
        amountLabel.text = String(item.amount)
        amountLabel.sizeToFit()
    }
}

extension CashOutLogCell {
    
    fileprivate func setupUI() {
        
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

