//
//  Const.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import Foundation
import UIKit


//iOS13被废弃，用下面的方式，需要经过测试
//let kKeyWindow = UIApplication.shared.keyWindow!

let kKeyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })

/// 屏幕宽
let kScreenW = UIScreen.main.bounds.size.width
/// 屏幕高
let kScreenH = UIScreen.main.bounds.size.height
/// 状态栏高度
let kStatusBarHeight = UIApplication.shared.statusBarFrame.size.height

/// 导航栏高度
let kNavBarHeight:CGFloat = kStatusBarHeight + 44
/// tabbar高度
let kTabBarHeight:CGFloat = kStatusBarHeight > 20 ? 83:50
/// 底部安全区域的高度
let kSafeAreaHeight:CGFloat = kStatusBarHeight > 20 ? 34:0
/// 除去nav和tabbar高度
let kContentHight: CGFloat = kScreenH - kTabBarHeight - kNavBarHeight

/// 基础间距
let kMargin: CGFloat = 16

//

/// 国际化
func Localized(_ string:String, _ comment:String = "")->String{
    return NSLocalizedString(string, comment: comment)
}

/// 当前地区
let kRegionCode = NSLocale.current.regionCode ?? "US"
/// 当前国家地区是否是中国
let kRegionChina = "CN".elementsEqual(kRegionCode)

/// 当前语言环境
let kCurrentLanguage = NSLocale.preferredLanguages.first!

/// 是否是中文
let kIsChinese = "zh-Hans-CN".elementsEqual(kCurrentLanguage) || "zh-Hant-CN".elementsEqual(kCurrentLanguage) || "zh-Hant-HK".elementsEqual(kCurrentLanguage) || "zh-Hant-TW".elementsEqual(kCurrentLanguage) || "zh-Hant-MO".elementsEqual(kCurrentLanguage) || "yue-Hans-CN".elementsEqual(kCurrentLanguage) || "yue-Hant-CN".elementsEqual(kCurrentLanguage) || kCurrentLanguage.contains("zh-")


// MARK: KEYS

/// app版本号 eg: 1.0.0
let kAppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
/// app版本号 eg: 100
let kAppBuildVersion:String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

// MARK: 默认图片
let PlaceHolderAvatar = UIImage(named: "default_avatar")
let PlaceHolderBig = UIImage(named: "default_big")
let PlaceHolderSmall = UIImage(named: "default_small")

// MARK: 用户协议
let Agreement = "https://img.juzitang.net/html/agreement.html"
let Privacy = "https://img.juzitang.net/html/privacy.html"
let RechargePrivacy = "https://img.juzitang.net/html/recharge.html"

/// 管理员会话ID，需要过滤掉
let AdminConvId = "c2c_administrator"

/////////////////////////////////////////////////////////////////////////////////
//
//                             文件缓存路径
//
/////////////////////////////////////////////////////////////////////////////////
let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let LUIKit_DB_Path = DocumentsDirectory.appendingPathComponent("net_juzitang_data")
let LUIKit_Image_Path = LUIKit_DB_Path.appendingPathComponent("image")
let LUIKit_Video_Path = LUIKit_DB_Path.appendingPathComponent("video")
let LUIKit_Voice_Path = LUIKit_DB_Path.appendingPathComponent("voice")
let LUIKit_File_Path = LUIKit_DB_Path.appendingPathComponent("file")

/// 红包领取记录
let REDPACKET_RECORD = "redpacket_record"
