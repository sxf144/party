//
//  WxOrderModel.swift
//  constellation
//
//  Created by Lee on 2020/4/27.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


///获取验证码
class WxOrderResp: RespModel {
    var data:WxOrderModel?
    
    override init(_ json: JSON) {
        super.init(json)
        data = WxOrderModel(json["data"]["weixin"])
    }
}

struct WxOrderModel {
    
    ///
    var appid:String = ""
    ///
    var noncestr:String = ""
    ///
    var package:String = ""
    ///
    var partnerid:String = ""
    ///
    var prepay_id:String = ""
    ///
    var prepayid:String = ""
    ///
    var sign:String = ""
    ///
    var timestamp:String = ""
    
    init(_ json: JSON) {
        appid = json["appid"].stringValue
        noncestr = json["noncestr"].stringValue
        package = json["package"].stringValue
        partnerid = json["partnerid"].stringValue
        prepay_id = json["prepay_id"].stringValue
        prepayid = json["prepayid"].stringValue
        sign = json["sign"].stringValue
        timestamp = json["timestamp"].stringValue
    }
}
