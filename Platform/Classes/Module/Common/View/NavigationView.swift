//
//  NavigationView.swift
//  constellation
//
//  Created by Lee on 2020/4/28.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

enum NavigationViewStyle: Int {
    /// 默认样式
    case defalut = 0
    /// 白色主题（返回按钮、标题为白色）
    case light = 1
}

class NavigationView: UIView {
    
    let HeadWidth: CGFloat = 40
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 背景
    lazy var backView: UIImageView = {
      let view = UIImageView()
      view.backgroundColor = UIColor.ls_color("#FFFFFF")
      return view
    }()


    /// 返回按钮
    lazy var leftButton: UIButton = {
        let button = UIButton()
        let img = UIImage(named: "icon_arrow_left_black")
        let backImg = img?.withRenderingMode(.alwaysOriginal)
        button.setImage(backImg, for: .normal)
        button.titleLabel?.textAlignment = .left
        button.titleLabel?.font = UIFont.ls_font(15)
        return button
    }()

    /// 右边按钮
    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.contentMode = .right
        button.titleLabel?.textAlignment = .right
        button.titleLabel?.font = UIFont.ls_font(15)
        button.setTitleColor(UIColor.ls_color(0x08b0bf), for: .normal)
        return button
    }()

    /// 标题
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(18)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.ls_color("#2F1557")
        label.sizeToFit()
        return label
    }()
    
    /// 头像
    lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = HeadWidth/2
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderAvatar)
        imageView.isHidden = true
        return imageView
    }()
    
    /// 分割线
    lazy var seperateLine: UIView = {
        let view = UIView()
        return view
    }()
    
}

extension NavigationView {
    func changeStyle(_ style: NavigationViewStyle){
        switch style {
        case .defalut:
            self.leftButton.setImage(UIImage(named: "icon_arrow_left_black"), for: .normal)
            self.titleLabel.textColor = UIColor.ls_color("#2F1557")
            self.backView.backgroundColor = UIColor.ls_color("#FFFFFF")
        case .light:
            self.leftButton.setImage(UIImage(named: "icon_arrow_left_white"), for: .normal)
            self.titleLabel.textColor = UIColor.ls_color("#FFFFFF")
            self.backView.backgroundColor = UIColor.ls_color("#14110F")
        }
    }
    
    func showAvatar() {
        avatar.isHidden = false
        
        titleLabel.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview().offset(HeadWidth/2+3)
            make.bottom.equalTo(-11)
        }
    }
}

fileprivate extension NavigationView {
    func setupView() {
        self.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        self.addSubview(leftButton)
        leftButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(4)
            make.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(44)
            make.height.equalTo(44)
        }

        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-11)
        }
        
        self.addSubview(avatar)
        avatar.snp.makeConstraints { (make) in
            make.right.equalTo(titleLabel.snp.left).offset(-6)
            make.bottom.equalToSuperview().offset(-2)
            make.size.equalTo(CGSize(width: HeadWidth, height: HeadWidth))
        }

        self.addSubview(rightButton)
        rightButton.snp.makeConstraints { (make) in
            make.right.equalTo(-14)
            make.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(44)
            make.height.equalTo(44)
        }
    }
}
