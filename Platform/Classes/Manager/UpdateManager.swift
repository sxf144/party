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
    
    static func checkForUpdate() {
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }

        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=net.juzitang.party") else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data, error == nil else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let latestVersion = results.first?["version"] as? String {
                    LSLog("latestVersion:\(latestVersion)")
                    if latestVersion != currentVersion {
                        // There is an update available
                        DispatchQueue.main.async {
                            showUpdateAlert(latestVersion)
                        }
                    } else {
                        LSLog("已经是最新版本！")
                    }
                } else {
                    LSLog("已经是最新版本！")
                }
            } catch {
                LSLog(error.localizedDescription)
            }
        }

        task.resume()
    }
    
    static func showUpdateAlert(_ latestVersion:String) {
        // 是否要升级版本
        let message = "v\(latestVersion)\n\n新版本发布了，更多优化功能，快来体验吧～点击下载！！！"
        let alertController = BaseAlertController(title: "发现新版本", message: message)
                
        let cancelAction = BaseAlertAction(title: "下次再说", style: .default) { (action) in
            // 处理取消按钮点击后的操作
        }
        
        let okAction = BaseAlertAction(title: "立即更新", style: .destructive) {(action) in
            // Open App Store for the update
            if let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/6472176486") {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        PageManager.shared.currentVC()?.present(alertController, animated: true, completion: nil)
    }
}


