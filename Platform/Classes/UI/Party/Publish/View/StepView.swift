//
//  StepView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit


class StepView: UIView {
    
    let icon1Width = 16.0
    let icon2Width = 18.0
    var iconName: String = "icon_female"
    var count: Int = 0
    
    /// 回调闭包
    public var actionBlock: ((_ cnt:Int) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // icon
    fileprivate lazy var iconIV: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: iconName)
        return imageView
    }()
    
    fileprivate lazy var leftBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_reduce"), for: .normal)
        button.addTarget(self, action: #selector(clickLeftBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var countLabel: UILabel = {
        let label = UILabel()
        label.text = String(count)
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_mediumFont(14)
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var rightBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_add"), for: .normal)
        button.addTarget(self, action: #selector(clickRightBtn(_:)), for: .touchUpInside)
        return button
    }()
}


extension StepView {
    
    func initUI() {
        setupUI()
    }
    
    @objc func clickLeftBtn(_ sender:UIButton) {
        if (count <= 0) {
            return
        }
        
        count -= 1
        countLabel.text = String(count)
        countLabel.sizeToFit()
        // 回调闭包
        if let actionBlock = actionBlock {
            actionBlock(count)
        }
    }
    
    @objc func clickRightBtn(_ sender:UIButton) {
        count += 1
        countLabel.text = String(count)
        countLabel.sizeToFit()
        // 回调闭包
        if let actionBlock = actionBlock {
            actionBlock(count)
        }
    }
}




extension StepView {
    
    fileprivate func setupUI() {
        
        self.addSubview(iconIV)
        self.addSubview(leftBtn)
        self.addSubview(countLabel)
        self.addSubview(rightBtn)
        
        
        iconIV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(icon1Width)
            make.height.equalTo(icon1Width)
        }
        
        leftBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconIV.snp.right).offset(8)
            make.width.equalTo(icon2Width)
            make.height.equalTo(icon2Width)
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(leftBtn.snp.right)
            make.width.equalTo(25)
            make.height.equalTo(icon2Width)
        }
        
        rightBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(countLabel.snp.right)
            make.width.equalTo(icon2Width)
            make.height.equalTo(icon2Width)
        }
    }
}
