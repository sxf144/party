//
//  SupplyUserController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import ZLPhotoBrowser
import Kingfisher

class SupplyUserController: BaseController {
    

    let maxCharacterCount = 20
    var userInfo = LoginManager.shared.getUserInfo()
    var currAvatarUrl:String = ""
    
    override func viewDidLoad() {
        title = "完善资料"
        super.viewDidLoad()
        setupUI()
        
        // 初始化条件
        var sender = maleSelectBtn
        if userInfo?.sex == 1 {
            sender = maleSelectBtn
        } else if userInfo?.sex == 2 {
            sender = femaleSelectBtn
        }
        
        // 默认选择男
        clickMaleSelectBtn(sender)
    }
    
    fileprivate lazy var avatar:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 57
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.kf.setImage(with: URL(string: userInfo?.portrait ?? ""), placeholder: PlaceHolderAvatar)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    
    fileprivate lazy var nickTextField: UITextField = {
        let textField = UITextField()
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 30
        textField.backgroundColor = UIColor.ls_color("#F7F7F7")
        textField.textColor = kColorTextBlack
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(string: "请输入昵称", attributes: [NSAttributedString.Key.foregroundColor: kColorTextGray])
        textField.text = userInfo?.nick
        return textField
    }()
    
    fileprivate lazy var maleSelectBtn:UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.ls_color("#aaaaaa"), for: .normal)
        button.setTitleColor(UIColor.ls_color("#ffffff"), for: .highlighted)
        button.setTitleColor(UIColor.ls_color("#ffffff"), for: .selected)
        button.titleLabel?.font = kFontRegualer16
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        button.setTitle("男生", for: .normal)
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#f7f7f7")), for: .normal)
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#FE9C5B")), for: .highlighted)
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#FE9C5B")), for: .selected)
        button.setImage(UIImage(named: "male_normal"), for: .normal)
        button.setImage(UIImage(named: "male_selected"), for: .highlighted)
        button.setImage(UIImage(named: "male_selected"), for: .selected)
        button.ls_layout(.imageLeft, padding: 10)
        button.addTarget(self, action: #selector(clickMaleSelectBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var femaleSelectBtn:UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.ls_color("#aaaaaa"), for: .normal)
        button.setTitleColor(UIColor.ls_color("#ffffff"), for: .highlighted)
        button.setTitleColor(UIColor.ls_color("#ffffff"), for: .selected)
        button.titleLabel?.font = kFontRegualer16
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        button.backgroundColor = UIColor.ls_color("#f7f7f7")
        button.setTitle("女生", for: .normal)
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#f7f7f7")), for: .normal)
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#FE9C5B")), for: .highlighted)
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#FE9C5B")), for: .selected)
        button.setImage(UIImage(named: "female_normal"), for: .normal)
        button.setImage(UIImage(named: "female_selected"), for: .highlighted)
        button.setImage(UIImage(named: "female_selected"), for: .selected)
        button.ls_layout(.imageLeft, padding: 10)
        button.addTarget(self, action: #selector(clickFemaleSelectBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var doneBtn:UIButton = {
        let button = UIButton()
        button.setTitleColor(kColorTextWhite, for: .normal)
        button.titleLabel?.font = kFontRegualer16
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitle("完成", for: .normal)
        button.addTarget(self, action: #selector(clickDoneBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension SupplyUserController: UITextFieldDelegate {
    
    @objc func cancelTextField() {
        nickTextField.resignFirstResponder()
    }
    
    @objc func imageTapped() {
        cancelTextField()
        
        let pickerConfig = ZLPhotoConfiguration.default()
        pickerConfig.maxSelectCount = 1 // 设置最大选择数量为 1
        let ps = ZLPhotoPreviewSheet()
        ps.selectImageBlock = { [weak self] results, isOriginal in
            LSLog("selectImageBlock:\(results)")
            // your code
            if results.count > 0 {
                let zlResultModel:ZLResultModel = results[0]
                if let data = zlResultModel.image.pngData() {
                    LSHUD.showLoading("上传中...")
                    OSSManager.shared.uploadData(data, type: .portrait, suffix: ".png") { resp in
                        LSLog("uploadData resp:\(resp)")
                        LSHUD.hide()
                        if resp.status == .success {
                            // 刷新头像
                            self?.currAvatarUrl = resp.fullUrl
                            self?.avatar.kf.setImage(with: URL(string: self?.currAvatarUrl ?? ""), placeholder: PlaceHolderAvatar)
                        } else {
                            LSHUD.showInfo("上传失败")
                        }
                    }
                }
            }
        }
        
        ps.showPreview(sender: self)
    }
    
    @objc func clickMaleSelectBtn(_ sender:UIButton) {
        cancelTextField()
        maleSelectBtn.isSelected = true
        femaleSelectBtn.isSelected = false
    }
    
    @objc func clickFemaleSelectBtn(_ sender:UIButton) {
        cancelTextField()
        maleSelectBtn.isSelected = false
        femaleSelectBtn.isSelected = true
    }
    
    @objc func clickDoneBtn(_ sender:UIButton) {
        // 修改头像
        if !currAvatarUrl.isEmpty {
            NetworkManager.shared.editPortrait(currAvatarUrl) { resp in
                if resp.status == .success {
                    self.userInfo?.portrait = self.currAvatarUrl
                    // 保存本地信息
                    if let nUserInfo = self.userInfo {
                        LoginManager.shared.saveUserInfo(nUserInfo)
                    }
                } else {
                    
                }
            }
        }
        
        // 修改昵称
        let nickText = nickTextField.text
        if let newNick = nickText {
            // 新昵称与老昵称不同，则发起修改昵称请求
            if (!newNick.isEqual(userInfo?.nick)) {
                // 编辑昵称
                NetworkManager.shared.editNick(newNick) { resp in
                    if resp.status == .success {
                        // 修改本地信息
                        self.userInfo?.nick = newNick
                        if let nUserInfo = self.userInfo {
                            LoginManager.shared.saveUserInfo(nUserInfo)
                        }
                    } else {
                        
                    }
                }
            }
        }
        
        // 修改性别
        let sex:Int64 = maleSelectBtn.isSelected ? 1 : 2
        if (sex != userInfo?.sex) {
            // 编辑性别
            NetworkManager.shared.editSex(sex) { resp in
                if resp.status == .success {
                    // 修改本地信息
                    self.userInfo?.sex = sex
                    if let nUserInfo = self.userInfo {
                        LoginManager.shared.saveUserInfo(nUserInfo)
                    }
                } else {
                    
                }
            }
        }
        
        
        // 返回上一界面
        self.pop()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 获取当前文本字段的文本
        guard let currentText = textField.text else {
            return true
        }
        
        // 计算新的文本长度
        let newLength = currentText.count + string.count - range.length
        
        // 检查是否超过了最大字符数
        return newLength <= maxCharacterCount
    }
}


extension SupplyUserController {
    
    fileprivate func setupUI() {
        
        view.addSubview(avatar)
        view.addSubview(nickTextField)
        view.addSubview(maleSelectBtn)
        view.addSubview(femaleSelectBtn)
        view.addSubview(doneBtn)
        
        avatar.snp.makeConstraints { (make) in
            make.top.equalTo(kTabBarHeight + 30)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 114, height: 114))
        }
        
        nickTextField.snp.makeConstraints { (make) in
            make.top.equalTo(avatar.snp.bottom).offset(66)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(60)
        }
        
        maleSelectBtn.snp.makeConstraints { (make) in
            make.top.equalTo(nickTextField.snp.bottom).offset(20)
            make.left.equalTo(nickTextField)
            make.width.equalTo(nickTextField).dividedBy(2).offset(-10)
            make.height.equalTo(60)
        }
        
        femaleSelectBtn.snp.makeConstraints { (make) in
            make.top.equalTo(nickTextField.snp.bottom).offset(20)
            make.right.equalTo(nickTextField)
            make.width.equalTo(nickTextField).dividedBy(2).offset(-10)
            make.height.equalTo(60)
        }
        
        doneBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight-30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(60)
        }
    }
}
