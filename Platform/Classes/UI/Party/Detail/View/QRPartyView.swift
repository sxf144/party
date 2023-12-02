//
//  QRPartyView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import swiftScan

class QRPartyView: UIView {
    
    static let shared = QRPartyView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
    let qrSize: CGSize = CGSize(width: 280, height: 280)
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 16
    var uniqueCode: String = ""
    
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
    
    // 二维码图片
    fileprivate lazy var qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderBig)
        return imageView
    }()
    
    // 提示文字
    fileprivate lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium18
        label.textColor = UIColor.white
        label.text = "使用桔子糖APP扫码加入"
        label.sizeToFit()
        label.numberOfLines = 4
        label.lineBreakMode = .byWordWrapping
        return label
    }()
}


extension QRPartyView {
    
    // 取消
    @objc fileprivate func cancelDidClick(){
        LSLog("cancelDidClick")
        removeTaskView()
    }
    
    /// 显示 view
    func showInWindow(_ uniqueCode:String) {
        self.uniqueCode = uniqueCode
        LSHUD.showLoading()
        if !self.uniqueCode.isEmpty {
            let qrCodeUrl = "https://static.juzitang.net/detail?code=\(self.uniqueCode)"
            // 调用生成二维码的方法
            if let qrCodeImage = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator", codeString: qrCodeUrl, size: qrSize, qrColor: .black, bkColor: .white) {
                qrImageView.image = qrCodeImage
            }
            LSHUD.hide()
        }
        
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        keyWindow!.addSubview(self)
        keyWindow!.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.3) {
            self.bgView.alpha = 0.6
            self.contentView.alpha = 1.0
        }
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



extension QRPartyView {
    
    fileprivate func setupUI() {
        
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(qrImageView)
        contentView.addSubview(tipLabel)
        
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        qrImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(qrSize)
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(qrImageView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
    }
}
