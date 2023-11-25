//
//  EditUserController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import ZLPhotoBrowser
import Kingfisher

class EditUserController: BaseController {
    
    let leftMargin = 16.0
    var userInfo:UserInfoModel = LoginManager.shared.getUserInfo() ?? UserInfoModel()
    var userPageData: UserPageModel = LoginManager.shared.getUserPageInfo() ?? UserPageModel()
    var currAvatarUrl:String = ""
    var sex: Int64 = 1
    let btnTagStart: Int = 1001
    let titleTag: Int = 1011
    
    let options: [[String: String]] = [["tip": "昵称", "name": "", "color": "#333333"], ["tip": "性别", "title": "", "color": "#333333"], ["tip": "个性签名", "title": "", "color": "#FE9C5B"]]
    let optionKey = "OptionKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.ls_color("#F8F8F8")
        title = "编辑资料"
        // 重置Navigation
        resetNavigation()
        setupUI()
        
        // 刷新数据
        refreshUI()
    }
    
    fileprivate lazy var headContainer:UIView = {
        let view = UIView()
        view.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()
    
    fileprivate lazy var avatar:UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 57
        iv.clipsToBounds = true
        iv.kf.setImage(with: URL(string: userInfo.portrait ), placeholder: PlaceHolderAvatar)
        return iv
    }()
    
    fileprivate lazy var iconAlbum:UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.image = UIImage(named: "icon_edit_album")
        return iv
    }()
}

extension EditUserController {
    
    
    @objc func headTapped() {
        
        let pickerConfig = ZLPhotoConfiguration.default()
        pickerConfig.maxSelectCount = 1 // 设置最大选择数量为 1
        let ps = ZLPhotoPreviewSheet()
        ps.selectImageBlock = { [weak self] results, isOriginal in
            LSLog("selectImageBlock:\(results)")
            // your code
            if results.count > 0 {
                let zlResultModel:ZLResultModel = results[0]
                OSSManager.shared.uploadData(zlResultModel.image) { resp in
                    LSLog("uploadData resp:\(resp)")
                    // 刷新头像
                    self?.currAvatarUrl = resp.fullUrl
                    self?.avatar.kf.setImage(with: URL(string: self?.currAvatarUrl ?? ""), placeholder: PlaceHolderAvatar)
                }
            }
        }
        
        ps.showPreview(sender: self)
    }
    
    // options
    @objc func clickOptionBtn(_ sender:UIButton) {
        LSLog("clickOptionBtn")
        let optionValue:Int = sender.layer.value(forKey: optionKey) as! Int
        // optionValue 1、2、3分别是昵称、性别、个性签名
        if optionValue == 1 {
            let vc = InputViewController()
            vc.setData(userInfo.nick , maxCount: 8)
            vc.confirmBlock = { text in
                LSLog("confirmBlock text:\(text)")
                self.updateNick(text)
            }
            vc.hidesBottomBarWhenPushed = true
            PageManager.shared.currentNav()?.pushViewController(vc, animated: true)
        } else if optionValue == 2 {
            self.showSexActionSheet()
        } else if optionValue == 3 {
            let vc = InputViewController()
            vc.setData(userInfo.intro , maxCount: 30)
            vc.confirmBlock = { text in
                LSLog("confirmBlock text:\(text)")
                self.updateIntro(text)
            }
            vc.hidesBottomBarWhenPushed = true
            PageManager.shared.currentNav()?.pushViewController(vc, animated: true)
        }
    }
    
    func showSexActionSheet() {
        // 创建一个UIAlertController
        let alertController = UIAlertController(title: nil, message: "修改性别", preferredStyle: .actionSheet)

        // 添加操作按钮
        let option1 = UIAlertAction(title: "男", style: .default) { (action) in
            // 处理选项1的操作
            self.sex = 1
            // 先修改本地
            let optionBtn2:UIButton = self.view.viewWithTag(self.btnTagStart+1) as! UIButton
            let titleLabe2:UILabel = optionBtn2.viewWithTag(self.titleTag) as! UILabel
            titleLabe2.text = self.sex == 1 ? "男" : "女"
            titleLabe2.sizeToFit()
            // 发起给服务器修改
            self.updateSex(self.sex)
        }

        let option2 = UIAlertAction(title: "女", style: .default) { (action) in
            // 处理选项2的操作
            self.sex = 2
            // 先修改本地
            let optionBtn2:UIButton = self.view.viewWithTag(self.btnTagStart+1) as! UIButton
            let titleLabe2:UILabel = optionBtn2.viewWithTag(self.titleTag) as! UILabel
            titleLabe2.text = self.sex == 1 ? "男" : "女"
            titleLabe2.sizeToFit()
            // 发起给服务器修改
            self.updateSex(self.sex)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            // 处理取消的操作
        }

        // 将操作按钮添加到UIAlertController
        alertController.addAction(option1)
        alertController.addAction(option2)
        alertController.addAction(cancelAction)

        // 显示UIAlertController
        present(alertController, animated: true, completion: nil)
    }
    
    func refreshUI() {
        
        // 头像
        avatar.kf.setImage(with: URL(string: userInfo.portrait ), placeholder: PlaceHolderAvatar)
        
        // 昵称
        if !userInfo.nick.isEmpty {
            let optionBtn1:UIButton = view.viewWithTag(btnTagStart) as! UIButton
            let titleLabel1:UILabel = optionBtn1.viewWithTag(titleTag) as! UILabel
            titleLabel1.text = userInfo.nick
            titleLabel1.sizeToFit()
        }
        
        // 性别
        let optionBtn2:UIButton = view.viewWithTag(btnTagStart+1) as! UIButton
        let titleLabe2:UILabel = optionBtn2.viewWithTag(titleTag) as! UILabel
        titleLabe2.text = userInfo.sex == 1 ? "男" : "女"
        titleLabe2.sizeToFit()
        
        // 介绍
        let optionBtn3:UIButton = view.viewWithTag(btnTagStart+2) as! UIButton
        let titleLabel3:UILabel = optionBtn3.viewWithTag(titleTag) as! UILabel
        
        if !userInfo.intro.isEmpty {
            titleLabel3.text = userInfo.intro
            titleLabel3.sizeToFit()
        } else {
            titleLabel3.text = "介绍一下你自己"
            titleLabel3.sizeToFit()
        }
    }
    
    func updateAvatar() {
        if !currAvatarUrl.isEmpty, currAvatarUrl != self.userInfo.portrait {
            NetworkManager.shared.editPortrait(currAvatarUrl) { resp in
                if resp.status == .success {
                    self.userInfo.portrait = self.currAvatarUrl
                    self.userPageData.user.portrait = self.currAvatarUrl
                    // 保存本地信息
                    LoginManager.shared.saveUserInfo(self.userInfo)
                    LoginManager.shared.saveUserPageInfo(self.userPageData)
                    self.refreshUI()
                    LSNotification.postUserPageInfoChange()
                } else {
                    
                }
            }
        }
    }
    
    // 修改昵称
    func updateNick(_ nick:String) {
        if !nick.isEmpty {
            // 新昵称与老昵称不同，则发起修改昵称请求
            if (!nick.isEqual(userInfo.nick)) {
                // 编辑昵称
                NetworkManager.shared.editNick(nick) { resp in
                    if resp.status == .success {
                        // 修改本地信息
                        self.userInfo.nick = nick
                        self.userPageData.user.nick = nick
                        LoginManager.shared.saveUserInfo(self.userInfo)
                        LoginManager.shared.saveUserPageInfo(self.userPageData)
                        // 刷新本地数据
                        self.refreshUI()
                        // 发送用户主页信息更新通知
                        LSNotification.postUserPageInfoChange()
                    } else {
                        
                    }
                }
            }
        }
    }
    
    // 修改性别
    func updateSex(_ sex:Int64) {
        
        if (sex != userInfo.sex) {
            // 编辑性别
            NetworkManager.shared.editSex(sex) { resp in
                if resp.status == .success {
                    // 修改本地信息
                    self.userInfo.sex = sex
                    self.userPageData.user.sex = sex
                    LoginManager.shared.saveUserInfo(self.userInfo)
                    LoginManager.shared.saveUserPageInfo(self.userPageData)
                    self.refreshUI()
                    // 发送用户主页信息更新通知
                    LSNotification.postUserPageInfoChange()
                } else {
                    
                }
            }
        }
    }
    
    // 修改签名
    func updateIntro(_ intro:String) {
        if !intro.isEmpty {
            // 新签名与老签名不同，则发起修改签名请求
            if (!intro.isEqual(userInfo.intro)) {
                // 编辑签名
                NetworkManager.shared.editIntro(intro) { resp in
                    if resp.status == .success {
                        // 修改本地信息
                        self.userInfo.intro = intro
                        self.userPageData.user.intro = intro
                        LoginManager.shared.saveUserInfo(self.userInfo)
                        LoginManager.shared.saveUserPageInfo(self.userPageData)
                        self.refreshUI()
                        // 发送用户主页信息更新通知
                        LSNotification.postUserPageInfoChange()
                    } else {
                        
                    }
                }
            }
        }
    }
    
}


extension EditUserController {
    
    fileprivate func setupUI() {
        
        view.addSubview(headContainer)
        headContainer.addSubview(avatar)
        headContainer.addSubview(iconAlbum)
        
        headContainer.snp.makeConstraints { (make) in
            make.top.equalTo(kTabBarHeight + 30)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 114, height: 114))
        }
        
        avatar.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        iconAlbum.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 28, height: 28))
        }
        
        setupOptions()
    }
    
    fileprivate func setupOptions() {
        
        for i in 0 ..< options.count {
            
            let isLast: Bool = i == options.count - 1
            let option = options[i]
            
            lazy var optionBtn: UIButton = {
                let button = UIButton()
                button.tag = btnTagStart + i
                button.backgroundColor = .white
                button.clipsToBounds = true
                button.layer.setValue(i+1, forKey: optionKey)
                button.addTarget(self, action: #selector(clickOptionBtn(_:)), for: .touchUpInside)
                return button
            }()
            
            lazy var optionTipLabel: UILabel = {
                let label = UILabel()
                label.font = kFontRegualer14
                label.textColor = UIColor.ls_color("#aaaaaa")
                label.text = option["tip"]
                label.sizeToFit()
                return label
            }()
            
            lazy var optionTitleLabel: UILabel = {
                let label = UILabel()
                label.tag = titleTag
                label.font = kFontRegualer14
                label.textColor = UIColor.ls_color(option["color"]!)
                label.text = option["title"]
                label.sizeToFit()
                return label
            }()
            
            
            view.addSubview(optionBtn)
            optionBtn.addSubview(optionTipLabel)
            optionBtn.addSubview(optionTitleLabel)
            
            
            optionBtn.snp.makeConstraints { (make) in
                make.top.equalTo(avatar.snp.bottom).offset(35+50*i)
                make.left.right.equalToSuperview()
                make.height.equalTo(50)
            }
            
            optionTipLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(leftMargin)
            }
            
            optionTitleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(90)
            }
            
            if !isLast {
                lazy var splitLine: UIView = {
                    let view = UIView()
                    view.backgroundColor = UIColor.ls_color("#ededed")
                    view.clipsToBounds = true
                    return view
                }()
                
                optionBtn.addSubview(splitLine)
                
                splitLine.snp.makeConstraints { (make) in
                    make.bottom.equalToSuperview()
                    make.right.equalToSuperview().offset(-leftMargin)
                    make.left.equalTo(optionTitleLabel)
                    make.height.equalTo(0.5)
                }
            }
        }
    }
    
    fileprivate func resetNavigation() {
        navigationView.backgroundColor = UIColor.clear
        navigationView.backView.backgroundColor = UIColor.clear
    }
}
