//
//  CheckVersionResp.swift
//  constellation
//
//  Created by Lee on 2020/4/27.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


/// 获取订单支付结果
class CheckVersionResp: RespModel {
    var data:CheckVersionModel?
    
    override init(_ json: JSON) {
        super.init(json)
        data = CheckVersionModel(json["data"])
    }
}

struct CheckVersionModel {
    
    /// 更新信息
    var updateInfo: UpdateInfo = UpdateInfo()
    
    init(_ json: JSON) {
        updateInfo = UpdateInfo(json["update_info"])
    }
    
    init() {}
}

struct UpdateInfo {
    
    /// 当前版本
    var currentVersion: String = ""
    /// 新版本
    var newVersion: String = ""
    /// 是否强制更新
    var isForce: Bool = true
    /// 更新内容
    var updateContent: String = ""
    
    init(_ json: JSON) {
        currentVersion = json["current_version"].stringValue
        newVersion = json["new_version"].stringValue
        isForce = json["is_force"].boolValue
        updateContent = json["update_content"].stringValue
    }
    
    init() {}
}
