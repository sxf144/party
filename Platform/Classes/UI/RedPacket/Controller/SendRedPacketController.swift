//
//  SendRedPacketController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

class SendRedPacketController: BaseController {
    
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 16
    // type 1、拼手气红包，2、平分红包，默认为1
    var type: RedPacketType = .RedPacketTypeLuck
    let maxCharacterCount = 10
    var uniqueCode: String = ""
    var personCount: Int = 1
    var userId: String = ""
    var taskId: Int64 = 0

    override func viewDidLoad() {
        title = "发红包"
        super.viewDidLoad()
        view.backgroundColor = UIColor.ls_color("#F6F6F6")
        setupUI()
    }
    
    
    // 红包类型选择
    fileprivate lazy var typeSelectBtn: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.addTarget(self, action: #selector(clickTypeSelectBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 类型
    fileprivate lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#FE9C5B")
        label.text = "拼手气红包"
        label.sizeToFit()
        return label
    }()
    
    // typeArrow
    fileprivate lazy var typeArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_arrow_down")
        return imageView
    }()
    
    // 红包个数
    fileprivate lazy var countView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        let countTapGes = UITapGestureRecognizer(target: self, action: #selector(countDidClick))
        view.addGestureRecognizer(countTapGes)
        view.isHidden = true
        return view
    }()
    
    fileprivate lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#333333")
        label.text = "红包个数"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var countUnitLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#333333")
        label.text = "个"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var countTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor.ls_color("#333333")
        textField.delegate = self
        textField.font = kFontRegualer16
        textField.textAlignment = .right
        textField.keyboardType = .numberPad
        textField.attributedPlaceholder = NSAttributedString(string: "填写红包个数", attributes: [NSAttributedString.Key.foregroundColor: kColorTextTips])
        return textField
    }()
    
    // 本群人数
    fileprivate lazy var personCountLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = kColorTextGray
        label.text = "本群共\(personCount)人"
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    // 红包金额
    fileprivate lazy var amountView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        let countTapGes = UITapGestureRecognizer(target: self, action: #selector(amountDidClick))
        view.addGestureRecognizer(countTapGes)
        return view
    }()
    
    fileprivate lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#333333")
        label.text = "总金额"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor.ls_color("#333333")
        textField.delegate = self
        textField.font = kFontRegualer16
        textField.textAlignment = .right
        textField.keyboardType = .decimalPad
        textField.attributedPlaceholder = NSAttributedString(string: "¥0.00", attributes: [NSAttributedString.Key.foregroundColor: kColorTextTips])
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    fileprivate lazy var amountUnitLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#333333")
        label.text = "¥"
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    // 总金额，大数字显示
    fileprivate lazy var bigAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_boldFont(36)
        label.textColor = UIColor.ls_color("#333333")
        label.text = "¥0.00"
        label.sizeToFit()
        return label
    }()
    
    // 发红包
    fileprivate lazy var sendBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE5B5B")
        button.setTitle("发红包", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = kFontMedium18
        button.layer.cornerRadius = 23
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickSendBtn(_:)), for: .touchUpInside)
        return button
    }()
    
}

extension SendRedPacketController {
    
    func setData(_ uniCode: String, personCount: Int, userId: String, taskId: Int64) {
        
        self.uniqueCode = uniCode
        self.personCount = personCount
        self.userId = userId
        self.taskId = taskId
        
        resetUI()
    }
    
    func resetUI() {
        
        // 判断是个人红包还是群红包
        if uniqueCode.isEmpty {
            typeSelectBtn.isHidden = true
            countView.isHidden = true
            personCountLabel.isHidden = true
        } else {
            typeSelectBtn.isHidden = false
            countView.isHidden = false
            personCountLabel.isHidden = false
        }
    }
    
    // 点击选择类别
    @objc fileprivate func clickTypeSelectBtn(_ sender:UIButton) {
        LSLog("clickTypeSelectBtn")
        // 创建一个UIAlertController
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // 添加操作按钮
        let option1 = UIAlertAction(title: "拼手气红包", style: .default) { (action) in
            // 处理选项1的操作
            self.type = .RedPacketTypeLuck
            self.typeLabel.text = action.title
        }

        let option2 = UIAlertAction(title: "普通红包", style: .default) { (action) in
            // 处理选项2的操作
            self.type = .RedPacketTypeAverage
            self.typeLabel.text = action.title
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
    
    @objc func countDidClick() {
        LSLog("countDidClick")
        countTextField.becomeFirstResponder()
    }
    
    @objc func amountDidClick() {
        LSLog("amountDidClick")
        amountTextField.becomeFirstResponder()
    }
    
    @objc func clickSendBtn(_ sender: UIButton) {
        LSLog("clickSendBtn")
        if !checkParam() {
            return
        }
        var count:Int64 = 0
        if uniqueCode.isEmpty {
            count = 1
        } else {
            count = Int64(countTextField.text?.trim() ?? "") ?? 0
        }
        
        var amount = (Int64(amountTextField.text?.trim() ?? "") ?? 0)*100
        NetworkManager.shared.sendRedPacket(taskId, uniqueCode: uniqueCode, toUserId: userId, count: count, amount: amount, getType: type.rawValue) { resp in
            
            if resp.status == .success {
                LSLog("sendRedPacket succ")
                self.pop()
            } else {
                LSLog("sendRedPacket fail")
                LSHUD.showError(resp.msg)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let newWidth = textField.intrinsicContentSize.width
        LSLog("textFieldDidChange newWidth:\(newWidth)")
//        textField.widthAnchor.constraint(equalToConstant: newWidth).isActive = true
    }
    
    func checkParam() -> Bool {
        
        // 群红包、单人红包检查参数不同
        if uniqueCode.isEmpty {
            
        } else {
            if (countTextField.text!.isEmpty) {
                LSLog("checkParam count err")
                LSHUD.showError("未填写「红包个数」")
                return false
            }
        }
        
        if (amountTextField.text!.isEmpty) {
            LSLog("checkParam amount err")
            LSHUD.showError("未填写「总金额」")
            return false
        }
        
        return true
    }
}

extension SendRedPacketController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == amountTextField {
            // 获取当前文本
            if let currentText = textField.text as NSString? {
                // 将替换后的文本与当前文本合并
                let newText = currentText.replacingCharacters(in: range, with: string)
                let inputValue = Double(newText)
                // 使用格式化字符串将Double值保留两位小数
                bigAmountLabel.text = String(format: "¥%.2f", inputValue ?? 0)
                
                amountUnitLabel.isHidden = newText.isEmpty
                
                return newText.count <= maxCharacterCount
            }
        }
        
        // 检查是否超过了最大字符数
        return true
    }
}

extension SendRedPacketController {
    
    fileprivate func setupUI() {
        
        view.addSubview(typeSelectBtn)
        typeSelectBtn.addSubview(typeLabel)
        typeSelectBtn.addSubview(typeArrow)
        view.addSubview(countView)
        countView.addSubview(countLabel)
        countView.addSubview(countUnitLabel)
        countView.addSubview(countTextField)
        view.addSubview(personCountLabel)
        view.addSubview(amountView)
        amountView.addSubview(amountLabel)
        amountView.addSubview(amountTextField)
        amountView.addSubview(amountUnitLabel)
        view.addSubview(bigAmountLabel)
        view.addSubview(sendBtn)
        
        
        typeSelectBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight+yMargin)
            make.left.equalToSuperview().offset(xMargin)
            make.size.equalTo(CGSize(width: 100, height: 24))
        }
        
        typeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }
        
        typeArrow.snp.makeConstraints { (make) in
            make.left.equalTo(typeLabel.snp.right).offset(6)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 14, height: 14))
        }
        
        countView.snp.makeConstraints { (make) in
            make.top.equalTo(typeSelectBtn.snp.bottom).offset(yMargin)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
            make.height.equalTo(58)
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.centerY.equalToSuperview()
        }
        
        countUnitLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-xMargin)
            make.centerY.equalToSuperview()
        }
        
        countTextField.snp.makeConstraints { (make) in
            make.right.equalTo(countUnitLabel.snp.left).offset(-xMargin)
            make.centerY.equalToSuperview()
        }
        
        personCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(countView.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(32)
        }
        
        if uniqueCode.isEmpty {
            amountView.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(kNavBarHeight+yMargin)
                make.left.equalToSuperview().offset(xMargin)
                make.right.equalToSuperview().offset(-xMargin)
                make.height.equalTo(58)
            }
        } else {
            amountView.snp.makeConstraints { (make) in
                make.top.equalTo(personCountLabel.snp.bottom).offset(yMargin)
                make.left.equalToSuperview().offset(xMargin)
                make.right.equalToSuperview().offset(-xMargin)
                make.height.equalTo(58)
            }
        }
        
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.centerY.equalToSuperview()
        }
        
        amountTextField.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-xMargin)
            make.centerY.equalToSuperview()
        }
        
        amountUnitLabel.snp.makeConstraints { (make) in
            make.right.equalTo(amountTextField.snp.left)
            make.centerY.equalTo(amountTextField)
        }
        
        bigAmountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(amountView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
        
        sendBtn.snp.makeConstraints { (make) in
            make.top.equalTo(bigAmountLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
            make.height.equalTo(46)
        }
    }
}
