//
//  TabBarController.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    static let shared = TabBarController()

    let kColorTabNormal: UIColor = UIColor.ls_color("#2F1557");
    let kColorTabSelected: UIColor = UIColor.ls_color("#2F1557");
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置代理，以便拦截 tab bar 点击事件
        self.delegate = self;
        tabBar.backgroundColor = UIColor.ls_color("#ffffff");

        // Do any additional setup after loading the view.
        addChildViewControllers()
        
        /**
         设置tintColor以解决tabbar按钮文字颜色被渲染为蓝色的问题
         在iOS7中，UIView新增了一个属性tintColor，被使用在UIView中改变应用程序的外观的。默认tintColor的值为nil，这表示它将会运用父视图层次的颜色来进行着色。如果父视图中没有设置tintColor，那么默认系统就会使用蓝色。
         */
        tabBar.tintColor = kColorTabSelected
        addShadowToTabBar()
    }
    
    func addBadge(index: Int, value: String?) {
        guard let tabItems = tabBar.items, index < tabItems.count else {
            return
        }
        
        let tabItem = tabItems[index]
        if value == "0" {
            tabItem.badgeValue = nil
        } else {
            tabItem.badgeValue = value
        }
    }
    
    func addShadowToTabBar() {
        // 设置阴影属性
        tabBar.layer.shadowColor = UIColor.ls_color("#000000", alpha: 0.3).cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.masksToBounds = false
    }
}

extension TabBarController {
    
    fileprivate func addChildViewControllers() {
        addSingleChildVC(HomeController(), title: Localized(""), iconName: "tab_home_")
        addSingleChildVC(MyPartyController(), title: Localized(""), iconName: "tab_game_")
        addSingleChildVC(BaseController(), title: Localized(""), iconName: "tab_add")
        addSingleChildVC(ConversationListController(), title: Localized(""), iconName: "tab_message_")
        addSingleChildVC(MyUserPageController(), title: Localized(""), iconName: "tab_mine_")
    }
    
    private func addSingleChildVC(_ childVC: UIViewController, title: String, iconName: String) {
        
        let nav = NavigationController(rootViewController: childVC)
        
        let attriNormal = [NSAttributedString.Key.foregroundColor: kColorTabNormal,NSAttributedString.Key.font: UIFont.ls_font(11)]
        let attriSelected = [NSAttributedString.Key.foregroundColor: kColorTabSelected,NSAttributedString.Key.font: UIFont.ls_font(11)]
        
        childVC.title = title
        childVC.tabBarItem.setTitleTextAttributes(attriNormal, for: .normal)
        childVC.tabBarItem.setTitleTextAttributes(attriSelected, for: .selected)
        if (iconName.isEqual("tab_add")) {
            childVC.tabBarItem.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
            childVC.tabBarItem.selectedImage = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        } else {
            childVC.tabBarItem.image = UIImage(named: iconName + "normal")?.withRenderingMode(.alwaysOriginal)
            childVC.tabBarItem.selectedImage = UIImage(named: iconName + "selected")?.withRenderingMode(.alwaysOriginal)
        }
        
        self.addChild(nav)
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("tabBarController shouldSelect")
        // 拦截逻辑
        // 返回 true 允许切换到相应的视图控制器，返回 false 阻止切换
        if let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) {
            switch selectedIndex {
            case 2:
                // 跳转到组局界面
                PageManager.shared.pushToPublishParty()
                return false // 阻止切换
            default:
                return true // 允许切换到其他标签
            }
        }
        
        return true // 默认允许切换
    }
}








