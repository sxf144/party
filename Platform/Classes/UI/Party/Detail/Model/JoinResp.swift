//
//  JoinResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class JoinResp: RespModel {
    var data = JoinModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = JoinModel(json["data"])
    }
}

struct JoinModel {
    
    /// 渠道号
    var channel: Int64 = 0
    /// 订单号
    var orderId: String = ""
    /// 成功
    var success: Bool = true
    
    init(_ json:JSON) {
        channel = json["channel"].int64Value
        orderId = json["order_id"].stringValue
        success = json["success"].boolValue
    }
    
    init() {}
}



