//
//  OSSModel.swift
//  constellation
//
//  Created by Lee on 2020/4/27.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


///获取验证码
class OSSResp: RespModel {
    var data:OSSModel?
    
    override init(_ json: JSON) {
        super.init(json)
        data = OSSModel(json["data"]["oss"])
    }
}

struct OSSModel {
    
    /// 帐号id
    var accessKeyId:String = ""
    /// 帐号Secret
    var accessKeySecret:String = ""
    /// 上传文件的域
    var bucketName:String = ""
    /// 上传的oss节点
    var endPoint:String = ""
    /// 有效期
    var expire:String = ""
    /// 前缀
    var imgPrefix:String = ""
    /// 文件上传基础路径,开头和结尾都没有斜杆，例如workshop/funny/41815178093568
    var fileUploadBasePath:String = ""
    /// 下载的oss节点
    var ossDownloadPoint:String = ""
    /// 请求id
    var requestId:String = ""
    /// token
    var securityToken:String = ""
    
    init(_ json: JSON) {
        accessKeyId = json["access_key_id"].stringValue
        accessKeySecret = json["access_key_secret"].stringValue
        bucketName = json["bucket_name"].stringValue
        endPoint = json["end_point"].stringValue
        expire = json["expire"].stringValue
        imgPrefix = json["img_prefix"].stringValue
        fileUploadBasePath = json["fileUploadBasePath"].stringValue
        ossDownloadPoint = json["ossDownloadPoint"].stringValue
        requestId = json["requestId"].stringValue
        securityToken = json["security_token"].stringValue
    }
}
