//
//  AppDelegate.swift
//  Platform
//
//  Created by Lee on 2021/7/1.
//

import UIKit
import AMapFoundationKit
import AMapLocationKit
import ImSDK_Plus_Swift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // app initialize
        appInitializes()
        // 添加监听
        addObservers()
        // 注册通知
        registNotification()
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)

        // resetRootViewController
        resetRootViewController()

        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        OSSManager.shared.loadOssInfo()
        AMapServices.shared().apiKey = "f41fc14a42f6ca6000e016f5a0bd322c"
        AMapServices.shared().enableHTTPS = true
        
        MyLocationManager.updatePrivacy()
        MyLocationManager.shared.startLocation()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        LSLog("didRegisterForRemoteNotificationsWithDeviceToken")
        
//        // 将 deviceToken 转换为字符串，通常是将其转换为十六进制字符串
//        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//
//        // 输出模拟的设备令牌
//        LSLog("Simulated Device Token: \(token)")
        
        let apnsConfig:V2TIMAPNSConfig = V2TIMAPNSConfig()
        apnsConfig.token = deviceToken
        apnsConfig.businessID = 40576
        V2TIMManager.shared.setAPNS(config: apnsConfig) {
            LSLog("setAPNS succ")
        } fail: { code, desc in
            LSLog("setAPNS fail code:\(code), desc:\(desc)")
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LSLog("register remote notification failed: \(error)")
    }
    
    @objc func handleLogin(_ notification: Notification) {
        // 登录成功
        resetRootViewController()
        judgeToModifyUserController()
        // 发起IM登录
        IMManager.shared.loginIM()
    }
    
    @objc func handleLogout(_ notification: Notification) {
        // 退出登录，刷新rootController
        resetRootViewController()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogin(_:)), name: NotificationName.loginSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout(_:)), name: NotificationName.logoutSuccess, object: nil)
        
        V2TIMManager.shared.setAPNSListener(apnsListener: self)
    }
    
    func registNotification()
    {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
                if granted {
                UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    // 创建并返回一个tabbar控制器
    func createTabBarController() -> TabBarController {
        let tabBarController = TabBarController()
        // 在这里配置你的tabbar控制器，添加需要的视图控制器和标签项
        return tabBarController
    }
    
    // 创建并返回一个NavigationController控制下的登录视图控制器
    func createNavController() -> NavigationController {
        let navController = NavigationController(rootViewController: LoginController())
        // 配置登录视图控制器的界面
        return navController;
    }
    
    // 在登录成功后调用此方法以更改根视图控制器
    func resetRootViewController() {
        // 读取数据
        let token = LoginManager.shared.getUserToken()
        let userInfo = LoginManager.shared.getUserInfo()
        LSLog("token:\(String(describing: token)), userInfo: \(String(describing: userInfo))")
        let newController: UIViewController
        
        if (token != nil && userInfo != nil && userInfo?.userId != nil && userInfo?.userId != "") {
            // 如果用户已经登录，跳转到TabBarController
            if let rootController = self.window?.rootViewController {
                let className = String(describing: TabBarController.self)
                let rootClassName = String(describing: type(of: rootController))
                if (rootClassName == className) {
                    return
                }
            }
            
            newController = createTabBarController()
            LSLog("newController type name: \(type(of: newController))")
        } else {
            // 如果用户未登录，跳转到NavigationController(LoginController)
            if let rootController = self.window?.rootViewController {
                let className = String(describing: NavigationController.self)
                let rootClassName = String(describing: type(of: rootController))
                if (rootClassName == className) {
                    return
                }
            }
            
            newController = createNavController()
            LSLog("newController type name: \(type(of: newController))")
        }
        
        // 设置转场动画
        UIView.transition(with: window!,
                          duration: 0.5, // 动画持续时间
                          options: .transitionCrossDissolve, // 过渡效果，这里使用淡入淡出效果
                          animations: {
                            self.window?.rootViewController = newController
                          },
                          completion: nil)
    }
    
    func judgeToModifyUserController() {
        if let rootController = self.window?.rootViewController {
            let className = String(describing: TabBarController.self)
            let rootClassName = String(describing: type(of: rootController))
            if (rootClassName == className) {
                // 登录成功，判断是否跳转入完善资料界面
                let userInfo = LoginManager.shared.getUserInfo()
                // 如果没有头像就跳转入完善资料
                if (userInfo?.portrait == nil || userInfo?.portrait == "") {
                    PageManager.shared.pushToModifyUser()
                }
            }
        }
    }
}

extension AppDelegate: V2TIMAPNSListener {
    
    func onSetAPPUnreadCount() -> UInt {
        return 0
    }
}

