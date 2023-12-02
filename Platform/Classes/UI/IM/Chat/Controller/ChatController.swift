//
//  ChatController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import ImSDK_Plus_Swift
import ZLPhotoBrowser
import IQKeyboardManagerSwift

class ChatController: BaseController {
    
    // chatKeyBoard
    private let kToolBarLastH: CGFloat = 52
    
//    let CellHeight = 80.0
    let PageCount: UInt = 20
    var conversation: LIMConversation = LIMConversation()
    var dataList: [LIMMessage] = []
    var participateList: [SimpleUserInfo] = []
    var userPageData: UserPageModel = UserPageModel()
    var memberDic: [String: SimpleUserInfo] = [String: SimpleUserInfo]()
    var uniqueCode: String = ""
    var partyDetail: PartyDetailModel = PartyDetailModel()
    var isLoading: Bool = false
    var hasMore: Bool = true
    let myUserInfo: UserInfoModel = LoginManager.shared.getUserInfo() ?? UserInfoModel()
    var sceneId: Int64 = 0
    

    override func viewDidLoad() {
        title = ""
        view.backgroundColor = UIColor.ls_color("#F8F8F8")
        
        super.viewDidLoad()
        resetNavigation()
        setupUI()
        addObservers()
        
        // 拉取数据
        loadNewData()
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
    
    // 创建UITableView
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.backgroundColor = UIColor.ls_color("#F8F8F8")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
//        tableView.estimatedRowHeight = CellHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        // 注册UITableViewCell类
        tableView.register(DefaultMessageCell.self, forCellReuseIdentifier: "DefaultMessageCell")
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: "TextMessageCell")
        tableView.register(SysMessageCell.self, forCellReuseIdentifier: "SysMessageCell")
        tableView.register(GroupTipsMessageCell.self, forCellReuseIdentifier: "GroupTipsMessageCell")
        tableView.register(ImageMessageCell.self, forCellReuseIdentifier: "ImageMessageCell")
        tableView.register(GiftMessageCell.self, forCellReuseIdentifier: "GiftMessageCell")
        tableView.register(InviteMessageCell.self, forCellReuseIdentifier: "InviteMessageCell")
        tableView.register(RedPacketMessageCell.self, forCellReuseIdentifier: "RedPacketMessageCell")
        tableView.register(GameStoryMessageCell.self, forCellReuseIdentifier: "GameStoryMessageCell")
        tableView.register(GameCardMessageCell.self, forCellReuseIdentifier: "GameCardMessageCell")
        tableView.register(GameRedPacketMessageCell.self, forCellReuseIdentifier: "GameRedPacketMessageCell")
        tableView.register(GameEndMessageCell.self, forCellReuseIdentifier: "GameEndMessageCell")
        
        return tableView
    }()
    
    // 创建底部工具栏
    fileprivate lazy var bottomView: ChatBottomView = {
        let view = ChatBottomView()
        view.inputBtnBlock = {
            self.chatKeyboard.showKeyBoard()
        }
        view.imageBtnBlock = {
            self.handleImagePicker()
        }
        view.redPacketBtnBlock = {
//            let vc = SendRedPacketController()
//            vc.setData(self.uniqueCode, personCount: self.memberDic.count, userId: self.conversation.userID ?? "", taskId: 0)
//            vc.hidesBottomBarWhenPushed = true
//            PageManager.shared.currentNav()?.pushViewController(vc, animated: true)
            
            PageManager.shared.pushToSendRedPacketController(self.uniqueCode, personCount: self.memberDic.count, userId: self.conversation.userID ?? "", taskId: 0)
        }
        return view
    }()
    
    fileprivate lazy var chatKeyboard: ChatKeyboardView = {
        let keyBoard = ChatKeyboardView(frame: CGRect(x: 0, y: kScreenH, width: kScreenW, height: kToolBarLastH))
        keyBoard.needHiddenToolBar = true
        keyBoard.delegate = self
        return keyBoard
    }()
}

extension ChatController {
    
    func setData(conv: LIMConversation?) {
        // 清除未读数
        cleanUnread()
        if let conv = conv {
            conversation = conv
            if (conversation.type == .LIM_C2C) {
                navigationView.titleLabel.text = conversation.showName
                let uid = conversation.userID ?? ""
                bottomView.setUserId(uid)
            } else if (conversation.type == .LIM_GROUP) {
                uniqueCode = conversation.groupID ?? ""
                bottomView.setUniCode(uniqueCode)
                navigationView.titleLabel.text = conversation.showName
            }
        }
    }
    
    func cleanUnread() {
        
        V2TIMManager.shared.cleanConversationUnreadMessageCount(conversationID: conversation.conversationID, cleanTimestamp: 0, cleanSequence: 0) {
            // 清理未读数成功
            
        } fail: { code, desc in
            
        }
    }
    
    // 获取详情
    func getUserHomePage(_ peopleId:String,_ completion: @escaping () -> Void) {
        NetworkManager.shared.getUserPage (peopleId) { resp in
            if resp.status == .success {
                LSLog("getUserPage data:\(resp.data)")
                self.userPageData = resp.data
                self.handleUserPage(self.userPageData)
                completion()
            } else {
                LSLog("getUserPage fail")
            }
        }
    }
    
    func getParticipateList(_ completion: @escaping () -> Void) {
        if uniqueCode.isEmpty {
            completion()
            return
        }
        NetworkManager.shared.getParticipateList(uniqueCode) { resp in
            LSLog("getParticipateList data:\(resp.data)")
            if resp.status == .success {
                LSLog("getParticipateList succ")
                self.participateList = resp.data.participateList
                self.handleMemberList(self.participateList)
                completion()
            } else {
                LSLog("getParticipateList fail")
            }
        }
    }
    
    func getPartyDetail(_ completion: @escaping () -> Void) {
        if uniqueCode.isEmpty {
            completion()
            return
        }
        
        NetworkManager.shared.getPartyDetail (uniqueCode) { resp in
            if resp.status == .success {
                LSLog("getPartyDetail data:\(resp.data)")
                self.partyDetail = resp.data
                self.handlePartyDetail()
                completion()
            } else {
                LSLog("getPartyDetail fail")
            }
        }
    }
    
    func addObservers() {
        V2TIMManager.shared.addAdvancedMsgListener(listener: self)
    }

    func loadMsgs(_ refresh: Bool = false, _ completion: @escaping(([V2TIMMessage]) -> ())) {
        // 正在拉取数据
        if isLoading {
            return
        }
        
        // 不是刷新，且无更多数据
        if (!refresh && !hasMore) {
            return
        }
        
        isLoading = true
        let option:V2TIMMessageListGetOption  = V2TIMMessageListGetOption()
        option.getType = .V2TIM_GET_CLOUD_OLDER_MSG     // 拉取云端的更老的消息
        option.count = PageCount                        // 返回时间范围内所有的消息
        option.userID = conversation.userID
        option.groupID = conversation.groupID
        option.lastMsg = dataList.count > 0 ? dataList[0].originMessage : nil

        V2TIMManager.shared.getHistoryMessageList(option: option) { msgs in
            LSLog("getHistoryMessageList msgs:\(msgs)")
            if (msgs.count < self.PageCount) {
                self.hasMore = false;
            }
            self.isLoading = false
            self.handleData(msgs: msgs, refresh: refresh)
            completion(msgs)
        } fail: { code, desc in
            self.isLoading = false
            // 刷新界面
            self.tableView.reloadData()
        }
    }
    
    func loadNewData() {
        // 使用 DispatchGroup 来等待异步任务完成
        let dispatchGroup = DispatchGroup()
        
        // 将异步任务添加到 DispatchGroup 中
        dispatchGroup.enter()
        loadMsgs(true) { msgs in
            dispatchGroup.leave()
        }
        
        if (conversation.type == .LIM_C2C) {
            dispatchGroup.enter()
            let uid = conversation.userID ?? ""
            getUserHomePage(uid) {
                dispatchGroup.leave()
            }
        } else if (conversation.type == .LIM_GROUP) {

            dispatchGroup.enter()
            getPartyDetail {
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            getParticipateList {
                dispatchGroup.leave()
            }
        }
        
        // 在 DispatchGroup 中的所有任务完成后执行
        dispatchGroup.notify(queue: .main) {
            self.handleOtherData()
            self.refreshComplete()
        }
    }
    
    func loadMoreData() {
        loadMsgs(false) { msgs in
            self.handleOtherData()
            self.loadMoreComplete(msgs)
        }
    }
    
    func handleData(msgs:[V2TIMMessage], refresh:Bool) {
        if refresh {
            dataList = []
        }
        
        for i in 0 ..< msgs.count {
            let item = msgs[i]
            let limMsg:LIMMessage = LIMModel.TIMMsgToLIMMsg(item)
            dataList.insert(limMsg, at: 0)
        }
    }
    
    func refreshComplete() {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        scrollToBottom(false)
    }
    
    func loadMoreComplete(_ msgs:[V2TIMMessage]) {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        scrollToLast(msgs.count)
    }
    
    // 处理其他数据
    func handleOtherData() {
        if (dataList.count == 0 || memberDic.count == 0 || partyDetail.uniqueCode == nil) {
            return
        }
        
        // 判断是否是最后一条游戏消息
        var lastGameElemExist = false
        
        // 从dataList.count-1倒序到0，步长为1
        for i in stride(from: dataList.count-1, through: 0, by: -1) {
            let item = dataList[i]
            
            // 游戏消息
            if item.elemType == .LIMElemGameStatusSync {
                if lastGameElemExist {
                    item.gameElem?.status = 1
                } else {
                    // 如果是红包、卡牌任务、剧情故事（时间为0），置为未完成
                    if partyDetail.state != 2, partyDetail.state != 3 {
                        if (item.gameElem?.action.actionId == .LIMGameStatusCard || item.gameElem?.action.actionId == .LIMGameStatusRedPacket || (item.gameElem?.action.actionId == .LIMGameStatusStory && item.gameElem?.action.roundInfo.showSeconds == 0)) {
                            item.gameElem?.status = 0
                        } else {
                            item.gameElem?.status = 1
                        }
                        
                        // 最后一条如果是游戏结束消息，把sceneId置为0
                        if item.gameElem?.action.actionId == .LIMGameStatusEnd {
                            sceneId = 0
                        } else {
                            sceneId = item.gameElem?.sceneId ?? 0
                        }
                    } else {
                        item.gameElem?.status = 1
                        // 如果是解散或者过期状态，把sceneId置为0
                        sceneId = 0
                    }
                }
                lastGameElemExist = true
            }
            
            // 处理用户信息
            switch item.elemType {
                case .LIMElemGift:
                    LSLog("toAccount:\(item.giftElem?.toAccount ?? "")")
                    if let toAccount = item.giftElem?.toAccount, memberDic.count > 0 {
                        let toUserInfo:SimpleUserInfo = memberDic[toAccount] ?? SimpleUserInfo()
                        item.giftElem?.toUserName = toUserInfo.nick
                        LSLog("toUserName:\(item.giftElem?.toUserName ?? ""),nickName:\(toUserInfo.nick)")
                    }
                
                case .LIMElemInvite:
                    if let fromUserId = item.inviteElem?.userId, let toUserId = item.inviteElem?.toUserId, memberDic.count > 0
                    {
                        let fromUserInfo:SimpleUserInfo = memberDic[fromUserId] ?? SimpleUserInfo()
                        let toUserInfo:SimpleUserInfo = memberDic[toUserId] ?? SimpleUserInfo()
                        item.inviteElem?.userName = fromUserInfo.nick
                        item.inviteElem?.toUserName = toUserInfo.nick
                    }
                
                case .LIMElemRedPacket:
                    if let redPacketId = item.redPacketElem?.id {
                        let status = RedPacketManager.shared.getRedPacketStatusById(redPacketId)
                        item.redPacketElem?.status = status
                    }
                    
                case .LIMElemGameStatusSync:
                    
                    switch item.gameElem?.action.actionId {
                        
                        case .LIMGameStatusCard:
                            if let userIds = item.gameElem?.action.teamUserIds, userIds.count > 0, memberDic.count > 0
                            {
                                item.isSelf = item.gameElem?.action.teamUserIds.contains(myUserInfo.userId)
                                item.nickName = ""
                                for i in 0 ..< userIds.count {
                                    let uid = userIds[i]
                                    let userInfo:SimpleUserInfo = memberDic[uid] ?? SimpleUserInfo()
                                    if (i == 0) {
                                        item.faceURL = userInfo.portrait
                                    }
                                    
                                    if let oldName = item.nickName, oldName != "" {
                                        item.nickName = oldName + "、" + userInfo.nick
                                    } else {
                                        item.nickName = userInfo.nick
                                    }
                                }
                            }
                            
                        case .LIMGameStatusRedPacket:
                            if let userIds = item.gameElem?.action.teamUserIds, userIds.count > 0, memberDic.count > 0
                            {
                                item.nickName = ""
                                for i in 0 ..< userIds.count {
                                    let uid = userIds[i]
                                    let userInfo:SimpleUserInfo = memberDic[uid] ?? SimpleUserInfo()
                                    if (i == 0) {
                                        item.faceURL = userInfo.portrait
                                    }
                                    
                                    if let oldName = item.nickName, oldName != "" {
                                        item.nickName = oldName + "、" + userInfo.nick
                                    } else {
                                        item.nickName = userInfo.nick
                                    }
                                }
                            }
                            
                        
                        default:
                            break
                    }
                
                default:
                    break
            }
            
            dataList[i] = item
        }
    }
    
    func scrollToLast(_ newMsgCount:Int) {
        if tableView.contentSize.height > tableView.frame.height {
            // 恢复原位置
            let lastSection = tableView.numberOfSections - 1
            if lastSection >= 0, newMsgCount >= 0, newMsgCount < dataList.count {
                let indexPath = IndexPath(row: newMsgCount, section: lastSection)
                tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
    }
    
    func scrollToBottom(_ animated:Bool = true) {
        if tableView.contentSize.height > tableView.frame.height {
            let lastSection = tableView.numberOfSections - 1

            if lastSection >= 0 {
                let lastRow = tableView.numberOfRows(inSection: lastSection) - 1
                if lastRow >= 0 {
                    let indexPath = IndexPath(row: lastRow, section: lastSection)
                    tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
            }
        }
    }
    
    func handleMemberList(_ memberList:[SimpleUserInfo]) {
        memberDic = [String: SimpleUserInfo]()
        for i in 0 ..< memberList.count {
            let item = memberList[i]
            memberDic[item.userId] = item
        }
    }
    
    func handleUserPage(_ userPage:UserPageModel) {
        memberDic = [String: SimpleUserInfo]()
        let obj: SimpleUserInfo = SimpleUserInfo()
        obj.userId = userPage.user.userId
        obj.nick = userPage.user.nick
        obj.portrait = userPage.user.portrait
        obj.selfSignature = userPage.user.intro
        memberDic[obj.userId] = obj
        
        // 设置导航栏图标
        navigationView.avatar.kf.setImage(with: URL(string: obj.portrait), placeholder: PlaceHolderAvatar)
    }
    
    func handlePartyDetail() {
        self.bottomView.setPartyDetail(partyDetail)
        // 设置导航栏图标、名称
        navigationView.avatar.kf.setImage(with: URL(string: partyDetail.cover), placeholder: PlaceHolderAvatar)
        let personCount = partyDetail.maleCnt + partyDetail.femaleCnt - partyDetail.maleRemainCount - partyDetail.femaleRemainCount
        navigationView.titleLabel.text = "\(conversation.showName ?? "")(\(personCount))"
    }
    
    func addNewMessage(_ msg:V2TIMMessage) {
        let limMsg:LIMMessage = LIMModel.TIMMsgToLIMMsg(msg)
        dataList.append(limMsg)
        
        // 处理其他数据
        handleOtherData()
        
        // 刷新界面
        tableView.reloadData()
        
        // 跳转到最底部
        scrollToBottom()
        
        // 判断是否是自己抽到了卡牌
        if limMsg.elemType == .LIMElemGameStatusSync {
            if limMsg.isSelf ?? false, limMsg.gameElem?.action.actionId == .LIMGameStatusCard {
                // 先关闭其他 TaskView
                StoryTaskView.shared.removeTaskView()
                // 打开需要的 TaskView
                CardTaskView.shared.cardTaskBlock = { msg in
                    LSLog("cardTaskBlock")
                    // 发红包逃避任务
                    PageManager.shared.pushToSendRedPacketController(self.uniqueCode, personCount: self.memberDic.count, userId: self.conversation.userID ?? "", taskId: msg.gameElem?.taskId ?? 0)
                    
                }
                CardTaskView.shared.showInWindow(limMsg)
            }
            
            if limMsg.gameElem?.action.actionId == .LIMGameStatusStory {
                // 先关闭其他 TaskView
                CardTaskView.shared.removeTaskView()
                // 打开需要的 TaskView
                StoryTaskView.shared.storyTaskBlock = { msg in
                    LSLog("storyTaskBlock")
                    // 下一关
                    NetworkManager.shared.doneTask(limMsg.gameElem?.taskId ?? 0) { resp in
                        if resp.status == .success {
                            LSLog("doneTask succ")
                            limMsg.gameElem?.status = 1
                        } else {
                            LSLog("doneTask fail")
                            LSHUD.showError(resp.msg)
                        }
                    }
                }
                StoryTaskView.shared.showInWindow(limMsg)
            }
        }
    }
    
    func updateMessage(_ msg:V2TIMMessage) {
        var isExist = false
        for i in 0 ..< dataList.count {
            let item = dataList[i]
            if item.msgID == msg.msgID {
                dataList[i] = LIMModel.TIMMsgToLIMMsg(msg)
                isExist = true
                break
            }
        }
        
        if isExist {
            // 刷新界面
            tableView.reloadData()
        } else {
            addNewMessage(msg)
        }
    }
    
    func handleImagePicker() {
        if let currVC = PageManager.shared.currentVC() {
            let pickerConfig = ZLPhotoConfiguration.default()
            pickerConfig.maxSelectCount = 1 // 设置最大选择数量为 1
            let ps = ZLPhotoPreviewSheet()
            ps.selectImageBlock = { [weak self] results, isOriginal in
                // your code
                if results.count > 0 {
                    let zlResultModel:ZLResultModel = results[0]
                    
                    if let data:Data = zlResultModel.image.jpegData(compressionQuality: 0.75) {
                        let imagePathUrl = LUIKit_Image_Path.appendingPathComponent(String.genImageName("") ?? "")
                        FileManager.default.createFile(atPath: imagePathUrl.path, contents: data)
                        if let msg:V2TIMMessage = V2TIMManager.shared.createImageMessage(imagePath: imagePathUrl.path) {
                            // 发送消息
                            self?.sendMessage(msg)
                        }
                    } else {
                        // 图片保存失败
                        LSLog("图片获取失败")
                    }
                }
            }
            
            ps.showPreview(sender: currVC)
        }
    }
    
    func sendMessage(_ msg: V2TIMMessage) {
        
        _ = V2TIMManager.shared.sendMessage(message: msg, receiver: conversation.userID ?? "", groupID: conversation.groupID ?? "", priority: .V2TIM_PRIORITY_DEFAULT, onlineUserOnly: false, offlinePushInfo: nil, progress: { progress in
            LSLog("sendMessage progress:\(progress)")
        }, succ: {
            LSLog("sendMessage succ")
            LSLog("msg status :\(msg.status)")
            self.updateMessage(msg)
        }, fail: { code, desc in
            LSLog("sendMessage fail code:\(code), desc:\(desc)")
            LSLog("msg status :\(msg.status)")
            // 发送失败 展示感叹号
            self.updateMessage(msg)
        })
        
        // 插入本地消息
        self.updateMessage(msg)
    }
    
    // 更多
    override func rightAction() {
        /**
         * 私聊展示举报、拉黑
         * 群聊展示举报、结束当前游戏、解散此桔
         */
        if self.uniqueCode.isEmpty {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            // 添加带有图标的动作
            let action1 = UIAlertAction(title: "举报", style: .default) { (action) in
                self.handleReport()
            }
            action1.setValue(UIImage(named: "icon_report"), forKey: "image")
            action1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let action2Title = self.userPageData.relation.black ? "取消拉黑" : "拉黑"
            let action2 = UIAlertAction(title: action2Title, style: .default) { (action) in
                self.handleBlackList()
            }
            action2.setValue(UIImage(named: "icon_blacklist"), forKey: "image")
            action2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)

            // 添加动作到操作表
            alertController.addAction(action1)
            alertController.addAction(action2)
            alertController.addAction(cancelAction)

            // 显示操作表
            present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            // 添加带有图标的动作
            let action1 = UIAlertAction(title: "举报", style: .default) { (action) in
                self.handleReport()
            }
            action1.setValue(UIImage(named: "icon_report"), forKey: "image")
            action1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let action2 = UIAlertAction(title: "结束当前游戏", style: .default) { (action) in
                self.showEndAlert()
            }
            action2.setValue(UIImage(named: "icon_endgame"), forKey: "image")
            action2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            // 添加带有图标的动作
            let action3 = UIAlertAction(title: "解散此桔", style: .default) { (action) in
                self.showDismissAlert()
            }
            action3.setValue(UIImage(named: "icon_dismissgame"), forKey: "image")
            action3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)

            // 添加动作到操作表
            alertController.addAction(action1)
            
            // 当前桔非解散、非过期、当前游戏在游戏中、主持人是自己，才展示
            if partyDetail.userId == myUserInfo.userId, partyDetail.state != 2, partyDetail.state != 3, sceneId > 0 {
                alertController.addAction(action2)
            }
            // 当前桔非解散、非过期、主持人是自己，才展示解散提示
            if partyDetail.userId == myUserInfo.userId, partyDetail.state != 2, partyDetail.state != 3 {
                alertController.addAction(action3)
            }
            
            alertController.addAction(cancelAction)

            // 显示操作表
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func handleReport() {
        // 选择举报理由
        let vc = ReportReasonListController()
        vc.reasonConfirmBlock = { [self] reasonItem in
            self.report(reasonItem)
        }
        vc.hidesBottomBarWhenPushed = true
        PageManager.shared.currentNav()?.pushViewController(vc, animated: true)
    }
    
    func handleBlackList() {
        // 取消拉黑、拉黑
        LSHUD.showLoading()
        if self.userPageData.relation.black {
            NetworkManager.shared.removeBlackList(self.userPageData.user.userId) { resp in
                LSHUD.hide()
                if resp.status == .success {
                    LSLog("removeBlackList succ")
                    self.userPageData.relation.black = false
                    LSHUD.showInfo("操作成功")
                } else {
                    LSLog("removeBlackList fail")
                    LSHUD.showInfo("操作失败")
                }
            }
        } else {
            NetworkManager.shared.addBlackList(self.userPageData.user.userId) { resp in
                LSHUD.hide()
                if resp.status == .success {
                    LSLog("addBlackList succ")
                    self.userPageData.relation.black = true
                    LSHUD.showInfo("操作成功")
                } else {
                    LSLog("addBlackList fail")
                    LSHUD.showInfo("操作失败")
                }
            }
        }
    }
    
    func report(_ resonItem:ReportReasonItem) {
        // objType 1用户，2局
        let objType:Int64 = 2
        let objId:String = uniqueCode
        
        NetworkManager.shared.report(objType, objId: objId, reasonId: resonItem.reasonId) { resp in
            if resp.status == .success {
                LSLog("report succ")
                LSHUD.showInfo("操作成功")
            } else {
                LSLog("report fail")
                LSHUD.showInfo("操作失败")
            }
        }
    }
    
    func showEndAlert() {
        // 二次确认是否要结束当前游戏
        let alertController = UIAlertController(title: "", message: "确定要结束当前游戏吗？", preferredStyle: .alert)
                
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
            self.endGame()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (action) in
            // 处理取消按钮点击后的操作
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func endGame() {
        LSHUD.showLoading()
        // 结束当前游戏
        NetworkManager.shared.endGame(self.uniqueCode, sceneId: self.sceneId) { resp in
            LSHUD.hide()
            if resp.status == .success {
                LSLog("endGame succ")
                self.sceneId = 0
                LSHUD.showInfo("操作成功")
            } else {
                LSLog("endGame fail")
                LSHUD.showInfo("操作失败")
            }
        }
    }
    
    func showDismissAlert() {
        // 二次确认是否要解散
        let alertController = UIAlertController(title: "", message: "确定要解散此桔吗？", preferredStyle: .alert)
                
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
            self.dismissParty()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (action) in
            // 处理取消按钮点击后的操作
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func dismissParty() {
        LSHUD.showLoading()
        NetworkManager.shared.dismissParty(self.uniqueCode) { resp in
            LSHUD.hide()
            if resp.status == .success {
                LSLog("dismissParty succ")
                self.partyDetail.state = 2
                // 发送局状态变更通知
                LSNotification.postPartyStatusChange()
                // 返回
                self.pop()
            } else {
                LSLog("dismissParty fail")
                LSHUD.showInfo(resp.msg)
            }
        }
    }
}

// MARK: - V2TIMAdvancedMsgListener
extension ChatController: V2TIMAdvancedMsgListener {
    
    func onRecvNewMessage(msg: ImSDK_Plus_Swift.V2TIMMessage) {
        LSLog("onRecvNewMessage")
        updateMessage(msg)
        // 清除未读数
        cleanUnread()
    }
    
    func onRecvMessageReadReceipts(receiptList: Array<ImSDK_Plus_Swift.V2TIMMessageReceipt>) {
        LSLog("onRecvMessageReadReceipts")
    }
    
    func onRecvC2CReadReceipt(receiptList: Array<ImSDK_Plus_Swift.V2TIMMessageReceipt>) {
        LSLog("onRecvC2CReadReceipt")
    }
    
    func onRecvMessageRevoked(msgID: String, operateUser: ImSDK_Plus_Swift.V2TIMUserInfo, reason: String?) {
        LSLog("onRecvMessageRevoked")
    }
    
    func onRecvMessageModified(msg: ImSDK_Plus_Swift.V2TIMMessage) {
        LSLog("onRecvMessageModified")
    }
    
    func onRecvMessageExtensionsChanged(msgID: String, extensions: Array<ImSDK_Plus_Swift.V2TIMMessageExtension>) {
        LSLog("onRecvMessageExtensionsChanged")
    }
    
    func onRecvMessageExtensionsDeleted(msgID: String, extensionKeys: Array<String>) {
        LSLog("onRecvMessageExtensionsDeleted")
    }
    
    func onRecvMessageReactionsChanged(changeList: Array<ImSDK_Plus_Swift.V2TIMMessageReactionChangeInfo>) {
        LSLog("onRecvMessageReactionsChanged")
    }
    
    func onRecvMessageRevoked(msgID: String) {
        LSLog("onRecvMessageRevoked")
    }
}

// MARK: - ChatDelegate
extension ChatController: ChatDelegate {
    
    func reSend(_ limMessage: LIMMessage) {
        LSLog("ChatDelegate reSend")
        if let msg = limMessage.originMessage {
            sendMessage(msg)
        }
    }
}

// MARK: - ChatKeyboardViewDelegate
extension ChatController: ChatKeyboardViewDelegate {
    
    func keyboard(_ keyboard: ChatKeyboardView, DidFinish content: String) {
        
        if (content.isEmpty) {
            return
        }
        
        if let msg:V2TIMMessage = V2TIMManager.shared.createTextMessage(text: content) {
            sendMessage(msg)
        }
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
            self.tableView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(kNavBarHeight)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview()
                make.bottom.equalToSuperview().offset(offsetY - kScreenH)
            }
            
            view.layoutIfNeeded()
            scrollToBottom()
        } else {
            self.tableView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(kNavBarHeight)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview()
                make.bottom.equalTo(self.bottomView.snp.top)
            }
            
            view.layoutIfNeeded()
            scrollToBottom()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate
extension ChatController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY <= 0 {
//            loadMsgs(false)
            loadMoreData()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        LSLog("scrollViewWillBeginDragging")
        if tableView.frame.height < (kScreenH - kTabBarHeight - kNavBarHeight) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .kChatTextKeyboardNeedHide, object: nil)
            }
        }
    }
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataList[indexPath.row]
        var cell:UITableViewCell
        LSLog("cellForRowAt LIMElemText:\(item.elemType)")
        switch item.elemType {
            
            case .LIMElemText:
                let tempCell = tableView.dequeueReusableCell(withIdentifier: "TextMessageCell", for: indexPath) as! TextMessageCell
                tempCell.configure(item, party: partyDetail)
                tempCell.delegate = self
                cell = tempCell
                
            case .LIMElemSystemMsg:
                let tempCell = tableView.dequeueReusableCell(withIdentifier: "SysMessageCell", for: indexPath) as! SysMessageCell
                tempCell.configure(item)
                cell = tempCell
                
            case .LIMElemGroupTips:
                let tempCell = tableView.dequeueReusableCell(withIdentifier: "GroupTipsMessageCell", for: indexPath) as! GroupTipsMessageCell
                tempCell.configure(item)
                cell = tempCell
                
            case .LIMElemImage:
                let tempCell = tableView.dequeueReusableCell(withIdentifier: "ImageMessageCell", for: indexPath) as! ImageMessageCell
                tempCell.configure(item, party: partyDetail)
                tempCell.delegate = self
                cell = tempCell
                
            case .LIMElemGift:
                let tempCell = tableView.dequeueReusableCell(withIdentifier: "GiftMessageCell", for: indexPath) as! GiftMessageCell
                tempCell.configure(item, party: partyDetail)
                cell = tempCell
                
            case .LIMElemInvite:
                let tempCell = tableView.dequeueReusableCell(withIdentifier: "InviteMessageCell", for: indexPath) as! InviteMessageCell
                tempCell.configure(item, party: partyDetail)
                cell = tempCell
                
            case .LIMElemRedPacket:
                let tempCell = tableView.dequeueReusableCell(withIdentifier: "RedPacketMessageCell", for: indexPath) as! RedPacketMessageCell
                tempCell.configure(item, party: partyDetail)
                tempCell.fetchBlock = {
                    LSLog("fetchBlock")
                    // 状态为1，是已经处理过的红包，直接跳转进入详情
                    if item.redPacketElem?.status == 1 {
                        // 打开红包详情
                        PageManager.shared.pushToRedPacketDetailController(item)
                    } else {
                        NetworkManager.shared.fetchRedPacket(item.redPacketElem?.id ?? 0) { resp in
                            if resp.status == .success {
                                LSLog("fetchRedPacket succ")
                                item.redPacketElem?.status = 1
                                tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                                if let redPacketId = item.redPacketElem?.id {
                                    RedPacketManager.shared.saveRedPacketStatusById(redPacketId)
                                }
                                // 打开红包详情
                                PageManager.shared.pushToRedPacketDetailController(item)
                            } else {
                                // 红包已抢完，红包已领取，红包已过期，其他未知错误，都算已读
                                LSLog("fetchRedPacket fail")
                                LSHUD.showError(resp.msg)
                                // 处理红包已处理的状态
                                item.redPacketElem?.status = 1
                                tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                                if let redPacketId = item.redPacketElem?.id {
                                    RedPacketManager.shared.saveRedPacketStatusById(redPacketId)
                                }
                            }
                        }
                    }
                }
                cell = tempCell
            
            case .LIMElemGameStatusSync:
                
                switch item.gameElem?.action.actionId {
                    
                    case .LIMGameStatusStory:
                        let tempCell = tableView.dequeueReusableCell(withIdentifier: "GameStoryMessageCell", for: indexPath) as! GameStoryMessageCell
                        tempCell.configure(item)
                        // 主持人确认完成任务
                        tempCell.gameStoryConfirmBlock = {
                            LSLog("gameStoryConfirmBlock")
                            NetworkManager.shared.doneTask(item.gameElem?.taskId ?? 0) { resp in
                                if resp.status == .success {
                                    LSLog("doneTask succ")
                                        item.gameElem?.status = 1
    //                                    tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                                } else {
                                    LSLog("doneTask fail")
                                    LSHUD.showError(resp.msg)
                                }
                            }
                        }
                        cell = tempCell
                    
                    case .LIMGameStatusCard:
                        let tempCell = tableView.dequeueReusableCell(withIdentifier: "GameCardMessageCell", for: indexPath) as! GameCardMessageCell
                        tempCell.configure(item, party: partyDetail)
                        tempCell.gameCardBlock = {
                            CardTaskView.shared.cardTaskBlock = { msg in
                                LSLog("cardTaskBlock")
                                // 发红包逃避任务
                                PageManager.shared.pushToSendRedPacketController(self.uniqueCode, personCount: self.memberDic.count, userId: self.conversation.userID ?? "", taskId: msg.gameElem?.taskId ?? 0)
                                
                            }
                            CardTaskView.shared.showInWindow(item)
                        }
                        // 主持人确认完成任务
                        tempCell.gameCardConfirmBlock = {
                            LSLog("gameCardConfirmBlock")
                            NetworkManager.shared.doneTask(item.gameElem?.taskId ?? 0) { resp in
                                if resp.status == .success {
                                    LSLog("doneTask succ")
                                    item.gameElem?.status = 1
//                                    tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                                } else {
                                    LSLog("doneTask fail")
                                    LSHUD.showError(resp.msg)
                                }
                            }
                        }
                        cell = tempCell
                    
                    case .LIMGameStatusRedPacket:
                        let tempCell = tableView.dequeueReusableCell(withIdentifier: "GameRedPacketMessageCell", for: indexPath) as! GameRedPacketMessageCell
                        tempCell.configure(item)
                        // 发红包
                        tempCell.actionBlock = {
                            LSLog("actionBlock")
                            if let taskId = item.gameElem?.taskId {
                                PageManager.shared.pushToSendRedPacketController(self.uniqueCode, personCount: self.memberDic.count, userId: self.conversation.userID ?? "", taskId: taskId)
                            }
                        }
                        cell = tempCell
                    
                    case .LIMGameStatusEnd:
                        let tempCell = tableView.dequeueReusableCell(withIdentifier: "GameEndMessageCell", for: indexPath) as! GameEndMessageCell
                        cell = tempCell
                    
                    
                    default:
                        let tempCell = tableView.dequeueReusableCell(withIdentifier: "DefaultMessageCell", for: indexPath) as! DefaultMessageCell
                        tempCell.configure(item)
                        cell = tempCell
                }
                
                
            default:
                let tempCell = tableView.dequeueReusableCell(withIdentifier: "DefaultMessageCell", for: indexPath) as! DefaultMessageCell
                tempCell.configure(item)
                cell = tempCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选中cell
        let item = dataList[indexPath.row]
        // 目前仅处理story
        if item.elemType == .LIMElemGameStatusSync, item.gameElem?.action.actionId == .LIMGameStatusStory {
            // 先关闭其他 TaskView
            CardTaskView.shared.removeTaskView()
            // 打开需要的 TaskView
            StoryTaskView.shared.storyTaskBlock = { msg in
                LSLog("storyTaskBlock")
                // 下一关
                NetworkManager.shared.doneTask(item.gameElem?.taskId ?? 0) { resp in
                    if resp.status == .success {
                        LSLog("doneTask succ")
                        item.gameElem?.status = 1
                    } else {
                        LSLog("doneTask fail")
                        LSHUD.showError(resp.msg)
                    }
                }
            }
            StoryTaskView.shared.showInWindow(item)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}


extension ChatController {
    
    fileprivate func setupUI(){
        
        view.addSubview(tableView)
        view.addSubview(bottomView)
        view.addSubview(chatKeyboard)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kTabBarHeight)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.height.equalTo(kTabBarHeight)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    fileprivate func resetNavigation() {
        
        navigationView.showAvatar()
        let rightImg = UIImage(named: "icon_more_action")
        let shareImg = rightImg?.withRenderingMode(.alwaysOriginal)
        navigationView.rightButton.setImage(shareImg, for: .normal)
    }
}
