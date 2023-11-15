//
//  LSNotification.swift
//  constellation
//
//  Created by Lee on 2020/4/20.
//  Copyright © 2020 Constellation. All rights reserved.
//
/**
 通知管理类，项目里的通知分发都放在这里，便于通知参数的管理
 */

import UIKit


struct NotificationName {
    /// TabBar红点逻辑
    static let tabbarBadgeChange = NSNotification.Name(rawValue: "kNotification_tabbarBadgeChange")
    /// 登录成功
    static let loginSuccess = NSNotification.Name("kNotification_loginSuccess")
    /// 退出登录成功
    static let logoutSuccess = NSNotification.Name("kNotification_logoutSuccess")
    /// 用户信息更新
    static let userInfoChange = NSNotification.Name("kNotification_userInfoChange")
    /// 用户主页信息更新
    static let userPageInfoChange = NSNotification.Name("kNotification_userPageInfoChange")
    /// 会员信息变化
    static let vipInfoChange = NSNotification.Name("kNotification_vipInfoChange")
    /// 会员时运势信息变化
    static let vipHourFortuneChange = NSNotification.Name("kNotification_vipHourFortuneChange")
    /// 星座信息变化
    static let constellationChange = NSNotification.Name("kNotification_constellationChange")
}

class LSNotification: NSObject {
    
    
    /// Tabbar的badge 文字
    static func showTabbarBadge(_ show: Bool = true, at index: Int, content: String = "") {
        let dic = ["show":show,
                   "index":index,
                   "number":0,
                   "content":content] as [String : Any]
        NotificationCenter.default.post(name: NotificationName.tabbarBadgeChange, object: dic)
    }
    
    /// Tabbar的badge 数字
    static func showTabbarBadge(_ show: Bool = true, at index: Int, number: Int) {
        let dic = ["show":show,
                   "index":index,
                   "number":number,
                   "content":""] as [String : Any]
        NotificationCenter.default.post(name: NotificationName.tabbarBadgeChange, object: dic)
    }
    
    /// 隐藏Tabbar的badge
    static func hiddenTabbarBadge(at index: Int) {
        let dic = ["show":false,
                   "index":index,
                   "number":0,
                   "content":""] as [String : Any]
        NotificationCenter.default.post(name: NotificationName.tabbarBadgeChange, object: dic)
    }
    /// 登录成功
    static func postLoginSuccess(){
        let user = LoginManager.shared.userInfo
        NotificationCenter.default.post(name: NotificationName.loginSuccess, object: user)
    }
    /// 退出登录成功
    static func postLogoutSuccess(){
        NotificationCenter.default.post(name: NotificationName.logoutSuccess, object: nil)
    }
    
    /// 用户主页信息更新
    static func postUserPageInfoChange(){
        NotificationCenter.default.post(name: NotificationName.userPageInfoChange, object: nil)
    }
    
}
