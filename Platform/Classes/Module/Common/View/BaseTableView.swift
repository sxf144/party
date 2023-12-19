//
//  BaseTableView.swift
//  constellation
//
//  Created by Lee on 2020/4/28.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

enum DataStatus: Int {
    /// 无状态
    case none = 0
    /// 加载中
    case loading = 1
    /// 加载失败
    case error = 2
    /// 无数据
    case empty = 3
    /// 无定位
    case location = 4
}

class BaseTableView: UITableView {
    
    /// 回调闭包
    public var actionBlock: (() -> ())?
    let ImageWidth: CGFloat = 375
    let ImageHeight: CGFloat = 254
    let loadingImage = UIImage(named: "icon_loading")
    let errorImage = UIImage(named: "icon_error")
    let emptyImage = UIImage(named: "icon_empty")
    let noLocationImage = UIImage(named: "icon_nolocation")
    var dataStatus: DataStatus = .none {
        didSet {
            LSLog("dataStatus didSet:\(dataStatus)")
            switch dataStatus {
            case .none:
                backView.isHidden = true
            case .loading:
                backView.isHidden = false
                actionButton.isHidden = true
                iconImageView.image = loadingImage
                textLabel.text = "加载中..."
                textLabel.sizeToFit()
            case .error:
                backView.isHidden = false
                actionButton.isHidden = false
                iconImageView.image = errorImage
                textLabel.text = "加载失败，点击重试"
                textLabel.sizeToFit()
                actionButton.setTitle("重试", for: .normal)
            case .empty:
                backView.isHidden = false
                actionButton.isHidden = true
                iconImageView.image = emptyImage
                textLabel.text = "这里什么也没有"
                textLabel.sizeToFit()
            case .location:
                backView.isHidden = false
                actionButton.isHidden = false
                iconImageView.image = noLocationImage
                textLabel.text = "请打开定位权限"
                textLabel.sizeToFit()
                actionButton.setTitle("打开定位", for: .normal)
            }
        }
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()

        if let newWindow = window {
            // 视图被添加到新的窗口，重置backgroundView的height
            LSLog("Entered window: \(newWindow)")
            backView.snp.remakeConstraints { (make) in
                make.width.equalTo(self.bounds.width)
                make.height.equalTo(self.bounds.height)
                make.center.equalToSuperview()
            }
        } else {
            // 视图从窗口中移除
            LSLog("Left window")
        }
    }
    
    /// 加载中
    lazy var backView: UIView = {
        let view = UIView()
        self.backgroundView = view
        return view
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_loading")
        return imageView
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer14
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = "这里什么也没有"
        label.sizeToFit()
        return label
    }()

    /// 操作按钮
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 21
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitleColor(.white, for: .normal)
        button.setTitle("重试", for: .normal)
        button.titleLabel?.font = kFontMedium16
        button.addTarget(self, action: #selector(clickActionBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension BaseTableView {
    
    @objc func clickActionBtn(_ sender: UIButton) {
        LSLog("clickActionBtn")
        if let actionBlock = actionBlock {
            actionBlock()
        }
        
        // 打开定位
        if dataStatus == .location {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

fileprivate extension BaseTableView {
    
    func setupView() {
        
        backView.addSubview(iconImageView)
        backView.addSubview(textLabel)
        backView.addSubview(actionButton)
        
        backView.snp.makeConstraints { (make) in
            make.width.equalTo(self.bounds.width)
            make.height.equalTo(self.bounds.height)
            make.center.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.size.equalTo(CGSize(width: ImageWidth, height: ImageHeight))
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom).offset(-30)
        }
        
        actionButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(textLabel.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 180, height: 42))
        }
    }
}
