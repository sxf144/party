//
//  InputViewController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import ZLPhotoBrowser
import Kingfisher
import IQKeyboardManagerSwift

class InputViewController: BaseController {
    
    /// 回调闭包
    public var confirmBlock: ((_ text:String) -> ())?
    let xMargin = 16.0
    let yMargin = 16.0
    var maxCharacterCount = 140
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.ls_color("#ffffff")
        // 重置Navigation
        resetNavigation()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        LSLog("InputViewController viewWillAppear")
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        LSLog("InputViewController viewDidDisappear")
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    // 输入框
    fileprivate lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor.ls_color("#666666")
        textView.font = UIFont.ls_font(16)
        textView.delegate = self
        return textView
    }()
}

extension InputViewController {
    
    func setData(_ text:String, maxCount:Int) {
        textView.text = text
        maxCharacterCount = maxCount
    }
    
    // 点击导航栏右边按钮
    override func rightAction() {
        LSLog("rightAction")
        if let confirmBlock = confirmBlock {
            confirmBlock(textView.text)
        }
        
        self.pop()
    }
}

extension InputViewController: UITextViewDelegate {
    
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


extension InputViewController {
    
    fileprivate func setupUI() {
        
        view.addSubview(textView)
        
        textView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight+yMargin)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
        }
    }
    
    
    
    fileprivate func resetNavigation() {
        
        navigationView.rightButton.setImage(nil, for: .normal)
        navigationView.rightButton.setTitle("确定", for: .normal)
        navigationView.rightButton.setTitleColor(UIColor.ls_color("#FE9C5B"), for: .normal)
        navigationView.rightButton.titleLabel?.font = UIFont.ls_mediumFont(16)
        
        navigationView.rightButton.snp.updateConstraints { (make) in
            make.right.equalTo(-16)
            make.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(56)
            make.height.equalTo(44)
        }
    }
}
