//
//  UserPageController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

class UserPageController: BaseController {
    
    let infoWidth = 80.0
    let userInfo = LoginManager.shared.getUserInfo()
    let leftMargin = 16.0
    let topHeight:CGFloat = 300.0
    var peopleId: String = ""
    var userPageData: UserPageModel = UserPageModel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // 重置Navigation
        resetNavigation()
        setupUI()
        
        // 获取个人主页信息
        getUserHomePage()
    }
    
    // TopView
    fileprivate lazy var topView: UIView = {
        let v = UIView()
        return v
    }()
    
    // 头像
    fileprivate lazy var avatar: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderBig)
        return iv
    }()
    
    // 昵称
    fileprivate lazy var nickLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(22)
        label.textColor = UIColor.white
        label.text = " "
        label.sizeToFit()
        return label
    }()
    
    // 性别
    fileprivate lazy var sexIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "icon_female")
        return imageView
    }()
    
    // 详情view
    fileprivate lazy var detailView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        v.layer.cornerRadius = 8
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()
    
    // 关注
    fileprivate lazy var followNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_boldFont(18)
        label.textColor = UIColor.ls_color("#333333")
        label.text = " "
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var followTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(12)
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = "关注"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    // 粉丝
    fileprivate lazy var fansNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_boldFont(18)
        label.textColor = UIColor.ls_color("#333333")
        label.text = " "
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var fansTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(12)
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = "粉丝"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    // 礼物
    fileprivate lazy var giftNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_boldFont(18)
        label.textColor = UIColor.ls_color("#333333")
        label.text = " "
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var giftTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(12)
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = "礼物"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    // 个性签名
    fileprivate lazy var signTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(14)
        label.textColor = UIColor.ls_color("#333333")
        label.text = "个性签名"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var signLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(14)
        label.textColor = UIColor.ls_color("#333333")
        label.text = "这家伙太懒，什么都没写..."
        label.sizeToFit()
        return label
    }()
    
    // 关注
    fileprivate lazy var followBtn: UIButton = {
        let button = UIButton()
        button.setTitleColor(kColorTextWhite, for: .normal)
        button.titleLabel?.font = UIFont.ls_mediumFont(16)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitle("+关注", for: .normal)
        button.addTarget(self, action: #selector(clickFollowBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 聊天
    fileprivate lazy var sendMsgBtn: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.ls_color("#333333"), for: .normal)
        button.titleLabel?.font = UIFont.ls_mediumFont(16)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = UIColor.ls_color("#F9F9F9")
        button.setTitle("聊天", for: .normal)
        button.addTarget(self, action: #selector(clickChatBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension UserPageController {
    
    func setData(userId: String) {
        peopleId = userId
    }
    
    // 获取详情
    func getUserHomePage() {
        NetworkManager.shared.getUserPage (peopleId) { resp in
            if resp.status == .success {
                LSLog("getUserPage data:\(resp.data)")
                self.userPageData = resp.data
                self.refreshData()
            } else {
                LSLog("getUserPage fail")
            }
        }
    }
    
    // 刷新界面
    func refreshData() {
        // 头像
        avatar.kf.setImage(with: URL(string: userPageData.user.portrait), placeholder: PlaceHolderAvatar)
        
        // 昵称
        nickLabel.text = userPageData.user.nick
        nickLabel.sizeToFit()
        
        // 性别
        sexIcon.image = UIImage(named: userPageData.user.sex == 1 ? "icon_male" : "icon_female")
        
        // 关注
        followNumLabel.text = String(userPageData.relation.followCnt)
        
        // 粉丝
        fansNumLabel.text = String(userPageData.relation.fansCnt)
        
        // 礼物
        giftNumLabel.text = String(userPageData.gift.recvGiftCnt)
        
        // 关注按钮
        refreshFollowBtn()
    }
    
    func refreshFollowBtn() {
        
        if userPageData.relation.follow {
            followBtn.setTitle("取消关注", for: .normal)
            followBtn.backgroundColor = UIColor.ls_color("#FE5B5B")
        } else {
            followBtn.setTitle("+关注", for: .normal)
            followBtn.backgroundColor = UIColor.ls_color("#FE9C5B")
        }
    }
    
    // 更多
    override func rightAction() {
        
    }
    
    // 关注
    @objc func clickFollowBtn(_ sender:UIButton) {
        
        if userPageData.relation.follow {
            NetworkManager.shared.unfollowPeople(peopleId) { resp in
                if resp.status == .success {
                    LSLog("unfollowPeople succ")
                    self.userPageData.relation.follow = false
                    self.refreshFollowBtn()
                } else {
                    LSLog("unfollowPeople fail")
                    LSHUD.showInfo("取消关注失败")
                }
            }
        } else {
            NetworkManager.shared.followPeople(peopleId) { resp in
                if resp.status == .success {
                    LSLog("followPeople succ")
                    self.userPageData.relation.follow = true
                    self.refreshFollowBtn()
                } else {
                    LSLog("followPeople fail")
                    LSHUD.showInfo("关注失败")
                }
            }
        }
    }
    
    // 发送私信
    @objc func clickChatBtn(_ sender:UIButton) {
        let conv:LIMConversation = LIMConversation()
        conv.userID = peopleId
        conv.type = .LIM_C2C
        conv.conversationID = "c2c_\(conv.userID ?? "")"
        conv.showName = userPageData.user.nick
        PageManager.shared.pushToChatController(conv)
    }
}

extension UserPageController {
    
    fileprivate func setupUI() {
        
        view.addSubview(topView)
        topView.addSubview(avatar)
        topView.addSubview(nickLabel)
        topView.addSubview(sexIcon)
        view.addSubview(detailView)
        detailView.addSubview(followNumLabel)
        detailView.addSubview(followTipLabel)
        detailView.addSubview(fansNumLabel)
        detailView.addSubview(fansTipLabel)
        detailView.addSubview(giftNumLabel)
        detailView.addSubview(giftTipLabel)
        detailView.addSubview(signTitleLabel)
        detailView.addSubview(signLabel)
        view.addSubview(followBtn)
        view.addSubview(sendMsgBtn)
        
        
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(topHeight)
        }

        avatar.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        nickLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.bottom.equalToSuperview().offset(-27)
        }
        
        sexIcon.snp.makeConstraints { (make) in
            make.left.equalTo(nickLabel.snp.right).offset(5)
            make.centerY.equalTo(nickLabel)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
        
        detailView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(-8)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        followNumLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(leftMargin)
            make.width.equalTo(infoWidth)
        }
        
        followTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(followNumLabel.snp.bottom).offset(8)
            make.centerX.equalTo(followNumLabel)
        }
        
        fansNumLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(followNumLabel.snp.right)
            make.width.equalTo(infoWidth)
        }
        
        fansTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fansNumLabel.snp.bottom).offset(8)
            make.centerX.equalTo(fansNumLabel)
        }
        
        giftNumLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(fansNumLabel.snp.right)
            make.width.equalTo(infoWidth)
        }
        
        giftTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(giftNumLabel.snp.bottom).offset(8)
            make.centerX.equalTo(giftNumLabel)
        }
        
        signTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(110)
            make.left.equalToSuperview().offset(leftMargin)
        }
        
        signLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(signTitleLabel)
        }
        
        followBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.width.equalToSuperview().dividedBy(2).offset(-22)
            make.height.equalTo(42)
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
        }
        
        sendMsgBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftMargin)
            make.width.equalTo(followBtn)
            make.height.equalTo(followBtn)
            make.bottom.equalTo(followBtn)
        }
    }
    
    fileprivate func resetNavigation() {
        
        navigationView.backgroundColor = UIColor.clear
        navigationView.backView.backgroundColor = UIColor.clear
        
        let leftImg = UIImage(named: "icon_back_white")
        let backImg = leftImg?.withRenderingMode(.alwaysOriginal)
        navigationView.leftButton.setImage(backImg, for: .normal)
        let rightImg = UIImage(named: "icon_more_action")
        let shareImg = rightImg?.withRenderingMode(.alwaysOriginal)
        navigationView.rightButton.setImage(shareImg, for: .normal)
    }
}
