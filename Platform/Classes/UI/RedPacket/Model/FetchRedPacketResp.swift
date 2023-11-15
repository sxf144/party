//
//  FetchRedPacketResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class FetchRedPacketResp: RespModel {
    var data = FetchRedPacketModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = FetchRedPacketModel(json["data"])
    }
}

struct FetchRedPacketModel {
    
    /// 金额
    var getAmount: Int64 = 0
    
    init(_ json:JSON) {
        getAmount = json["get_amount"].int64Value
    }
    
    init() {}
}





