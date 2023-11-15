//
//  RechargeListResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON

class RechargeListResp: RespModel {
    var data = RechargeListModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = RechargeListModel(json["data"])
    }
}

struct RechargeListModel {
    
    /// items
    var items: [RechargeItem] = []
    
    init(_ json:JSON) {
        
        items = []
        for (_, subJson) in json["items"] {
            items.append(RechargeItem(subJson))
        }
    }
    
    init() {}
}

struct RechargeItem {
    
    var id: Int64 = 0
    var productId: String = ""
    var title: String = ""
    var coinAmount: Int64 = 0
    var cashAmount: Int64 = 0
    var selected: Bool = false
    
    init(_ json:JSON) {
        id = json["id"].int64Value
        productId = json["product_id"].stringValue
        title = json["title"].stringValue
        coinAmount = json["coin_amount"].int64Value
        cashAmount = json["cash_amount"].int64Value
    }
    
    init() {}
}







