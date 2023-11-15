//
//  PublishResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class PublishResp: RespModel {
    var data = PublishModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = PublishModel(json["data"])
    }
}

struct PublishModel {
    
    /// 页数
    var startTime: String = ""
    /// 每页数量
    var endTime: String = ""
    /// 总页数
    var uniqueCode: String = ""
    
    
    init(_ json:JSON) {
        startTime = json["start_time"].stringValue
        endTime = json["end_time"].stringValue
        uniqueCode = json["unique_code"].stringValue
    }
    
    init() {}
}





