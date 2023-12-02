//
//  ReportReasonListResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReportReasonListResp: RespModel {
    var data = ReportReasonListModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = ReportReasonListModel(json["data"])
    }
}

struct ReportReasonListModel {
    
    /// items
    var reasonList: [ReportReasonItem] = []
    
    init(_ json:JSON) {
        reasonList = []
        for (_, subJson) in json["reason_list"] {
            reasonList.append(ReportReasonItem(subJson))
        }
    }
    
    init() {}
}

struct ReportReasonItem {
    
    var reasonId: Int64 = 0
    var reasonDesc: String = ""
    // 选中状态（客户端使用）
    var selected: Bool = false
    
    init(_ json:JSON) {
        reasonId = json["reason_id"].int64Value
        reasonDesc = json["reason_desc"].stringValue
    }
    
    init() {}
}





