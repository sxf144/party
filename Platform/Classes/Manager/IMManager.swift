//
//  IMManager.swift
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import ImSDK_Plus_Swift

public protocol IMConversationDelegate: AnyObject {
    func updateConversationComplete(_ data:[LIMConversation])
}

class IMManager: NSObject {
    
    static let shared = IMManager()
    // 初始化 config 对象
    let config: V2TIMSDKConfig = V2TIMSDKConfig()
    let sdkAppID: Int32 = 1400826865
    let businessID: Int = 40576
    var deviceToken: Data?
    var conversationList: [LIMConversation] = []
    weak var conversationDelegate: IMConversationDelegate?
    
    private override init() {
        
        super.init()
        
        IMManager.createCachePath()
        // 指定 log 输出级别。
        config.logLevel = .V2TIM_LOG_INFO
        // 添加监听
        self.addObservers()
        // 初始化 IM SDK，调用这个接口后，可以立即调用登录接口
        _ = initIMSDK()
    }
    
    func initIMSDK() -> Bool {
        return V2TIMManager.shared.initSDK(sdkAppID: sdkAppID, config: config)
    }
    
    func uninitIMSDK() {
        V2TIMManager.shared.unInitSDK()
    }
    
    func loginIM() {
        if let userInfo = LoginManager.shared.getUserInfo() {
            V2TIMManager.shared.login(userID: userInfo.userId, userSig: userInfo.userSig) {
                LSLog("loginIM succ")
                self.uploadDeviceTokenToIM()
            } fail: { code, desc in
                // 如果返回以下错误码，表示使用 UserSig 已过期，请您使用新签发的 UserSig 进行再次登录。
                // 1. ERR_USER_SIG_EXPIRED（6206）
                // 2. ERR_SVR_ACCOUNT_USERSIG_EXPIRED（70001）
                // 注意：其他的错误码，请不要在这里调用登录接口，避免 IM SDK 登录进入死循环。

                LSLog("loginIM fail code:\(code), desc:\(desc)")
                if (code == 6206 || code == 70001) {
                    // UserSig已过期，获取新的UserSig并重新登录
//                    self.loginIM()
                    
                }
            }
        }
    }
    
    func setDeviceToken(_ deviceToken:Data) {
        self.deviceToken = deviceToken
    }
    
    func uploadDeviceTokenToIM() {
        if let deviceToken = deviceToken {
            let apnsConfig:V2TIMAPNSConfig = V2TIMAPNSConfig()
            apnsConfig.token = deviceToken
            apnsConfig.businessID = businessID
            V2TIMManager.shared.setAPNS(config: apnsConfig) {
                LSLog("setAPNS succ")
            } fail: { code, desc in
                LSLog("setAPNS fail code:\(code), desc:\(desc)")
            }
        }
    }
    
    func addObservers() {
        addIMSDKObservers()
        addConversationObservers()
    }
}

// MARK: - 会话相关
extension IMManager: V2TIMConversationListener, V2TIMGroupListener {
    
    func addConversationObservers() {
        V2TIMManager.shared.addConversationListener(listener: self)
        V2TIMManager.shared.addGroupListener(listener: self)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePartyStatusChange(_:)), name: NotificationName.partyStatusChange, object: nil)
    }
    
    @objc func handlePartyStatusChange(_ notification: Notification) {
        LSLog("---- handlePartyStatusChange ----")
        // 切换到主线程执行UI操作
        if let party = notification.object as? PartyDetailModel {
            if party.state == 2 || party.state == 3 {
                deleteConversation(party.uniqueCode)
            }
        }
    }
    
    func loadConversationList(_ completion: @escaping () -> Void) {
        // 在这里执行下拉刷新的操作
        V2TIMManager.shared.getConversationList(nextSeq: 0, count: INT_MAX) { list, nextSeq, isFinished in
            // 获取成功，list 为会话列表
            self.updateConversation(convList: list)
            completion()
        } fail: { code, desc in
            completion()
            self.conversationList = []
        }
    }
    
    func filterDataList() {
        // 过滤掉管理员会话ID
        conversationList = conversationList.filter { object in
            return object.conversationID != AdminConvId
        }
    }
    
    func sortDataList() {
        
//        dataList.sort { (item1, item2) -> Bool in
//            if let firstSortKey = item1.originConversation?.orderKey, let secondSortKey = item2.originConversation?.orderKey {
//                return firstSortKey < secondSortKey
//            }
//            return false // 如果无法解析sortKey，则假定它们相等
//        }
        
        // 目前按照时间排序
        conversationList.sort { (item1, item2) -> Bool in
            if let firstTime = item1.lastMessage.timestamp, let secondTime = item2.lastMessage.timestamp {
                return firstTime > secondTime
            }
            return false // 如果无法解析timestamp，则假定它们相等
        }
    }
    
    func updateConversation(convList:[V2TIMConversation]){
        
        // 更新 UI 会话列表，如果 UI 会话列表有新增的会话，就替换，如果没有，就新增
        for i in 0 ..< convList.count {
            let conv:V2TIMConversation = convList[i];
            LSLog("convId:\(conv.conversationID)")
            var isExit = false;
            for j in 0 ..< conversationList.count {
                let localConv:LIMConversation = conversationList[j]
                if (localConv.conversationID == conv.conversationID) {
                    // 转换对象
                    conversationList[j] = LIMModel.TIMConvToLIMConv(conv)
                    isExit = true
                    break;
                }
            }
            if (!isExit) {
                // 转换对象
                let limConv:LIMConversation = LIMModel.TIMConvToLIMConv(conv)
                conversationList.append(limConv)
            }
        }
        
        // UI 会话列表根据 会话id，过滤管理员信息，用来push专用，不展示
        filterDataList()
        
        // UI 会话列表根据 orderKey 重新排序，目前没使用到
        sortDataList()
        
        // 计算且展示未读消息数
        calculateUnreadMessageCount()
        
        // 回调函数
        if let convDelegate = conversationDelegate {
            convDelegate.updateConversationComplete(conversationList)
        }
    }
    
    func deleteConversation(_ uniCode:String) {
        for i in 0 ..< conversationList.count {
            let item = conversationList[i]
            if item.groupID == uniCode {
                // 删除此数据
                conversationList.remove(at: i)
                break
            }
        }
        
        // 回调函数
        if let convDelegate = conversationDelegate {
            convDelegate.updateConversationComplete(conversationList)
        }
    }
    
    func calculateUnreadMessageCount() {
        var unreadMessageCount = 0
        for item in conversationList {
            unreadMessageCount += item.unreadCount
        }
        
        var unreadStr = "\(unreadMessageCount)"
        if unreadMessageCount > 99 {
            unreadMessageCount = 99
            unreadStr = "99+"
        }
        
        TabBarController.shared.addBadge(index: 3, value: unreadStr)
    }
    
    func onNewConversation(conversationList: Array<V2TIMConversation>) {
        LSLog("onNewConversation")
        updateConversation(convList: conversationList)
    }
    
    func onConversationChanged(conversationList: Array<V2TIMConversation>) {
        LSLog("onConversationChanged")
        updateConversation(convList: conversationList)
    }
    
    func onGroupInfoChanged(groupID: String, changeInfoList: Array<V2TIMGroupChangeInfo>) {
        LSLog("onGroupInfoChanged")
        if (groupID.isEmpty) {
            return;
        }
        let conversationID:String = "group_\(groupID)"
        var tempItem:LIMConversation? = nil;
        for item in conversationList {
            if (item.conversationID == conversationID) {
                tempItem = item;
                break;
            }
        }
        
        if (tempItem == nil) {
            return;
        }
        
        V2TIMManager.shared.getConversation(conversationID: conversationID) { conv in
            self.updateConversation(convList: [conv])
        } fail: { code, desc in
            
        }
    }
}

extension IMManager {
    
    static func createCachePath() {
        
        let fileManager:FileManager = FileManager.default
        
        if(!fileManager.fileExists(atPath: LUIKit_DB_Path.path)){
            do {
                try fileManager.createDirectory(at: LUIKit_DB_Path, withIntermediateDirectories: true)
            } catch {
                print("无法创建子目录: \(error)")
            }
        }
        if(!fileManager.fileExists(atPath: LUIKit_Image_Path.path)){
            do {
                try fileManager.createDirectory(at: LUIKit_Image_Path, withIntermediateDirectories: true)
            } catch {
                print("无法创建子目录: \(error)")
            }
        }
        if(!fileManager.fileExists(atPath: LUIKit_Video_Path.path)){
            do {
                try fileManager.createDirectory(at: LUIKit_Video_Path, withIntermediateDirectories: true)
            } catch {
                print("无法创建子目录: \(error)")
            }
        }
        if(!fileManager.fileExists(atPath: LUIKit_Voice_Path.path)){
            do {
                try fileManager.createDirectory(at: LUIKit_Voice_Path, withIntermediateDirectories: true)
            } catch {
                print("无法创建子目录: \(error)")
            }
        }
        if(!fileManager.fileExists(atPath: LUIKit_File_Path.path)){
            do {
                try fileManager.createDirectory(at: LUIKit_File_Path, withIntermediateDirectories: true)
            } catch {
                print("无法创建子目录: \(error)")
            }
        }
    }
}

extension IMManager: V2TIMSDKListener {
    
    func addIMSDKObservers() {
        // 添加 V2TIMSDKListener 的事件监听器，self 是 id<V2TIMSDKListener> 的实现类
        V2TIMManager.shared.addIMSDKListener(listener: self)
    }
    
    func onConnecting() {
        LSLog("onConnecting")
    }
    
    func onConnectSuccess() {
        LSLog("onConnectSuccess")
    }
    
    func onConnectFailed(code: Int32, err: String) {
        LSLog("onConnectFailed code:\(code), err:\(err)")
    }
    
    func onKickedOffline() {
        LSLog("onKickedOffline")
    }
    
    func onUserSigExpired() {
        LSLog("onUserSigExpired")
    }
    
    func onSelfInfoUpdated(info: ImSDK_Plus_Swift.V2TIMUserFullInfo) {
        LSLog("onSelfInfoUpdated")
    }
    
    func onUserStatusChanged(userStatusList: Array<ImSDK_Plus_Swift.V2TIMUserStatus>) {
        LSLog("onUserStatusChanged")
    }
    
    func onUserInfoChanged(userInfoList: Array<ImSDK_Plus_Swift.V2TIMUserFullInfo>) {
        LSLog("onUserInfoChanged")
    }
    
    func onAllReceiveMessageOptChanged(receiveMessageOptInfo: ImSDK_Plus_Swift.V2TIMReceiveMessageOptInfo) {
        LSLog("onAllReceiveMessageOptChanged")
    }
    
    func onExperimentalNotify(key: String, param: AnyObject) {
        LSLog("onExperimentalNotify")
    }
}
