//
//  AppDelegate+Utils.swift
//  FY-JetChat
//
//  Created by iOS.Jet on 2019/2/28.
//  Copyright © 2019 Jett. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import SwifterSwift
import ImSDK_Plus_Swift

extension AppDelegate {
    
    // MARK: - AppearanceSetting
    func appearanceSetting() {
        // iOS 11 及其以上系统运行
        if #available(iOS 11, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
            UITableView.appearance().contentInsetAdjustmentBehavior = .never
            UICollectionView.appearance().contentInsetAdjustmentBehavior = .never
        }
    }
    
    // MARK: - 键盘管理
    func keyboardManager() {
        //开启键盘监听
        IQKeyboardManager.shared.enable = true
        //控制点击背景是否收起键盘
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        //控制键盘上的工具条文字颜色是否用户自定义
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = true
        //IQKeyboardManager.sharedManager().shouldToolbarUsesTextFieldTintColor = true
        //将右边Done改成完成
        //IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "完成"
        // 控制是否显示键盘上的工具条
        IQKeyboardManager.shared.enableAutoToolbar = true
        //最新版的设置键盘的returnKey的关键字 ,可以点击键盘上的next键，自动跳转到下一个输入框，最后一个输入框点击完成，自动收起键盘
        IQKeyboardManager.shared.toolbarManageBehaviour = .byPosition
    }
    
    func appInitializes() {
        // 添加监听
        addObservers()
        keyboardManager()
        appearanceSetting()
        _ = WXApiManager.shared.registerApp()
    }
}



