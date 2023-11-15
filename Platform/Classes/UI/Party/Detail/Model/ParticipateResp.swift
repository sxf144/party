//
//  ParticipateResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class ParticipateResp: RespModel {
    var data = ParticipateModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = ParticipateModel(json["data"])
    }
}

struct ParticipateModel {
    
    /// 用户ID
    var participateList: [SimpleUserInfo] = []
    
    init(_ json:JSON) {
        
        for (_, subJson) in json["participate_list"] {
            participateList.append(SimpleUserInfo(subJson))
        }
    }
    
    init() {}
}



