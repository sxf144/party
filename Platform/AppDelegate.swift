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
    var launched: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // app initialize
        appInitializes()
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
        LSLog("applicationDidBecomeActive")
        // 应用回到前台时，刷新几个数据
        OSSManager.shared.loadOssInfo()
        AMapServices.shared().apiKey = "f41fc14a42f6ca6000e016f5a0bd322c"
        AMapServices.shared().enableHTTPS = true
        
        MyLocationManager.updatePrivacy()
        MyLocationManager.shared.startLocation()
        // 检查token，如果token过期，去刷新，如果有效，则登录IM
        if !LoginManager.shared.isTokenValid() {
            LoginManager.shared.refreshToken()
        } else {
            if !launched {
                launched = true
                // 登录IM
                IMManager.shared.loginIM()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        LSLog("didRegisterForRemoteNotificationsWithDeviceToken")
        
        // 把deviceToken传给IM，待IM登录后上传deviceToken
        IMManager.shared.setDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        LSLog("register remote notification failed: \(error)")
    }
    
    /*********************************************  微信SDK begin *********************************************/
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handleUrlStr = url.absoluteString
        LSLog("handleOpen options handleUrlStr:\(handleUrlStr)")
        if let handleUrl = URL(string: handleUrlStr) {
            return WXApi.handleOpen(handleUrl, delegate: WXApiManager.shared)
        }
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handleUrlStr = url.absoluteString
        LSLog("handleOpen sourceApplication handleUrlStr:\(handleUrlStr)")
        if let handleUrl = URL(string: handleUrlStr) {
            return WXApi.handleOpen(handleUrl, delegate: WXApiManager.shared)
        }
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        LSLog("userActivity restorationHandler:\(userActivity)")
        var result = true
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let webpageURL = userActivity.webpageURL {
                LSLog("userActivity restorationHandler webpageURL:\(webpageURL)")
                // 使用URLComponents来解析URL的参数
                if let urlComponents = URLComponents(url: webpageURL, resolvingAgainstBaseURL: false) {
                    // 微信标识
                    if urlComponents.path.contains("/app/") {
                        // 处理微信返回的数据
                        result = WXApi.handleOpenUniversalLink(userActivity, delegate: WXApiManager.shared)
                    } else if urlComponents.path.contains("detail") {
                        LSLog("userActivity path contain detail")
                        // 跳转到partyDetail
                        // 解析参数
                        if let queryItems = urlComponents.queryItems {
                            for queryItem in queryItems {
                                if queryItem.name == "code" {
                                    if let uniCode = queryItem.value {
                                        PageManager.shared.pushToPartyDetail(uniCode)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // 不存在webpageURL，暂不处理
            }
            
        } else {
            // 非NSUserActivityTypeBrowsingWeb模式，暂不处理
        }
        return result
    }
    /*********************************************  微信SDK end  *********************************************/
    
    @objc func handleLogin(_ notification: Notification) {
        LSLog("---- AppDelegate handleLogin ----")
        // 登录成功
        resetRootViewController()
        judgeToSupplyUserController()
        // 登录IM
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
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
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
        let tabBarController = TabBarController.shared
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
    
    func judgeToSupplyUserController() {
        LSLog("---- judgeToSupplyUserController ----")
        if let rootController = self.window?.rootViewController {
            let className = String(describing: TabBarController.self)
            let rootClassName = String(describing: type(of: rootController))
            if (rootClassName == className) {
                // 登录成功，判断是否跳转入完善资料界面
                let userInfo = LoginManager.shared.getUserInfo()
                if (userInfo?.portrait == nil || userInfo?.portrait == "") {
                    PageManager.shared.pushToSupplyUser()
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

