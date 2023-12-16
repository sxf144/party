//
//  UpdateManager.swift
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON

class UpdateManager: NSObject {
    
    static let shared = UpdateManager()
    
    private override init() {
        super.init()
    }
}

extension UpdateManager {
    
//    // 从AppStore获取版本信息
//    static func checkForUpdate() {
//        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
//            return
//        }
//
//        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=net.juzitang.party") else {
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            
//            guard let data = data, error == nil else { return }
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let results = json["results"] as? [[String: Any]],
//                   let latestVersion = results.first?["version"] as? String {
//                    LSLog("latestVersion:\(latestVersion)")
//                    if latestVersion != currentVersion {
//                        // There is an update available
//                        DispatchQueue.main.async {
//                            showUpdateAlert(latestVersion)
//                        }
//                    } else {
//                        LSLog("已经是最新版本！")
//                    }
//                } else {
//                    LSLog("已经是最新版本！")
//                }
//            } catch {
//                LSLog(error.localizedDescription)
//            }
//        }
//
//        task.resume()
//    }
    
    // 从自己服务器获取版本信息
    static func checkForUpdate() {
        NetworkManager.shared.checkVersion() { resp in
            if resp.status == .success {
                if let updateInfo = resp.data?.updateInfo, !updateInfo.updateContent.isEmpty {
                    showUpdateAlert(updateInfo)
                }
            } else {
                LSLog("checkVersion fail")
            }
        }
    }
    
    static func showUpdateAlert(_ updateInfo: UpdateInfo) {
        // 是否要升级版本
        let alertController = BaseAlertController(title: "发现新版本", message: updateInfo.updateContent)
               
        if !updateInfo.isForce {
            let cancelAction = BaseAlertAction(title: "下次再说", style: .default) { (action) in
                // 处理取消按钮点击后的操作
            }
            alertController.addAction(cancelAction)
        }
        
        let okAction = BaseAlertAction(title: "立即更新", style: .destructive) {(action) in
            // Open App Store for the update
            if let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/6472176486") {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        }
        
        // 强制的话，点击确定，弹窗不消失
        if updateInfo.isForce {
            okAction.isForce = true
        }
        
        
        alertController.addAction(okAction)
        PageManager.shared.currentVC()?.present(alertController, animated: true, completion: nil)
    }
}


