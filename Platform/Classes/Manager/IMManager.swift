//
//  IMManager.swift
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import ImSDK_Plus_Swift

class IMManager: NSObject {
    
    static let shared = IMManager()
    // 初始化 config 对象
    let config: V2TIMSDKConfig = V2TIMSDKConfig()
    let sdkAppID: Int32 = 1400826865
    let businessID: Int = 40576
    var deviceToken: Data?
    
    private override init() {
        
        super.init()
        
        IMManager.createCachePath()
        // 指定 log 输出级别。
        config.logLevel = .V2TIM_LOG_INFO
        // 添加 V2TIMSDKListener 的事件监听器，self 是 id<V2TIMSDKListener> 的实现类
//        V2TIMManager.shared.addIMSDKListener(listener: self)
        // 初始化 IM SDK，调用这个接口后，可以立即调用登录接口
        _ = initIMSDK()
    }
    
    func initIMSDK() -> Bool {
        V2TIMManager.shared.addIMSDKListener(listener: self)
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
