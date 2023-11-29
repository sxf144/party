//
//  TaskView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

// GiftView高度
private let CONTENT_HEIGHT: CGFloat = 310

class TaskView: UIView {
    
    static let shared = TaskView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
    /// 回调闭包
    public var redPacketBlock: ((_ gElem:LIMGameElem) -> ())?
    let CardImageDefault: UIImage = UIImage(named: "card_item_bg")!
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 16
    var userPageInfo: UserPageModel? = LoginManager.shared.getUserPageInfo()
    var gameElem: LIMGameElem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 主体
    fileprivate lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        view.alpha = 0.2
        view.backgroundColor = UIColor.black
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
        button.addTarget(self, action: #selector(clickRedPacketBtnBtn(_:)), for: .touchUpInside)
        return button
    }()
}


extension TaskView {
    
    // 发红包逃避任务
    @objc fileprivate func clickRedPacketBtnBtn(_ sender:UIButton) {
        LSLog("clickRedPacketBtnBtn")
        if let redPacketBlock = redPacketBlock, let gElem = gameElem {
            redPacketBlock(gElem)
            removeTaskView()
        }
    }
    
    // 取消
    @objc fileprivate func cancelDidClick(){
        LSLog("cancelDidClick")
        removeTaskView()
    }
    
    /// 显示 view
    func showInWindow(_ gameElem:LIMGameElem) {
        
        // 赋值
        self.gameElem = gameElem
        
        // 卡牌图片
        cardImageView.kf.setImage(with: URL(string: gameElem.action.cardInfo.introductionThumbnail ), placeholder: CardImageDefault)
        
        // 卡牌名称
        nameLabel.text = gameElem.action.cardInfo.name
        nameLabel.sizeToFit()
        
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        keyWindow!.addSubview(self)
        keyWindow!.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = 1.0
        }
    }
    
    /// 移除 view
    func removeTaskView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.alpha = 0.2
            UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
        }) { (suc) in
            self.removeFromSuperview()
        }
    }
}



extension TaskView {
    
    fileprivate func setupUI() {
        
        addSubview(contentView)
        contentView.addSubview(titleImageView)
        contentView.addSubview(cardImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(redPacketBtn)
        
        
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
            make.centerX.centerY.equalToSuperview()
        }
        
        redPacketBtn.snp.makeConstraints { (make) in
            make.top.equalTo(cardImageView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 260, height: 46))
        }
    }
}
