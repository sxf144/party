//
//  OrderStatusResp.swift
//  constellation
//
//  Created by Lee on 2020/4/27.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


/// 获取订单支付结果
class OrderStatusResp: RespModel {
    var data:OrderStatusModel?
    
    override init(_ json: JSON) {
        super.init(json)
        data = OrderStatusModel(json["data"])
    }
}

struct OrderStatusModel {
    
    /// 0待支付 1已支付 2已退款
    var state:Int64 = 0
    
    
    init(_ json: JSON) {
        state = json["state"].int64Value
    }
}
