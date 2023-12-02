//
//  ReportReasonItemCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation


class ReportReasonItemCell: UITableViewCell {
    
    let leftMargin: CGFloat = 16.0
    var item: ReportReasonItem = ReportReasonItem()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 举报理由
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#333333")
        label.text = item.reasonDesc
        label.sizeToFit()
        return label
    }()
    
    // 选中标识
    fileprivate lazy var accessIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "icon_cell_selected")
        imageView.isHidden = false
        return imageView
    }()
}

extension ReportReasonItemCell {
    
    func configure(with citem: ReportReasonItem) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 游戏名称
        nameLabel.text = item.reasonDesc
        nameLabel.sizeToFit()
        
        // 选中标识
        accessIcon.isHidden = !item.selected
    }
}

extension ReportReasonItemCell {
    
    fileprivate func setupUI() {
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(accessIcon)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.centerY.equalToSuperview()
        }
        
        accessIcon.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftMargin)
            make.centerY.equalTo(nameLabel)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }
}

