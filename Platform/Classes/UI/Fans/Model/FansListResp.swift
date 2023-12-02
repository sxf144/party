//
//  FansListResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class FansListResp: RespModel {
    var data: FansListModel?
    
    override init(_ json: JSON) {
        super.init(json)
        data = FansListModel(json["data"])
    }
}

class FansListModel {
    
    /// 页数
    var pageNum: Int64 = 1
    /// 每页数量
    var pageSize: Int64 = 10
    /// 总页数
    var pageTotal: Int64 = 1
    /// 总页数
    var totalCount: Int64 = 10
    /// users
    var users: [FansItem] = []
    
    
    init(_ json:JSON) {
        pageNum = json["page_num"].int64Value
        pageSize = json["page_size"].int64Value
        pageTotal = json["page_total"].int64Value
        totalCount = json["total_count"].int64Value
        users = []
        for (_, subJson) in json["users"] {
            users.append(FansItem(subJson))
        }
    }
    
    init() {}
}

class FansItem {
    
    var userId: String = ""
    var nick: String = ""
    var portrait: String = ""
    var intro: String = ""
    var sex: Int64 = 0
    var coinBalance: Int64 = 0
    var selected: Bool = false
    var needSelect: Bool = false
    
    init(_ json:JSON) {
        userId = json["user_id"].stringValue
        nick = json["nick"].stringValue
        portrait = json["portrait"].stringValue
        intro = json["intro"].stringValue
        sex = json["sex"].int64Value
        coinBalance = json["coin_balance"].int64Value
    }
    
    init() {}
}





