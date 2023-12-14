//
//  CommentCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation


class CommentCell: UITableViewCell {
    
    let leftMargin: CGFloat = 16.0
    let avatarWidth: CGFloat = 36.0
    var item: CommentItem = CommentItem()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        accessoryType = .none
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 用户头像
    fileprivate lazy var avatar: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 18
        iv.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderAvatar)
        return iv
    }()
    
    // 昵称
    fileprivate lazy var nick: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#999999")
        label.text = ""
        label.sizeToFit()
        return label
    }()
    
    // 点赞区域
    fileprivate lazy var likeBtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(clickLikeBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 点赞数
    fileprivate lazy var likeCntLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#999999")
        label.text = ""
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var likeIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "icon_like")
        return iv
    }()
    
    // 内容
    fileprivate lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer13
        label.textColor = UIColor.ls_color("#333333")
        label.text = ""
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    // 时间
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer10
        label.textColor = UIColor.ls_color("#5C5C5C")
        label.text = ""
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var replyTipLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer10
        label.textColor = UIColor.ls_color("#FE9C5B")
        label.text = ""
        label.sizeToFit()
        return label
    }()
}

extension CommentCell {
    
    func configure(with citem: CommentItem) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 游戏封面
        avatar.kf.setImage(with: URL(string: item.from.portrait), placeholder: PlaceHolderAvatar)
        
        // 昵称
        nick.text = item.from.nick
        nick.sizeToFit()
        
        // 点赞数
        likeCntLabel.text = "\(item.likeCnt)"
        likeCntLabel.sizeToFit()
        
        // 内容
        contentLabel.text = item.content
        contentLabel.sizeToFit()
        
        // 时间
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let inputDate = inputDateFormatter.date(from: item.commentTime ) {
            timeLabel.text = inputDate.ls_formatStr()
            timeLabel.sizeToFit()
        }
    }
    
    @objc func clickLikeBtn(_ sender: UIButton) {
        LSLog("clickLikeBtn")
        sender.isSelected = !sender.isSelected
        if (sender.isSelected) {
            item.likeCnt += 1
        } else {
            item.likeCnt -= 1
        }
        
        if item.likeCnt < 0 {
            item.likeCnt = 0
        }
        
        likeCntLabel.text = String(item.likeCnt)
        likeCntLabel.sizeToFit()
        
        // 发送给服务器修改
        commentLike(!sender.isSelected)
    }
    
    func commentLike(_ cancel:Bool) {
        NetworkManager.shared.commentLike( item.id, cancel: cancel) { resp in
            if resp.status == .success {
                LSLog("commentLike succ")
            } else {
                LSLog("commentLike fail")
            }
        }
    }
}

extension CommentCell {
    
    fileprivate func setupUI() {
        
        contentView.addSubview(avatar)
        contentView.addSubview(nick)
        contentView.addSubview(likeBtn)
        likeBtn.addSubview(likeCntLabel)
        likeBtn.addSubview(likeIcon)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(replyTipLabel)
        
        avatar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.top.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: avatarWidth, height: avatarWidth))
        }
        
        nick.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(8)
            make.top.equalTo(avatar)
        }
        
        likeBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftMargin)
            make.centerY.equalTo(nick)
            make.height.equalTo(24)
        }
        
        likeCntLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        likeIcon.snp.makeConstraints { (make) in
            make.right.equalTo(likeCntLabel.snp.left).offset(-2)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 22, height: 22))
            make.left.equalToSuperview().offset(4)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nick.snp.bottom).offset(5)
            make.left.equalTo(nick)
            make.right.equalToSuperview().offset(-leftMargin)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.left.equalTo(nick)
            make.bottom.equalTo(contentView).offset(-10)
        }
        
        replyTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(timeLabel.snp.right).offset(8)
            make.centerY.equalTo(timeLabel)
        }
    }
}

