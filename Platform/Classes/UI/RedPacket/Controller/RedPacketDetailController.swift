//
//  RedPacketDetailController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

class RedPacketDetailController: BaseController {
    
    let leftMargin = 16.0
    let headerHeight: CGFloat = 386.0
    let topHeight: CGFloat = 336.0
    let redViewHeight: CGFloat = 124.0
    let CellHeight: CGFloat = 62
    var redPacketDetail: QueryRedPacketModel = QueryRedPacketModel()
    var limMsg: LIMMessage = LIMMessage()
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.ls_color("#F8F8F8")
        setupUI()
        resetNavigation()

        // 获取红包详情
        getRedPacketDetail()
    }
    
    fileprivate lazy var headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    // TopView
    fileprivate lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate lazy var redView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: redViewHeight))
        // 创建 UIBezierPath 来绘制弧形
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: view.bounds.width, y: view.bounds.height * 0.70))
        bezierPath.addLine(to: CGPoint(x: view.bounds.width, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: view.bounds.height * 0.70))
        bezierPath.addQuadCurve(to: CGPoint(x: view.bounds.width, y: view.bounds.height * 0.70), controlPoint: CGPoint(x: view.bounds.width / 2, y: view.bounds.height+60)) // 添加二次贝塞尔曲线，形成弧形
        
        // 创建 CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        
        // 设置 CAShapeLayer 的属性
        shapeLayer.fillColor = UIColor.ls_color("#F95A65").cgColor // 填充颜色
//        shapeLayer.strokeColor = UIColor.clear.cgColor // 边框颜色
        
        // 将 CAShapeLayer 添加到 UIView 的 layer 中
        view.layer.addSublayer(shapeLayer)
        return view
    }()
    
    // 头像
    fileprivate lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 28
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderAvatar)
        return imageView
    }()
    
    // 昵称
    fileprivate lazy var nickLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium16
        label.textColor = UIColor.ls_color("#333333")
        label.text = "发出的红包"
        label.sizeToFit()
        return label
    }()
    
    // 总金额
    fileprivate lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(36)
        label.textColor = UIColor.ls_color("#FE9C5B")
        label.sizeToFit()
        return label
    }()
    
    // 分割区域
    fileprivate lazy var splitView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ls_color("#F7F7F7")
        return view
    }()
    
    // 红包个数、总金额
    fileprivate lazy var midView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // 红包记录标题
    fileprivate lazy var logTitleLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#999999")
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var logSplitView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ls_color("#ededed")
        return view
    }()
    
    // 评论列表
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
        tableView.rowHeight = UITableView.automaticDimension
        
        // 注册UITableViewCell类
        tableView.register(RedPacketLogCell.self, forCellReuseIdentifier: "RedPacketLogCell")
        return tableView
    }()
}

extension RedPacketDetailController {
    
    func setData(_ limMsg:LIMMessage) {
        self.limMsg = limMsg
        
        refreshData()
    }
    
    // 获取详情
    func getRedPacketDetail() {
        NetworkManager.shared.queryRedPacket(limMsg.redPacketElem?.id ?? 0)  { resp in
            if resp.status == .success {
                LSLog("queryRedPacket resp:\(resp)")
                
                if let data = resp.data {
                    self.handleData(data)
                }
                
            } else {
                LSLog("queryRedPacket fail")
            }
        }
    }
    
    func handleData(_ data:QueryRedPacketModel) {
        redPacketDetail = data
        // 处理手气最佳
        if redPacketDetail.logs.count == redPacketDetail.count, redPacketDetail.getType == RedPacketType.RedPacketTypeLuck.rawValue {
            var maxIndex = -1
            var maxValue:Int64 = 0
            for i in 0 ..< redPacketDetail.logs.count {
                let item = redPacketDetail.logs[i]
                if item.amount > maxValue {
                    maxIndex = i
                    maxValue = item.amount
                }
            }
            
            if maxIndex >= 0, maxIndex < redPacketDetail.logs.count {
                redPacketDetail.logs[maxIndex].isMax = true
            }
        }
        
        refreshData()
    }
    
    // 刷新界面
    func refreshData() {
        // 发送者头像
        avatar.kf.setImage(with: URL(string: limMsg.faceURL), placeholder: PlaceHolderAvatar)
        
        // 发送者昵称
        nickLabel.text = "\(limMsg.nickName ?? "")发出的红包"
        nickLabel.sizeToFit()
        
        // 金额
        let unitString: String = "元"
        let amountString: String = String(format: "%.2f\(unitString)", Double(redPacketDetail.amount)/100 )
        let attributedText = NSMutableAttributedString(string: amountString)
        attributedText.addAttributes([.font: kFontRegualer14], range: NSRange(location: attributedText.length - unitString.count, length: unitString.count))
        amountLabel.attributedText = attributedText
        amountLabel.sizeToFit()
        
        // 记录标题
        logTitleLabel.text = String(format: "\(redPacketDetail.count)个红包，总金额：¥%.2f", Double(redPacketDetail.amount)/100 )
        
        // 刷新界面
        tableView.reloadData()
    }
}

// UITableView 代理
extension RedPacketDetailController: UITableViewDataSource, UITableViewDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return redPacketDetail.logs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RedPacketLogCell", for: indexPath) as! RedPacketLogCell
        let item = redPacketDetail.logs[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

extension RedPacketDetailController {
    
    fileprivate func setupUI() {
        
        headerView.addSubview(topView)
        topView.addSubview(redView)
        topView.addSubview(avatar)
        topView.addSubview(nickLabel)
        topView.addSubview(amountLabel)
        headerView.addSubview(splitView)
        headerView.addSubview(midView)
        midView.addSubview(logTitleLabel)
        midView.addSubview(logSplitView)
        view.addSubview(tableView)
        
        
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
        
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(topHeight)
        }
        
        redView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(redViewHeight)
        }
        
        avatar.snp.makeConstraints { (make) in
            make.top.equalTo(redView.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
        
        nickLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatar.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        amountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nickLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        splitView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(10)
        }
        
        midView.snp.makeConstraints { (make) in
            make.top.equalTo(splitView.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }
        
        logTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.centerY.equalToSuperview()
        }
        
        logSplitView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    fileprivate func resetNavigation() {
        
        navigationView.backgroundColor = UIColor.clear
        navigationView.backView.backgroundColor = UIColor.clear
        
        let leftImg = UIImage(named: "icon_back_white")
        let backImg = leftImg?.withRenderingMode(.alwaysOriginal)
        navigationView.leftButton.setImage(backImg, for: .normal)
    }
}
