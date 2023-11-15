//
//  RespModel.swift
//  constellation
//
//  Created by Lee on 2020/4/15.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON

class RespModel: NSObject {
    
    /// 请求状态描述
    var msg: String?
    var messageId: String?
    /// 请求状态。0表示成功，其它表示失败
    var status: Network.ResultCode?
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        status = Network.ResultCode(rawValue: json["state"].int ?? -100)
        msg = json["msg"].string
        messageId = json["messageId"].string
        
    }
    
}
