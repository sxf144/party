//
//
//  GiftLogResp.swift
//  constellation
//
//  Created by Lee on 2020/4/27.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


/// 获取收支记录
class GiftLogResp: RespModel {
    var data:GiftLogModel?
    
    override init(_ json: JSON) {
        super.init(json)
        data = GiftLogModel(json["data"])
    }
}

class GiftLogModel {
    
    ///
    var pageNum:Int64 = 1
    ///
    var pageSize:Int64 = 10
    ///
    var pageTotal:Int64 = 0
    ///
    var totalCount:Int64 = 0
    ///
    var items:[GiftItem] = []
    
    init(_ json: JSON) {
        pageNum = json["page_num"].int64Value
        pageSize = json["page_size"].int64Value
        pageTotal = json["page_total"].int64Value
        totalCount = json["total_count"].int64Value
        items = []
        for (_, subJson) in json["items"] {
            items.append(GiftItem(subJson))
        }
    }
    
    init() {}
}
