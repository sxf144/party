//
//  Config.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

let kTencentQQAppId = "101870902"


/// 输出日志
///
/// - parameter message:  日志消息
/// - parameter file:     文件名
/// - parameter method:   方法名
/// - parameter line:     代码行数
func LSLog<T>(_ message: T?,
                           file: String = #file,
                           method: String = #function,
                           line: Int = #line)
{
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(String(describing:  message))")
    #endif
}


#if DEBUG
/// 服务器域名：测试环境
fileprivate let kImageServerHost = "https://miaozhua-test.oss-cn-hangzhou.aliyuncs.com"
#else
/// 服务器域名：正式环境
fileprivate let kImageServerHost = "https://image.52mengdong.com"
#endif

/// 图片链接
func imageUrlStr(_ path:String?) -> String {
    guard let path = path else { return "" }
    if path.contains("http://") || path.contains("https://") {
        return path
    }
    
    let endPoint = OSSManager.shared.ossInfo?.ossDownloadPoint
    var hostUrl = endPoint != nil ? (endPoint ?? kImageServerHost) : kImageServerHost
    if hostUrl.count == 0 {
        hostUrl = kImageServerHost
    }
    let urlStr = hostUrl + "/" + path
    return urlStr
}

/// 图片链接
func imageUrl(_ path:String?) -> URL? {
    let urlStr = imageUrlStr(path)
    let url = URL(string: urlStr.ls_urlEncoded())
    return url
}


class Config: NSObject {
    
}
