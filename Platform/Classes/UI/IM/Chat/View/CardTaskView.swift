//
//  CardTaskView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

class CardTaskView: UIView {
    
    static let shared = CardTaskView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
    /// 回调闭包
    public var cardTaskBlock: (() -> ())?
    let CardImageDefault: UIImage = UIImage(named: "card_item_bg")!
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 16
    var userPageInfo: UserPageModel? = LoginManager.shared.getUserPageInfo()
    var limMsg: LIMMessage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 背景
    fileprivate lazy var bgView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        view.alpha = 0.0
        view.backgroundColor = .black
        return view
    }()
    
    /// 主体
    fileprivate lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        view.alpha = 0.0
        view.backgroundColor = .clear
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(cancelDidClick))
        view.addGestureRecognizer(tapGes)
        return view
    }()
    
    // 标题
    fileprivate lazy var titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "task_title")
        return imageView
    }()
    
    // 卡牌
    fileprivate lazy var cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.kf.setImage(with: URL(string: ""), placeholder: CardImageDefault)
        return imageView
    }()
    
    // 卡牌名字
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium18
        label.textColor = UIColor.white
        label.text = ""
        label.sizeToFit()
        label.numberOfLines = 4
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    // 红包按钮
    fileprivate lazy var redPacketBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE5B5B")
        button.setTitle("发红包逃避此任务", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = kFontMedium14
        button.layer.cornerRadius = 23
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickRedPacketBtn(_:)), for: .touchUpInside)
        return button
    }()
}


extension CardTaskView {
    
    // 发红包逃避任务
    @objc fileprivate func clickRedPacketBtn(_ sender:UIButton) {
        LSLog("clickRedPacketBtn")
        if let cardTaskBlock = cardTaskBlock {
            cardTaskBlock()
            removeTaskView()
        }
    }
    
    // 取消
    @objc fileprivate func cancelDidClick(){
        LSLog("cancelDidClick")
        removeTaskView()
    }
    
    /// 显示 view
    func showInWindow(_ limMsg:LIMMessage) {
        
        // 赋值
        self.limMsg = limMsg
        
        // 是自己抽到，才展示发红包逃避按钮
        if limMsg.isSelf ?? false {
            // 判断任务已经完成过，不展示发红包逃避按钮
            if limMsg.gameElem?.status == 1 {
                redPacketBtn.isHidden = true
            } else {
                redPacketBtn.isHidden = false
            }
        } else {
            redPacketBtn.isHidden = true
        }
        
        // 卡牌图片
        cardImageView.kf.setImage(with: URL(string: limMsg.gameElem?.action.cardInfo.introductionThumbnail ), placeholder: CardImageDefault)
        
        // 卡牌名称
        nameLabel.text = limMsg.gameElem?.action.cardInfo.name
        nameLabel.sizeToFit()
        
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        keyWindow!.addSubview(self)
        keyWindow!.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.3) {
            self.bgView.alpha = 0.6
            self.contentView.alpha = 1.0
        }
        
        // 创建一个震动反馈生成器
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// 移除 view
    func removeTaskView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.alpha = 0.0
            self.contentView.alpha = 0.0
            UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
        }) { (suc) in
            self.removeFromSuperview()
        }
    }
}



extension CardTaskView {
    
    fileprivate func setupUI() {
        
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(titleImageView)
        contentView.addSubview(cardImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(redPacketBtn)
        
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(84)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 138, height: 26))
        }
        
        cardImageView.snp.makeConstraints { (make) in
            make.top.equalTo(titleImageView.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 318, height: 538))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.width.lessThanOrEqualToSuperview().offset(-xMargin*2)
            make.center.equalToSuperview()
        }
        
        redPacketBtn.snp.makeConstraints { (make) in
            make.top.equalTo(cardImageView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 260, height: 46))
        }
    }
}
