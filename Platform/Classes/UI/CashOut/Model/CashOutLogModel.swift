//
//
//  CashOutLogResp.swift
//  constellation
//
//  Created by Lee on 2020/4/27.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


/// 获取收支记录
class CashOutLogResp: RespModel {
    var data:CashOutLogModel?
    
    override init(_ json: JSON) {
        super.init(json)
        data = CashOutLogModel(json["data"])
    }
}

class CashOutLogModel {
    
    ///
    var pageNum:Int64 = 1
    ///
    var pageSize:Int64 = 10
    ///
    var pageTotal:Int64 = 0
    ///
    var totalCount:Int64 = 0
    ///
    var logs:[CashOutItem] = []
    
    init(_ json: JSON) {
        pageNum = json["page_num"].int64Value
        pageSize = json["page_size"].int64Value
        pageTotal = json["page_total"].int64Value
        totalCount = json["total_count"].int64Value
        logs = []
        for (_, subJson) in json["logs"] {
            logs.append(CashOutItem(subJson))
        }
    }
    
    init() {}
}

class CashOutItem {
    
    /// id
    var id:Int64 = 0
    /// 金额
    var amount:Int64 = 0
    /// 创建时间
    var createTime:String = ""
    ///
    var detailId:String = ""
    ///
    var detailStatus:String = ""
    ///
    var nick:String = ""
    ///
    var realName:String = ""
    ///
    var state:Int64 = 0
    ///
    var userId:String = ""
    ///
    var zfbAccount:String = ""
    
    init(_ json: JSON) {
        id = json["id"].int64Value
        amount = json["amount"].int64Value
        createTime = json["create_time"].stringValue
        detailId = json["detail_id"].stringValue
        detailStatus = json["detail_status"].stringValue
        nick = json["nick"].stringValue
        realName = json["real_name"].stringValue
        state = json["state"].int64Value
        userId = json["user_id"].stringValue
        zfbAccount = json["zfb_account"].stringValue
    }
    
    init() {}
}
