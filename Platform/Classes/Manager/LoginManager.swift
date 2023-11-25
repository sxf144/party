//
//  LoginManager.swift
//  constellation
//
//  Created by Lee on 2020/4/17.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate let KEY_USER_LOGIN_TOKEN = "KEY_USER_LOGIN_TOKEN"//登录token
fileprivate let KEY_USER_LOGIN_INFO = "KEY_USER_LOGIN_INFO"//登录信息
fileprivate let KEY_USER_PAGE_INFO = "KEY_USER_PAGE_INFO"//用户主页信息

class LoginManager: NSObject {
    
    
    static let shared = LoginManager()
    
    // 防止重复请求
    var tokenRefreshing:Bool = false
    var isLoginSuceess = false
    var uid:Int = 0
    var tokenInfo: UserTokenModel?
    var userInfo: UserInfoModel?
    var userPageInfo: UserPageModel?
    
    private override init() {
        super.init()
        loadLoaclData()
    }
    
    func loadLoaclData(){
        let token = getUserToken()
        let user = getUserInfo()
        if let user = user {
            tokenInfo = token
            userInfo = user
            isLoginSuceess = true
        }
    }
}

extension LoginManager{
    
    /// 更新用户信息
    func updateUserInfo(_ user: UserInfoModel?){
        guard let user = user else { return }
        userInfo = user
        uid = Int(user.userId) ?? 0
        saveUserInfo(user)
    }
    
    func logout(){
        isLoginSuceess = false
        uid = 0
        tokenInfo = nil
        userInfo = nil
        userPageInfo = nil
        
        removeLocalUserInfo()
        removeUserToken()
        removeLocalUserPageInfo()
        
        // 发送退出登录通知
        LSNotification.postLogoutSuccess()
    }
    
    /// 登录失效
    func loginExpird(){
        logout()
    }
}

extension LoginManager {
    
    //保存用户信息
    func saveUserToken(_ token: UserTokenModel){
        tokenInfo = token
        let json = token.modelToJson()
        var data: Data?
        do {
            data = try json.rawData()
        } catch {
            
        }
        UserDefaults.standard.set(data, forKey: KEY_USER_LOGIN_TOKEN)
    }
    
    //本地的用户信息
    func getUserToken()->UserTokenModel?{
        if (tokenInfo != nil) {
            return tokenInfo
        }
        let data = UserDefaults.standard.data(forKey: KEY_USER_LOGIN_TOKEN)
        guard data != nil else { return nil }
        var json:JSON?
        do {
            json = try JSON(data: data!)
        } catch  {
            
        }
        if let json = json {
            let token = UserTokenModel(json)
            tokenInfo = token
            return tokenInfo
        }
        return nil
    }
    
    /// 清除token
    func removeUserToken(){
        UserDefaults.standard.removeObject(forKey: KEY_USER_LOGIN_TOKEN)
    }

    //保存用户信息
    func saveUserInfo(_ user: UserInfoModel){
        userInfo = user
        let json = user.modelToJson()
        var data: Data?
        do {
            data = try json.rawData()
        } catch {
            
        }
        UserDefaults.standard.set(data, forKey: KEY_USER_LOGIN_INFO)
    }
    
    //本地的用户信息
    func getUserInfo()->UserInfoModel? {
        if (userInfo != nil) {
            return userInfo
        }
        let data = UserDefaults.standard.data(forKey: KEY_USER_LOGIN_INFO)
        guard data != nil else { return nil }
        var json:JSON?
        do {
            json = try JSON(data: data!)
        } catch  {
            
        }
        if let json = json {
            let user = UserInfoModel(json)
            userInfo = user
            return userInfo
        }
        return nil
    }
    
    func removeLocalUserInfo(){
        UserDefaults.standard.removeObject(forKey: KEY_USER_LOGIN_INFO)
    }
    
    // 保存个人主页信息
    func saveUserPageInfo(_ userPage: UserPageModel){
        userPageInfo = userPage
        let json = userPage.modelToJson()
        var data: Data?
        do {
            data = try json.rawData()
        } catch {
            
        }
        UserDefaults.standard.set(data, forKey: KEY_USER_PAGE_INFO)
    }
    
    // 本地的个人主页信息
    func getUserPageInfo()->UserPageModel? {
        if (userPageInfo != nil) {
            return userPageInfo
        }
        let data = UserDefaults.standard.data(forKey: KEY_USER_PAGE_INFO)
        guard data != nil else { return nil }
        var json:JSON?
        do {
            json = try JSON(data: data!)
        } catch  {
            
        }
        if let json = json {
            let userPage = UserPageModel(json)
            userPageInfo = userPage
            return userPageInfo
        }
        return nil
    }
    
    // 清除个人主页信息
    func removeLocalUserPageInfo(){
        UserDefaults.standard.removeObject(forKey: KEY_USER_PAGE_INFO)
    }
    
    func login() {
        NetworkManager.shared.login { (uresp) in
            if uresp.status == .success {
                LSLog("login data:\(uresp.data)")
                // 保存userInfo
                LoginManager.shared.saveUserInfo(uresp.data)
                
                // 发送登录成功通知
                LSNotification.postLoginSuccess()
                LSHUD.showSuccess("授权登录成功")
            } else {
                //错误提示，获取用户信息失败
                LSHUD.showError(uresp.msg)
            }
        }
    }
    
    func refreshToken() {
        if (tokenRefreshing) {
            return
        }
        tokenRefreshing = true
        // 登录失效的统一处理
        if let token = getUserToken() {
            let grantType = GrantType.refreshToken.rawValue
            let refreshToken = token.refreshToken
            // 发起授权登录，刷新token
            NetworkManager.shared.authorize("", smsCode: "", code: "", grantType: grantType, source: "", refreshToken: refreshToken, identityToken: "") { [self] (resp) in
                if resp.status == .success {
                    // 保存token
                    LoginManager.shared.saveUserToken(resp.data)
                    LSLog("authorize data:\(resp.data)")
                    // 刷新token成功，发起login，重新获取userInfo
                    login()
                } else {
                    // 刷新token失败，重新登录
                    LSHUD.showError(resp.msg)
                    loginExpird()
                }
                
                self.tokenRefreshing = false
            }
        } else {
            tokenRefreshing = false
            loginExpird()
        }
    }
    
    func getUserPage() {
        
        NetworkManager.shared.getUserPage () { resp in
            if resp.status == .success {
                LSLog("getUserPage data:\(resp.data)")
                // 保存userInfo
                LoginManager.shared.saveUserPageInfo(resp.data)
                
                // 发送用户主页信息更新通知
                LSNotification.postUserPageInfoChange()
            } else {
                LSLog("getUserPage fail")
            }
        }
    }
}
