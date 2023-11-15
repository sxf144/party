//
//  GiftGiveResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class GiftGiveResp: RespModel {
    var data = GiftGiveModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = GiftGiveModel(json["data"])
    }
}

struct GiftGiveModel {
    
    /// 当前代币数
    var coinBalance: Int64 = 1
    
    
    init(_ json:JSON) {
        coinBalance = json["coin_balance"].int64Value
    }
    
    init() {}
}





