//
//  QueryRedPacketResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class QueryRedPacketResp: RespModel {
    var data:QueryRedPacketModel?
    
    override init(_ json: JSON) {
        super.init(json)
        data = QueryRedPacketModel(json["data"])
    }
}

class QueryRedPacketModel {
    
    /// 红包ID
    var id: Int64 = 0
    /// 金额
    var amount: Int64 = 0
    /// 数量
    var count: Int64 = 0
    /// 领取方式 1 拼手气 2平分
    var getType: Int64 = 0
    /// 剩余个数
    var remainCount: Int64 = 0
    /// 剩余总金额
    var remainAmount: Int64 = 0
    /// 群红包时表示群ID
    var uniqueCode: String = ""
    /// 接受者ID
    var toUserId: String = ""
    /// 领取记录
    var logs: [RedPacketFetchItem] = []
    
    init(_ json:JSON) {
        id = json["id"].int64Value
        amount = json["amount"].int64Value
        count = json["count"].int64Value
        getType = json["get_type"].int64Value
        remainCount = json["remain_count"].int64Value
        remainAmount = json["remain_amount"].int64Value
        uniqueCode = json["unique_code"].stringValue
        toUserId = json["to_user_id"].stringValue
        logs = []
        
        for (_, subJson) in json["logs"] {
            logs.append(RedPacketFetchItem(subJson))
        }
    }
    
    init() {}
}

class RedPacketFetchItem {
    
    /// 领取金额
    var amount:Int64 = 0
    /// 用户ID
    var userId:String = ""
    /// 用户昵称
    var nick:String = ""
    /// 用户头像
    var portrait:String = ""
    /// 领取时间
    var fetchTime:String = ""
    
    init(_ json: JSON) {
        amount = json["amount"].int64Value
        userId = json["user_id"].stringValue
        nick = json["nick"].stringValue
        portrait = json["portrait"].stringValue
        fetchTime = json["fetch_time"].stringValue
    }
    
    init() {}
}




