//
//  CreateOrderResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class CreateOrderResp: RespModel {
    var data = CreateOrderModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = CreateOrderModel(json["data"])
    }
}

struct CreateOrderModel {
    
    /// 订单号
    var orderId: String = ""
    
    init(_ json:JSON) {
        orderId = json["order_id"].stringValue
    }
    
    init() {}
}



