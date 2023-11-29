//
//  Network.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

/// 输出日志
///
/// - parameter message:  日志消息
/// - parameter file:     文件名
/// - parameter method:   方法名
/// - parameter line:     代码行数
fileprivate func NetLog<T>(message: T?,
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
fileprivate let kServerHost = "https://api.juzitang.net/party"
#else
/// 服务器域名：正式环境
fileprivate let kServerHost = "https://api.juzitang.net/party"
#endif

fileprivate let APP_TYPE = "mobile-ios"
fileprivate let APP_NAME = "juzitang"

class Network: NSObject {
    
//    // 防止重复请求
//    var tokenRefreshing:Bool = false

    enum ResultCode: Int {
        /// 成功
        case success = 0
        /// token过期/登录失效
        case token_expired = 401
        /// vip过期
        case vip_expired = 300
        /// 本地网络错误
        case local_error = -100
        /// 红包已抢完
        case redpacket_finished = -10001
        /// 红包已过期
        case redpacket_expired = -10002
        /// 红包已领取过
        case redpacket_fetched = -10003
    }
    
    static let shared = Network()
    
    private override init() {
        super.init()
        
    }
    
    
    /// 服务器地址
    private var hostAddress: String {
        return kServerHost
    }
    
    /// 请求头http header
    private var httpHeader: HTTPHeaders {
        let platformName: String = UIDevice.current.systemName.lowercased()
        let iosVersion : String = UIDevice.current.systemVersion
        let deviceName: String = UIDevice.current.model.lowercased()
        let channel = "appstore"
//        let deviceUUID:String! =  UIDevice.current.identifierForVendor?.uuidString
        let timestamp = Date().ls_timeStamp
        var header = HTTPHeaders()
        header["apptype"] = APP_TYPE
        header["appname"] = APP_NAME
        header["versioncode"] = String(format: "%@",kAppBuildVersion)
        if let token = LoginManager.shared.getUserToken() {
            header["Authorization"] = token.tokenType + " " + token.accessToken
        }
        header["User-Agent"] = "party_fun;\(kAppVersion);\(platformName);\(iosVersion);\(deviceName);\(channel)"
        header["timestamp"] = timestamp
        header["Content-Type"] = "application/json"
        return header
    }

}


// MARK: 接口
extension Network {
    /// http的get请求
    @discardableResult
    func httpGetRequest(path:String,para:Parameters?, response:  @escaping (JSON)->()) -> DataRequest {
        
        let url = getRequestUrl(path)
        NetLog(message: "get:" + url)
        NetLog(message: para)
        let timestamp = Date().ls_milliStamp
        var header = getHttpHeader(timestamp)
        header["sign"] = getSign(path)
        NetLog(message: header)
        let reqest = AF.request(url, method: .get, parameters: para, encoding: URLEncoding.default, headers: header).responseJSON { (result) in
            
            switch result.result {
            case .success(let value):
                let jsonSwift = JSON(value)
                self.handleResponseResult(json: jsonSwift)
                response(jsonSwift)
                NetLog(message: "url:\(url)")
                NetLog(message: "JSON: \(jsonSwift)")
                
            case .failure(let error):
                NetLog(message: error)
                let json:JSON = ["status":-100,"message":"请求失败"]
                response(json)
                NetLog(message: "url:\(url)")
                NetLog(message: "JSON: \(json)")
            }
        }
        
        NetLog(message: "requestId:\(reqest.id), url:\(String(describing: reqest.request?.url))")
        return reqest
    }
    
    /// http的put请求
    func httpPutRequest(path:String,para:Parameters?, response:  @escaping (JSON)->()){
        
        let url = getRequestUrl(path)
        NetLog(message: "put:" + url)
        NetLog(message: para)
        let timestamp = Date().ls_milliStamp
        var header = getHttpHeader(timestamp)
        header["sign"] = getSign(para, timestamp: timestamp)
        AF.request(url, method: .put, parameters: para, encoding: JSONEncoding.default, headers: header).responseJSON { (result) in
            
            switch result.result {
            case .success(let value):
                let jsonSwift = JSON(value)
                self.handleResponseResult(json: jsonSwift)
                response(jsonSwift)
                NetLog(message: "url:\(url)")
                NetLog(message: "JSON: \(jsonSwift)")
                
            case .failure(let error):
                NetLog(message: error)
                let json:JSON = ["status":-100,"message":"请求失败"]
                response(json)
                NetLog(message: "url:\(url)")
                NetLog(message: "JSON: \(json)")
            }
            
        }
    }
    
    /// http的post请求
    @discardableResult
    func httpPostRequest(path:String,para:Parameters?, response:  @escaping (JSON)->()) -> DataRequest{
        
        let url = getRequestUrl(path)
        NetLog(message: "post:" + url)
        NetLog(message: para)
        let timestamp = Date().ls_milliStamp
        var header = getHttpHeader(timestamp)
        header["sign"] = getSign(para, timestamp: timestamp)
        let request = AF.request(url, method: .post, parameters: para, encoding: JSONEncoding.default, headers: header).responseJSON { (result) in
            
            switch result.result {
            case .success(let value):
                let jsonSwift = JSON(value)
                self.handleResponseResult(json: jsonSwift)
                response(jsonSwift)
                NetLog(message: "url:\(url)")
                NetLog(message: "JSON: \(jsonSwift)")
                
            case .failure(let error):
                NetLog(message: error)
                if let data = result.data {
                    let str = String(data: data, encoding: String.Encoding.utf8)
                    NetLog(message: str)
                }
                
                let json:JSON = ["status":-100,"message":"请求失败"]
                response(json)
                NetLog(message: "url:\(url)")
                NetLog(message: "JSON: \(json)")
            }
            
        }
        
        return request
    }
    
    // http的delete请求
    func httpDeleteRequest(path:String,para:Parameters?, response:  @escaping (JSON)->()){
        
        let url = getRequestUrl(path)
        NetLog(message: "delete:" + url)
        NetLog(message: para)
        let timestamp = Date().ls_milliStamp
        var header = getHttpHeader(timestamp)
        header["sign"] = getSign(path)
        //TODO: delete 请求的参数放在body中的情况
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: httpHeader).responseJSON { (result) in
            
            switch result.result {
            case .success(let value):
                let jsonSwift = JSON(value)
                self.handleResponseResult(json: jsonSwift)
                response(jsonSwift)
                NetLog(message: "url:\(url)")
                NetLog(message: "JSON: \(jsonSwift)")
            case .failure(let error):
                NetLog(message: error)
                let json:JSON = ["status":-100,"message":"请求失败"]
                response(json)
                NetLog(message: "url:\(url)")
                NetLog(message: "JSON: \(json)")
            }
            
        }
    }
}

fileprivate extension Network {
    
     func getRequestUrl(_ path: String) -> String {
        let url = hostAddress + path
        //        url = url.addingPercentEncoding(withAllowedCharacters: )
        return url
    }
    
    func getHttpHeader(_ timestamp:String) -> HTTPHeaders {
        //        let deviceUUID:String! =  UIDevice.current.identifierForVendor?.uuidString
        let platformName: String = UIDevice.current.systemName.lowercased()
        let iosVersion : String = UIDevice.current.systemVersion
        let deviceName: String = UIDevice.current.model.lowercased()
        let channel = "appstore"
        var header = HTTPHeaders()
        header["apptype"] = APP_TYPE
        header["appname"] = APP_NAME
        header["versioncode"] = kAppBuildVersion
        //        header["imei"] = deviceUUID
        header["channel"] = channel
        if let token = LoginManager.shared.getUserToken() {
            header["Authorization"] = token.tokenType + " " + token.accessToken
        }
        // UA格式"party_fun;1.1;android;12;HUAWEI;default"
        header["User-Agent"] = "party_fun;\(kAppVersion);\(platformName);\(iosVersion);\(deviceName);\(channel)"
        header["timestamp"] = String(format: "%@",timestamp)
        header["Content-Type"] = "application/json"
        return header
    }
    
    func getSign(_ path:String) -> String {
        let encode = path.ls_urlEncoded()
        let sign = encode.ls_md5
//        NetLog(message: "befor sign:\(encode) \n after sign:\(sign)")
        return sign
    }
    
    func getSign(_ para:Parameters?,timestamp:String) -> String{
        var signPara = para
        signPara?["versioncode"] = kAppBuildVersion
        signPara?["apptype"] = APP_TYPE
        signPara?["appname"] = APP_NAME
        signPara?["timestamp"] = timestamp
        let sign = getSignString(dic: signPara)
        return sign
    }
    
    /// 从字典获取有序的key=value字符串（String）
    private func getSignString(dic:Dictionary<String,Any>?) -> String{
        
        if dic?.keys.count == 0 || dic == nil {
            return ""
        }
        var result: String = ""
        let sortKeys =  dic?.keys.sorted(by: <)
        
        for item in sortKeys! {
            // result = "\(String(describing: result))\(item)=\(dic![item])"
            let value = dic![item]
            
            if let value = value {
                let valueType = type(of: value)
                if valueType == Array<Any>.self ||  valueType == NSArray.self{
                    continue
                }
                var valueEncode = value
                if (valueType == String.self || valueType == NSString.self) {
                    var str = value as! String
                    if str == "" {
                        continue
                    }
                    /**
                     字符串空格的问题，iOS端空格编码以后是%20，而服务端空格编码以后是+，导致sign校验不过。与服务端商议，在sign编码的时候剔除字符串中的空格。*(%2A)星号 不编码
                    */
                    str = str.replacingOccurrences(of: " ", with: "")
                    str = str.replacingOccurrences(of: "*", with: "")
                    str = str.ls_urlEncoded()
                    //@"测试一哈（*ﾟ∀ﾟ）つ―{}@{}@{}-来吃现";
                    //这个颜文字的*（%2A）替换没有生效，在转换以后再替换
                    str = str.replacingOccurrences(of: "%2A", with: "")
                    valueEncode = str
                }
                
                if result == "" {
                    result = "\(result)\(item)=\(valueEncode)"
                }else{
                    result = "\(result)&\(item)=\(valueEncode)"
                }
            }

        }
        let md5Str = result.ls_md5
        LSLog("result:\(result) md5:\(md5Str)")
        return md5Str
    }
    
    func handleResponseResult(json:JSON){
        let code = ResultCode(rawValue: json["state"].intValue)
        if code == ResultCode.token_expired {
            LoginManager.shared.refreshToken()
        }
    }
    
    //字典转json字符串
    func toJSONString(dict:Dictionary<String, Any>?)->String{
        
        if let dict = dict {
            let data = try? JSONSerialization.data(withJSONObject: dict)
            
            let strJson = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            return strJson! as String
        }else{
            return ""
        }
    }
    
}
