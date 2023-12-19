//
//  RateView.swift
//  constellation
//
//  Created by Lee on 2020/4/15.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class RateView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var rateIcon1:UIImageView = {
        return createIcon()
    }()
    fileprivate lazy var rateIcon2:UIImageView = {
        return createIcon()
    }()
    fileprivate lazy var rateIcon3:UIImageView = {
        return createIcon()
    }()
    fileprivate lazy var rateIcon4:UIImageView = {
        return createIcon()
    }()
    fileprivate lazy var rateIcon5:UIImageView = {
        return createIcon()
    }()

}

extension RateView{
    func setData(_ score:Int) {
        rateIcon1.isHidden = !(score > 0)
        rateIcon2.isHidden = !(score > 1)
        rateIcon3.isHidden = !(score > 2)
        rateIcon4.isHidden = !(score > 3)
        rateIcon5.isHidden = !(score > 4)
    }
}

fileprivate extension RateView{
    
    func setupView(){
        addSubview(rateIcon1)
        addSubview(rateIcon2)
        addSubview(rateIcon3)
        addSubview(rateIcon4)
        addSubview(rateIcon5)
        
        rateIcon1.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        rateIcon2.snp.makeConstraints { (make) in
            make.right.equalTo(rateIcon1.snp.left).offset(-4)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        rateIcon3.snp.makeConstraints { (make) in
            make.right.equalTo(rateIcon2.snp.left).offset(-4)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        rateIcon4.snp.makeConstraints { (make) in
            make.right.equalTo(rateIcon3.snp.left).offset(-4)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        rateIcon5.snp.makeConstraints { (make) in
            make.right.equalTo(rateIcon4.snp.left).offset(-4)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
    }
    
    func createIcon() -> UIImageView {
        let imv = UIImageView()
        imv.image = UIImage(named: "icon_rate_star")
        imv.isHidden = true
        return imv
    }
}
