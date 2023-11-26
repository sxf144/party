//
//  GiftListResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON

class GiftListResp: RespModel {
    var data:GiftListModel?
    
    override init(_ json: JSON) {
        super.init(json)
        data = GiftListModel(json["data"])
    }
}

struct GiftListModel {
    
    /// items
    var items: [GiftItem] = []
    
    init(_ json:JSON) {
        
        items = []
        for (_, subJson) in json["items"] {
            items.append(GiftItem(subJson))
        }
    }
    
    init() {}
}

struct GiftItem {
    
    var id: Int64 = 0
    var name: String = ""
    var amount: Int64 = 0
    var icon: String = ""
    var time: String = ""
    var selected: Bool = false
    
    init(_ json:JSON) {
        id = json["id"].int64Value
        name = json["name"].stringValue
        amount = json["amount"].int64Value
        icon = json["icon"].stringValue
        time = json["time"].stringValue
    }
    
    init() {}
}







