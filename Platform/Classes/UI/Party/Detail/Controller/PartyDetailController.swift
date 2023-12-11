//
//  PartyDetailController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh
import IQKeyboardManagerSwift

class PartyDetailController: BaseController {
    
    // chatKeyBoard
    private let kToolBarLastH: CGFloat = 52
    
    let userInfo = LoginManager.shared.getUserInfo()
    let leftMargin = 16.0
    let CellHeight = 110.0
    let topHeight:CGFloat = 300.0
    let creatorAvatarWidth = 46.0
    let ParticipateKey = "ParticipateKey"
    var uniCode: String = ""
    var partyDetail: PartyDetailModel?
    var participateData: ParticipateModel?
    var commentData: CommentListModel = CommentListModel()
    var joinData: JoinModel?
    var tempIndexPath: IndexPath?
    var selectedIndexPath: IndexPath?
    var isOwner = false
    var coverImage: UIImage?
    var isActive: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // 重置Navigation
        resetNavigation()
        setupUI()
        
        // 设置下拉刷新
        commentTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            // 在这里执行下拉刷新的操作，例如加载最新数据
            self?.loadNewData()
        })
        
        // 设置上拉加载更多
        commentTableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            // 在这里执行上拉加载更多的操作，例如加载更多数据
            self?.loadMoreData()
        })
        
        commentTableView.mj_header?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        LSLog("ChatController viewWillAppear")
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        LSLog("ChatController viewDidDisappear")
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    fileprivate lazy var headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    // TopView
    fileprivate lazy var topView: UIView = {
        let view = UIView()
        return view
    }()
    
    // 局封面
    fileprivate lazy var cover: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderBig)
        return iv
    }()
    
    // 组局人头像
    fileprivate lazy var creatorAvatar: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.ls_cornerRadius(CGFloat(creatorAvatarWidth/2))
        iv.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderAvatar)
        return iv
    }()
    
    fileprivate lazy var creatorTipView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 9
        v.backgroundColor = UIColor.ls_color("#FE9C5B")
        return v
    }()
    
    fileprivate lazy var creatorTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(10)
        label.textColor = UIColor.white
        label.text = "组局人"
        label.sizeToFit()
        return label
    }()
    
    // 二维码
    fileprivate lazy var qrCodeBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_qrcode"), for: .normal)
        button.addTarget(self, action: #selector(clickQrCodeBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 详情view
    fileprivate lazy var detailView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        v.layer.cornerRadius = 8
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()
    
    // 时间
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(16)
        label.textColor = UIColor.ls_color("#333333")
        label.text = " "
        label.sizeToFit()
        return label
    }()
    
    // 费用
    fileprivate lazy var feeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(14)
        label.textColor = UIColor.ls_color("#999999")
        label.text = " "
        label.sizeToFit()
        return label
    }()
    
    // 组局介绍
    fileprivate lazy var introductionView: UIView = {
        let v = UIView()
        return v
    }()
    
    fileprivate lazy var introductionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(16)
        label.textColor = UIColor.ls_color("#333333")
        label.text = "组局介绍"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var introductionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(14)
        label.textColor = UIColor.ls_color("#666666")
        label.text = " "
        label.sizeToFit()
        return label
    }()
    
    // 主打游戏
    fileprivate lazy var gameView: UIView = {
        let view = UIView()
        // 添加点击手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGameTap))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    fileprivate lazy var gameTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(16)
        label.textColor = UIColor.ls_color("#333333")
        label.text = "主打游戏"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var gameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(14)
        label.textColor = UIColor.ls_color("#666666")
        label.text = "无游戏/稍后选择"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var gameArrow: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "icon_arrow_right")
        return iv
    }()
    
    // 地点
    fileprivate lazy var addressView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var addressTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(16)
        label.textColor = UIColor.ls_color("#333333")
        label.text = "活动场所"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var addressMapView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.ls_color("#F9F9F9")
        // 添加点击手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLocationTap))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    fileprivate lazy var addressLocalIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_location1")
        return imageView
    }()
    
    // 名称
    fileprivate lazy var addressNameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium16
        label.textColor = UIColor.ls_color("#333333")
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.text = " "
        label.sizeToFit()
        return label
    }()
    
    // 地址
    fileprivate lazy var addressDetailLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.text = " "
        label.sizeToFit()
        return label
    }()
    
    // 参与人
    fileprivate lazy var personView: UIView = {
        let v = UIView()
        return v
    }()
    
    fileprivate lazy var personTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(16)
        label.textColor = UIColor.ls_color("#333333")
        label.text = "参与人（0/0）"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var personContent: UIView = {
        let v = UIView()
        return v
    }()
    
    // footer
    fileprivate lazy var footerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: kTabBarHeight + 40))
        return view
    }()
    
    fileprivate lazy var footLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(12)
        label.textColor = UIColor.ls_color("#999999")
        label.text = "展开更多评论"
        label.sizeToFit()
        // 添加点击手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFooterTap))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    fileprivate lazy var footerIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "icon_expand")
        return iv
    }()
    
    // 评论列表
    fileprivate lazy var commentTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
//        tableView.tableFooterView = footerView
        tableView.estimatedRowHeight = CellHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        // 注册UITableViewCell类
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.register(SubCommentCell.self, forCellReuseIdentifier: "SubCommentCell")
        return tableView
    }()
    
    // 创建底部工具栏
    fileprivate lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    // 评论按钮
    fileprivate lazy var commentBtn: UIButton = {
        let button = UIButton(frame: CGRectMake(0, 0, 112, 40))
        button.backgroundColor = UIColor.ls_color("#F4F4F4")
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.setTitle("写评论", for: .normal)
        button.setTitleColor(UIColor.ls_color("#CFCFCF"), for: .normal)
        button.titleLabel?.font = kFontMedium15
        button.addTarget(self, action: #selector(clickCommentBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 加入组局
    fileprivate lazy var joinBtn: UIButton = {
        let button = UIButton()
        button.setTitleColor(kColorTextWhite, for: .normal)
        button.titleLabel?.font = kFontMedium15
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitle("加入组局", for: .normal)
        button.addTarget(self, action: #selector(clickJoinBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var chatKeyboard: ChatKeyboardView = {
        let keyBoard = ChatKeyboardView(frame: CGRect(x: 0, y: kScreenH, width: kScreenW, height: kToolBarLastH))
        keyBoard.needHiddenToolBar = true
        keyBoard.delegate = self
        return keyBoard
    }()
}

extension PartyDetailController {
    
    func setData(uniqueCode: String) {
        uniCode = uniqueCode
    }
    
    // 获取详情
    func getPartyDetail() {
        LSHUD.showLoading()
        NetworkManager.shared.getPartyDetail (uniCode) { resp in
            LSHUD.hide()
            if resp.status == .success {
                LSLog("getPartyDetail data:\(resp.data)")
                self.partyDetail = resp.data
                self.refreshData()
                self.refreshPersions()
            } else {
                LSLog("getPartyDetail fail")
            }
        }
    }
    
    // 获取参与人信息
    func getParticipateList() {
        
        NetworkManager.shared.getParticipateList(uniCode) { resp in
            if resp.status == .success {
                LSLog("getParticipateList data:\(resp.data)")
                self.participateData = resp.data
                self.refreshPersions()
            } else {
                LSLog("getParticipateList fail")
            }
        }
    }
    
    // 获取评论
    func getComments(pageNum:Int64, pageSize:Int64, uniqueCode:String , parentId:Int64) {
        
        NetworkManager.shared.getComments(pageNum, pageSize: pageSize, uniqueCode: uniqueCode, parentId: parentId ) { resp in
            
            if (self.commentTableView.mj_header.isRefreshing) {
                self.commentTableView.mj_header.endRefreshing()
            }
            
            if (self.commentTableView.mj_footer.isRefreshing) {
                self.commentTableView.mj_footer.endRefreshing()
            }
            
            if resp.status == .success {
                LSLog("getComments succ")
                self.handleCommentsData(parentId: parentId, data: resp.data)
            } else {
                LSLog("getComments fail")
            }
        }
    }
    
    // 发评论
    func sendComment(_ uniqueCode:String, content:String) {
        var toCommentItem: CommentItem?
        if let indexPath = selectedIndexPath {
            if (indexPath.row == 0) {
                toCommentItem = commentData.comments[indexPath.section]
            } else {
                let pitem = commentData.comments[indexPath.section]
                toCommentItem = pitem.childComments[indexPath.row-1]
            }
        }
        
        // 构造本地评论数据
        let fromUser:UserBrief = UserBrief()
        fromUser.userId = userInfo?.userId ?? ""
        fromUser.nick = userInfo?.nick ?? ""
        fromUser.portrait = userInfo?.portrait ?? ""
        fromUser.sex = userInfo?.sex ?? 0
        var toUser:UserBrief = UserBrief()
        let tempComment:CommentItem = CommentItem()
        tempComment.from = fromUser
        tempComment.commentTime = Date().ls_formatterStr("yyyy-MM-dd HH:mm:ss")
        tempComment.content = content
        if let toCommentItem = toCommentItem {
            tempComment.parentId = toCommentItem.parentId
            toUser = tempComment.from
        }
        tempComment.to = toUser
        updateComment(tempComment)
        
        NetworkManager.shared.sendComment(uniqueCode, toCommentId: toCommentItem?.id ?? 0, content: content ) { [self] resp in
            if resp.status == .success {
                LSLog("sendComment succ")
                self.selectedIndexPath = nil
                self.tempIndexPath = nil
                tempComment.id = resp.data.commentId
                self.updateComment(tempComment)
            } else {
                self.selectedIndexPath = nil
                self.tempIndexPath = nil
                LSLog("sendComment fail")
                
            }
        }
    }
    
    // 邀请加入组局
    func inviteJoinParty(_ peopleIds:[String]) {
        NetworkManager.shared.inviteJoinParty(uniCode, peopleIds: peopleIds) { resp in
            
            if resp.status == .success {
                LSLog("inviteJoinParty:\(resp)")
                LSHUD.showInfo("邀请已发出")
            } else {
                LSLog("inviteJoinParty fail")
            }
        }
    }
    
    // 加入组局
    func joinParty() {
        LSHUD.showLoading()
        NetworkManager.shared.joinParty(uniCode) { resp in
            LSHUD.hide()
            if resp.status == .success {
                LSLog("joinParty data:\(resp.data)")
                self.joinData = resp.data
                
                // 判断是否需要支付
                if let orderId = self.joinData?.orderId, !orderId.isEmpty {
                    self.payForParty(orderId)
                } else {
                    self.joinStatusChanged()
                    self.showSuccAlert()
                }
            } else {
                LSLog("joinParty fail")
                LSHUD.showError(resp.msg)
            }
        }
    }
    
    // 移除成员
    func kickOut(_ items:[SimpleUserInfo]) {
        if items.count <= 0 {
            return
        }
        var peopleIds:[String] = []
        for i in 0 ..< items.count {
            let fItem = items[i]
            peopleIds.append(fItem.userId)
        }
        LSHUD.showLoading()
        NetworkManager.shared.kickOut(uniCode, peopleIds: peopleIds) { resp in
            LSHUD.hide()
            if resp.status == .success {
                LSLog("kickOut succ")
                LSHUD.showInfo("操作成功")
                self.getParticipateList()
            } else {
                LSLog("kickOut fail")
                LSHUD.showError(resp.msg)
            }
        }
    }
    
    // 退出局
    func leaveParty() {
        LSHUD.showLoading()
        NetworkManager.shared.leaveParty(uniCode) { resp in
            LSHUD.hide()
            if resp.status == .success {
                LSLog("leaveParty succ")
                self.joinStatusChanged()
                self.pop()
            } else {
                LSLog("joinParty fail")
                LSHUD.showError(resp.msg)
            }
        }
    }
    
    // 解散组局
    func dismissParty() {
        LSHUD.showLoading()
        NetworkManager.shared.dismissParty(uniCode) { [weak self] resp in
            LSHUD.hide()
            if resp.status == .success {
                LSLog("dismissParty succ")
                self?.partyDetail?.state = 2
                // 发送局状态变更通知
                LSNotification.postPartyStatusChange(self?.partyDetail ?? PartyDetailModel())
                // 返回
                self?.pop()
            } else {
                LSLog("dismissParty fail")
                LSHUD.showError(resp.msg)
            }
        }
    }
    
    func payForParty(_ orderId:String) {
        // 需要付费
        LSHUD.showLoading()
        // 渠道号1是微信，默认为1
        NetworkManager.shared.prePayJoinOrder(orderId) { resp in
            LSLog("prePayJoinOrder resp:\(resp)")
            LSHUD.hide()
            if resp.status == .success {
                LSLog("prePayJoinOrder succ")
                if let order = resp.data {
                    WXApiManager.shared.payBlock = { [weak self] oId, status in
                        LSLog("payBlock oId:\(oId), status:\(status)")
                        if oId == orderId {
                            self?.joinStatusChanged()
                            self?.showSuccAlert()
                        }
                    }
                    WXApiManager.shared.sendPayRequest(order, orderId: orderId)
                }
            } else {
                LSLog("prePayJoinOrder fail")
                LSHUD.showInfo(resp.msg)
            }
        }
    }
    
    func joinStatusChanged() {
        // 加入成功后，刷新数据
        self.loadNewData()
        // 发送局状态变更通知
        LSNotification.postPartyStatusChange()
    }
    
    func showSuccAlert() {
        // 提示成功加入
        let alertController = BaseAlertController(title: "加入成功，请准时赴约。", message: nil)
        
        let okAction = BaseAlertAction(title: "确定", style: .destructive) { (action) in

        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func refreshData() {
        if let detail = partyDetail {
            isOwner = userInfo?.userId == detail.userId
            
            // 封面
            cover.kf.setImage(with: URL(string: detail.coverThumbnail ), placeholder: PlaceHolderBig) { result in
                switch result {
                case .success(let value):
                    LSLog("cover load succ")
                    self.coverImage = value.image
                case .failure(let error):
                    LSLog("cover load error:\(error)")
                }
                
            }
            
            // 创建者头像
            creatorAvatar.kf.setImage(with: URL(string: detail.portrait ), placeholder: PlaceHolderAvatar)
            
            // 时间
            timeLabel.text = Date.formatDate(startTime: detail.startTime, endTime: detail.endTime)
            timeLabel.sizeToFit()
            
            // 费用
            if detail.fee != 0 {
                let newFee = String(format: "%.2f", Float(detail.fee)/100)
                feeLabel.text = "费用：¥" + String(newFee)
                feeLabel.sizeToFit()
            } else {
                feeLabel.text = "费用免费"
                feeLabel.sizeToFit()
            }
            
            // 组局介绍
            introductionLabel.text = detail.introduction
            introductionLabel.sizeToFit()
            
            // 主打游戏
            if !detail.relationGame.name.isEmpty {
                gameLabel.text = detail.relationGame.name
                gameLabel.sizeToFit()
            }
            
            // 活动场所
            addressNameLabel.text = detail.landmark
            addressNameLabel.sizeToFit()
            addressDetailLabel.text = detail.address
            addressDetailLabel.sizeToFit()
            
            // 根据参数确认底部按钮
            if detail.state == 2 {
                // 已解散
                joinBtn.isEnabled = false
                joinBtn.layer.borderWidth = 0
                joinBtn.backgroundColor = UIColor.ls_color("#eeeeee")
                joinBtn.setTitleColor(UIColor.ls_color("#999999"), for: .disabled)
                joinBtn.setTitle("已解散", for: .normal)
            } else if detail.state == 3 {
                // 已解散
                joinBtn.isEnabled = false
                joinBtn.layer.borderWidth = 0
                joinBtn.backgroundColor = UIColor.ls_color("#eeeeee")
                joinBtn.setTitleColor(UIColor.ls_color("#999999"), for: .disabled)
                joinBtn.setTitle("已结束", for: .normal)
            } else if (isOwner) {
                // 是自己创建的局，按钮文字展示为解散此桔
                joinBtn.isEnabled = true
                joinBtn.backgroundColor = UIColor.white
                joinBtn.layer.borderWidth = 1
                joinBtn.layer.borderColor = UIColor.ls_color("#FE9C5B").cgColor
                joinBtn.setTitleColor(UIColor.ls_color("#FE9C5B"), for: .normal)
                joinBtn.setTitle("解散此桔", for: .normal)
            } else if (detail.joinState == 1) {
                // 已加入
                joinBtn.layer.borderWidth = 0
                joinBtn.backgroundColor = UIColor.ls_color("#eeeeee")
                joinBtn.setTitleColor(UIColor.ls_color("#999999"), for: .disabled)
                joinBtn.setTitle("已加入", for: .normal)
            } else if (detail.maleRemainCount == 0 && detail.femaleRemainCount == 0) {
                // 空余位置为0，已满员
                joinBtn.isEnabled = false
                joinBtn.layer.borderWidth = 0
                joinBtn.backgroundColor = UIColor.ls_color("#eeeeee")
                joinBtn.setTitleColor(UIColor.ls_color("#999999"), for: .disabled)
                joinBtn.setTitle("已满员", for: .normal)
            } else if (detail.joinState == 2) {
                // 待付款
                joinBtn.isEnabled = true
                joinBtn.layer.borderWidth = 0
                joinBtn.backgroundColor = UIColor.ls_color("#FE9C5B")
                joinBtn.setTitleColor(UIColor.white, for: .normal)
                let fee = String(format: "%.2f", Float(detail.fee)/100)
                joinBtn.setTitle("¥\(fee)加入组局", for: .normal)
            } else if (detail.joinState == 0) {
                // 未加入
                joinBtn.isEnabled = true
                joinBtn.layer.borderWidth = 0
                joinBtn.backgroundColor = UIColor.ls_color("#FE9C5B")
                joinBtn.setTitleColor(UIColor.white, for: .normal)
                joinBtn.setTitle("加入组局", for: .normal)
            }
        }
    }
    
    func refreshPersions() {
        // 需要数据partyDetail、participateData都存在才能绘制
        if let pDetail = partyDetail, let partData = participateData {
            // 参与人
            let total = pDetail.maleCnt + pDetail.femaleCnt
            personTitleLabel.text = "参与人（\(partData.participateList.count)/\(total)）"
            personTitleLabel.sizeToFit()
            
            // 移除personContent 所有子view
            for subview in personContent.subviews {
                subview.removeFromSuperview()
            }
            
            view.layoutIfNeeded()
            
            let h_count:Int = 4
            let h_margin:CGFloat = 8.0
            let v_margin:CGFloat = 5.0
            let v_width = (personContent.frame.width + h_margin)/CGFloat(h_count) - h_margin
            let v_height:CGFloat = 106
            let len = partData.participateList.count
            for i in 0 ..< len {
                let item = partData.participateList[i]
                
                let pcBtn = UIButton()
                pcBtn.layer.cornerRadius = 8
                pcBtn.backgroundColor = UIColor.ls_color("#F9F9F9")
                pcBtn.addTarget(self, action: #selector(clickPcBtn(_:)), for: .touchUpInside)
                pcBtn.layer.setValue(i, forKey: ParticipateKey)
                personContent.addSubview(pcBtn)
                
                let pIV = UIImageView()
                pIV.layer.cornerRadius = 22
                pIV.clipsToBounds = true
                pIV.contentMode = .scaleAspectFill
                pIV.kf.setImage(with: URL(string: item.portrait), placeholder: PlaceHolderAvatar)
                pcBtn.addSubview(pIV)
                
                let aIV = UIImageView()
                aIV.image = UIImage(named: item.sex == 1 ? "icon_male" : "icon_female")
                pcBtn.addSubview(aIV)
                
                let nick = UILabel()
                nick.font = UIFont.ls_font(12)
                nick.textColor = UIColor.ls_color("#333333")
                nick.text = item.nick
                nick.sizeToFit()
                pcBtn.addSubview(nick)
                
                
                let v_left:CGFloat = CGFloat(i%h_count) * (v_width + h_margin)
                let v_top:CGFloat = CGFloat(i/h_count) * (v_margin + v_height)
                
                pcBtn.snp.makeConstraints { (make) in
                    make.left.equalTo(v_left)
                    make.top.equalTo(v_top)
                    make.width.equalTo(v_width)
                    make.height.equalTo(v_height)
                }
                
                pIV.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().offset(16)
                    make.size.equalTo(CGSize(width: 44, height: 44))
                }
                
                aIV.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.centerY.equalTo(pIV.snp.bottom)
                    make.size.equalTo(CGSize(width: 16, height: 16))
                }
                
                nick.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(pIV.snp.bottom).offset(16)
                }
            }
            
            // 邀请
            var finalLen = len
            finalLen += 1
            let pcBtn = UIButton()
            pcBtn.layer.cornerRadius = 8
            pcBtn.backgroundColor = UIColor.ls_color("#F9F9F9")
            pcBtn.addTarget(self, action: #selector(handleAddPersonTap(_:)), for: .touchUpInside)
            personContent.addSubview(pcBtn)
            
            let addIcon = UIImageView()
            addIcon.layer.cornerRadius = 22
            addIcon.clipsToBounds = true
            addIcon.image = UIImage(named: "icon_add_person")
            pcBtn.addSubview(addIcon)
            
            let v_left:CGFloat = CGFloat((finalLen-1)%h_count) * (v_width + h_margin)
            let v_top:CGFloat = CGFloat((finalLen-1)/h_count) * (v_margin + v_height)
            pcBtn.snp.makeConstraints { (make) in
                make.left.equalTo(v_left)
                make.top.equalTo(v_top)
                make.width.equalTo(v_width)
                make.height.equalTo(v_height)
            }
            
            addIcon.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 28, height: 28))
            }
            
            // 踢除成员
            if (userInfo?.userId == pDetail.userId && partData.participateList.count >= 2) {
                finalLen += 1
                let pcBtn = UIButton()
                pcBtn.layer.cornerRadius = 8
                pcBtn.backgroundColor = UIColor.ls_color("#F9F9F9")
                pcBtn.addTarget(self, action: #selector(handleDelPersonTap(_:)), for: .touchUpInside)
                personContent.addSubview(pcBtn)
                
                let delIcon = UIImageView()
                delIcon.layer.cornerRadius = 22
                delIcon.clipsToBounds = true
                delIcon.image = UIImage(named: "icon_del_person")
                pcBtn.addSubview(delIcon)
                
                let v_left:CGFloat = CGFloat((finalLen-1)%h_count) * (v_width + h_margin)
                let v_top:CGFloat = CGFloat((finalLen-1)/h_count) * (v_margin + v_height)
                pcBtn.snp.makeConstraints { (make) in
                    make.left.equalTo(v_left)
                    make.top.equalTo(v_top)
                    make.width.equalTo(v_width)
                    make.height.equalTo(v_height)
                }
                
                delIcon.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                    make.size.equalTo(CGSize(width: 28, height: 28))
                }
            }
            
            let pc_height = CGFloat(((finalLen + h_count - 1)/h_count)) * (v_height + v_margin)
            personContent.snp.updateConstraints { make in
                make.height.equalTo(pc_height)
            }
        }
    }

    func loadNewData() {
        // 请求详情数据
        getPartyDetail()
        // 请求参与人数据
        getParticipateList()
        // 获取评论
        getComments(pageNum: 1, pageSize: commentData.pageSize, uniqueCode: uniCode, parentId: 0)
    }
    
    func loadMoreData() {
        // 获取评论
        getComments(pageNum: commentData.pageNum+1, pageSize: commentData.pageSize, uniqueCode: uniCode, parentId: 0)
    }
    
    @objc func clickQrCodeBtn(_ sender:UIButton) {
        QRPartyView.shared.showInWindow(partyDetail?.uniqueCode ?? "")
    }
    
    func updateComment(_ item:CommentItem) {
        if (item.id == 0) {
            if let indexPath = selectedIndexPath {
                if (indexPath.row == 0) {
                    commentData.comments[indexPath.section].childComments.insert(item, at: 0)
                    tempIndexPath = IndexPath(row: 1, section: indexPath.section)
                } else {
                    commentData.comments[indexPath.section].childComments.insert(item, at: indexPath.row-1)
                }
            } else {
                commentData.comments.insert(item, at: 0)
                tempIndexPath = IndexPath(row: 0, section: 0)
            }
        } else {
            var isExist = false
            for i in 0 ..< commentData.comments.count {
                let comment = commentData.comments[i]
                if (comment.id == 0) {
                    isExist = true
                    commentData.comments[i] = item
                } else {
                    for j in 0 ..< comment.childComments.count {
                        let subComment = comment.childComments[j]
                        if (subComment.id == 0) {
                            isExist = true
                            commentData.comments[i].childComments[j] = item
                            break
                        }
                    }
                }
                
                if (isExist) {
                    break
                }
            }
        }
        
        commentTableView.reloadData()
    }
    
    func handleCommentsData(parentId:Int64, data:CommentListModel) {
        
        if (parentId == 0) {
            if (data.pageNum == 1) {
                commentData = data
            } else {
                commentData.pageNum = data.pageNum
                commentData.comments.append(contentsOf: data.comments)
            }
            if (commentData.totalCount <= commentData.pageNum * commentData.pageSize) {
                commentTableView.mj_footer.endRefreshingWithNoMoreData()
            }
        } else {
            let len = commentData.comments.count
            
            for i in 0 ..< len {
                let item = commentData.comments[i]
                if (item.id == parentId) {
                    if (data.pageNum == 1) {
                        item.childComments = data.comments
                    } else {
                        item.childComments.append(contentsOf: data.comments)
                    }
                    break
                }
            }
        }
        
        footLabel.isHidden = commentData.pageTotal <= commentData.pageNum
        footerIcon.isHidden = commentData.pageTotal <= commentData.pageNum
        commentTableView.reloadData()
    }
    
    @objc func handleFooterTap() {
        LSLog("handleFooterTap pageTotal:\(commentData.pageTotal), pageNum:\(commentData.pageNum)")
        // 加载更多评论
        if (commentData.pageTotal > commentData.pageNum) {
            getComments(pageNum: commentData.pageNum + 1, pageSize: commentData.pageSize, uniqueCode: uniCode, parentId: 0)
        }
    }
    
    @objc func clickCommentBtn(_ sender:UIButton) {
        // 评论
        selectedIndexPath = nil
        chatKeyboard.showKeyBoard()
    }
    
    @objc func clickJoinBtn(_ sender:UIButton) {
        LSLog("clickJoinBtn joinState:\(partyDetail?.joinState ?? -1)")
        // 根据状态处理，加入、解散
        if isOwner {
            // 二次确认解散
            showDismissAlert()
        } else if (partyDetail?.joinState == 0 || partyDetail?.joinState == 2) {
            // 加入组局
            joinParty()
        } else if (partyDetail?.joinState == 1) {
            // 二次确认退出
            showLeaveAlert()
        }
    }
    
    func showDismissAlert() {
        // 二次确认是否要结束当前游戏
        let alertController = BaseAlertController(title: "确定要解散此桔吗？", message: nil)
                
        let cancelAction = BaseAlertAction(title: "取消", style: .default) { (action) in
            // 处理取消按钮点击后的操作
        }
        
        let okAction = BaseAlertAction(title: "确定", style: .destructive) { (action) in
            // 解散次桔
            self.dismissParty()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showLeaveAlert() {
        // 二次确认是否退出
        let alertController = BaseAlertController(title: "确定要退出此桔吗？", message: nil)
                
        let cancelAction = BaseAlertAction(title: "取消", style: .default) { (action) in
            // 处理取消按钮点击后的操作
        }
        
        let okAction = BaseAlertAction(title: "确定", style: .destructive) { (action) in
            // 退出桔
            self.leaveParty()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // 点击成员
    @objc func clickPcBtn(_ sender:UIButton) {
        let index:Int = sender.layer.value(forKey: ParticipateKey) as! Int
        if index >= 0, index < participateData?.participateList.count ?? 0 {
            let partiUser = participateData?.participateList[index]
            PageManager.shared.pushToUserPage(partiUser?.userId ?? "")
        }
    }
    
    // 邀请好友
    @objc func handleAddPersonTap(_ sender:UIButton) {
        let vc = FollowListController()
        vc.setData(true)
        vc.followSelectedBlock = { [weak self] followItems in
            LSLog("followSelectedBlock followItems:\(followItems)")
            var peopleIds:[String] = []
            for i in 0 ..< followItems.count {
                let fItem = followItems[i]
                peopleIds.append(fItem.userId)
            }
            // 邀请加入局
            self?.inviteJoinParty(peopleIds)
        }
        vc.hidesBottomBarWhenPushed = true
        PageManager.shared.currentNav()?.pushViewController(vc, animated: true)
    }
    
    // 移除成员
    @objc func handleDelPersonTap(_ sender:UIButton) {
        LSLog("handleDelPersonTap")
        if let uniCode = partyDetail?.uniqueCode {
            let vc = ParticipateListController()
            vc.setData(uniCode, mutiSelect: true)
            vc.selectedBlock = { [weak self] items in
                LSLog("selectedBlock items:\(items)")
                self?.kickOut(items)
            }
            vc.hidesBottomBarWhenPushed = true
            PageManager.shared.currentVC()?.present(vc, animated: true)
        }
    }
    
    // 查看游戏
    @objc func handleGameTap() {
        if let relationGame = partyDetail?.relationGame{
            var item = GameItem()
            item.id = relationGame.gameId
            item.name = relationGame.name
            item.cover = relationGame.cover
            item.personCountMin = relationGame.personCountMin
            item.personCountMax = relationGame.personCountMax
            item.introduction = relationGame.introduction
            item.interactPersonCount = relationGame.interactPersonCount
            PageManager.shared.pushToGameDetail(item)
        } else {
            
        }
    }
    
    // 查看位置
    @objc func handleLocationTap() {
        
        if let lat = partyDetail?.latitude, let lon = partyDetail?.longitude {
            PageManager.shared.pushToMapNavigationController(partyDetail?.landmark ?? "", address: partyDetail?.address ?? "", lat: lat, lon: lon)
        } else {
            LSHUD.showInfo("地址有误，无法定位")
        }
    }
    
    override func rightAction() {
        LSLog("PartyDetail rightAction")
        // 分享
        if let party = partyDetail, let cImage = coverImage {
            let title = "邀请你加入\(party.name)"
            let desc = timeLabel.text!
            let pageUrl = "\(UNIVERSAL_LINK)/detail?code=\(party.uniqueCode)"
            
            WXApiManager.shared.shareToWX(title, description: desc, pageUrl: pageUrl, image: cImage)
        }
    }
    
    func scrollToIndexPath(_ indexPath:IndexPath) {
        
        // 跳转到指定位置
        DispatchQueue.main.async { [self] in
            // 在这里执行reloadData完成后的操作
            commentTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// UITableView 代理
extension PartyDetailController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        LSLog("scrollViewWillBeginDragging")
        if commentTableView.frame.height < (kScreenH - kTabBarHeight) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .kChatTextKeyboardNeedHide, object: nil)
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return commentData.comments.count
    }
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentData.comments[section].childComments.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            let item = commentData.comments[indexPath.section]
            cell.configure(with: item)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubCommentCell", for: indexPath) as! SubCommentCell
            cell.loadMoreBlock = { [weak self] citem, pitem in
                LSLog("loadMoreBlock item:\(citem)")
                let pageSize = 10
                let pageNum = pitem.childComments.count/pageSize + 1
                self?.getComments(pageNum: Int64(pageNum), pageSize: Int64(pageSize), uniqueCode: self?.uniCode ?? "", parentId: citem.parentId)
            }
            let pitem = commentData.comments[indexPath.section]
            let item = pitem.childComments[indexPath.row-1]
            cell.configure(with: item, pitem: pitem)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        var placeHolder:String = "说点什么"
        if (indexPath.row == 0) {
            let item = commentData.comments[indexPath.section]
            placeHolder = "@\(item.from.nick)"
        } else {
            let pitem = commentData.comments[indexPath.section]
            let item = pitem.childComments[indexPath.row-1]
            placeHolder = "@\(item.from.nick)"
        }
        // 拉起评论输入框
        chatKeyboard.setPlaceHolder(placeHolder)
        chatKeyboard.showKeyBoard()
    }
}

// MARK: - ChatKeyboardViewDelegate
extension PartyDetailController: ChatKeyboardViewDelegate {
    
    func keyboard(_ keyboard: ChatKeyboardView, DidFinish content: String) {
        
        if (content.isEmpty) {
            return
        }
        
        sendComment(uniCode, content: content)
    }
    
    func keyboard(_ keyboard: ChatKeyboardView, DidBecome isBecome: Bool) {
        
    }
    
    func keyboard(_ keyboard: ChatKeyboardView, DidMoreMenu type: ChatMoreMenuType) {
        
    }
    
    func keyboard(_ keyboard: ChatKeyboardView, DidObserver offsetY: CGFloat) {
        restChatKeyboardSafeTop(offsetY)
    }
    
    private func restChatKeyboardSafeTop(_ offsetY: CGFloat) {
        LSLog("restChatKeyboardSafeTop offsetY:\(offsetY)")
        if (kScreenH - offsetY > kTabBarHeight) {
            commentTableView.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(offsetY - kScreenH)
            }
            
            view.layoutIfNeeded()
            if let indexPath = tempIndexPath {
                scrollToIndexPath(indexPath)
            } else if let indexPath = selectedIndexPath {
                scrollToIndexPath(indexPath)
            }
        } else {
            
            commentTableView.snp.remakeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(self.bottomView.snp.top)
            }
        }
    }
}


extension PartyDetailController {
    
    fileprivate func setupUI() {
        
        headerView.addSubview(topView)
        topView.addSubview(cover)
        topView.addSubview(creatorAvatar)
        topView.addSubview(creatorTipView)
        creatorTipView.addSubview(creatorTipLabel)
        topView.addSubview(qrCodeBtn)
        headerView.addSubview(detailView)
        detailView.addSubview(timeLabel)
        detailView.addSubview(feeLabel)
        detailView.addSubview(introductionView)
        introductionView.addSubview(introductionTitleLabel)
        introductionView.addSubview(introductionLabel)
        detailView.addSubview(gameView)
        gameView.addSubview(gameTitleLabel)
        gameView.addSubview(gameLabel)
        gameView.addSubview(gameArrow)
        detailView.addSubview(addressView)
        addressView.addSubview(addressTitleLabel)
        addressView.addSubview(addressMapView)
        addressMapView.addSubview(addressLocalIcon)
        addressMapView.addSubview(addressNameLabel)
        addressMapView.addSubview(addressDetailLabel)
        detailView.addSubview(personView)
        personView.addSubview(personTitleLabel)
        personView.addSubview(personContent)
//        footerView.addSubview(footLabel)
//        footerView.addSubview(footerIcon)
        view.addSubview(bottomView)
        bottomView.addSubview(commentBtn)
        bottomView.addSubview(joinBtn)
        view.addSubview(commentTableView)
        view.addSubview(chatKeyboard)
        
        
//        footLabel.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(12)
//            make.centerX.equalToSuperview()
//        }
//        
//        footerIcon.snp.makeConstraints { (make) in
//            make.centerY.equalTo(footLabel)
//            make.left.equalTo(footLabel.snp.right).offset(2)
//            make.size.equalTo(CGSize(width: 10, height: 10))
//        }
        
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(detailView).offset(10)
        }
        
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(topHeight)
        }

        cover.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        creatorAvatar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.bottom.equalToSuperview().offset(-26)
            make.size.equalTo(CGSize(width: creatorAvatarWidth, height: creatorAvatarWidth))
        }
        
        creatorTipView.snp.makeConstraints { (make) in
            make.centerX.equalTo(creatorAvatar)
            make.centerY.equalTo(creatorAvatar.snp.bottom)
            make.size.equalTo(CGSize(width: creatorAvatarWidth, height: 18))
        }
        
        creatorTipLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        qrCodeBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(creatorAvatar)
            make.right.equalToSuperview().offset(-leftMargin)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        
        detailView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(-8)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(personView)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(leftMargin)
        }
        
        feeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeLabel)
            make.right.equalToSuperview().offset(-leftMargin)
        }
        
        introductionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalTo(introductionLabel).offset(10)
        }
        
        introductionTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.top.equalToSuperview().offset(20)
        }
        
        introductionLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.top.equalTo(introductionTitleLabel.snp.bottom).offset(10)
        }
        
        gameView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(introductionView.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalTo(gameLabel).offset(10)
        }
        
        gameTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.top.equalToSuperview().offset(10)
        }
        
        gameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.top.equalTo(gameTitleLabel.snp.bottom).offset(10)
        }
        
        gameArrow.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftMargin)
            make.centerY.equalTo(gameLabel)
            make.size.equalTo(CGSize(width: 14, height: 14))
        }
        
        addressView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(gameView.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalTo(addressMapView).offset(10)
        }
        
        addressTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.top.equalToSuperview().offset(10)
        }

        addressMapView.snp.makeConstraints { (make) in
            make.top.equalTo(addressTitleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(66)
        }

        addressLocalIcon.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }

        addressNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(addressLocalIcon.snp.right).offset(12)
            make.top.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-16)
        }

        addressDetailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(addressNameLabel)
            make.top.equalTo(addressNameLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
        }
        
        personView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(addressView.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalTo(personContent).offset(10)
        }
        
        personTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.top.equalToSuperview().offset(10)
        }
        
        personContent.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.top.equalTo(personTitleLabel.snp.bottom).offset(14)
            make.height.equalTo(111)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kTabBarHeight)
        }
        
        commentBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(leftMargin)
            make.width.equalTo(112)
            make.height.equalTo(40)
        }
        
        joinBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(commentBtn)
            make.left.equalTo(commentBtn.snp.right).offset(10)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(40)
        }
        
        commentTableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
    
    fileprivate func resetNavigation() {
        
        navigationView.backgroundColor = UIColor.clear
        navigationView.backView.backgroundColor = UIColor.clear
        
        let leftImg = UIImage(named: "icon_back_white")
        let backImg = leftImg?.withRenderingMode(.alwaysOriginal)
        navigationView.leftButton.setImage(backImg, for: .normal)
        let rightImg = UIImage(named: "icon_share_detail")
        let shareImg = rightImg?.withRenderingMode(.alwaysOriginal)
        navigationView.rightButton.setImage(shareImg, for: .normal)
    }
}
