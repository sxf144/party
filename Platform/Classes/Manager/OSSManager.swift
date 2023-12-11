//
//  OSSManager.swift
//  constellation
//
//  Created by Lee on 2020/4/27.
//  Copyright © 2020 Constellation. All rights reserved.
//
/**
 云工具，上传、下载文件等
 目前使用的是阿里云
 */

import UIKit
import AliyunOSSiOS

enum OBJECT_KEY_TYPE: String {
    case portrait = "portrait"
    case img = "img"
    case video = "video"
}

class OSSManager: NSObject {
    
    static let shared = OSSManager()
    
    var ossInfo: OSSModel?
    var client: OSSClient?
    
    private override init() {
        super.init()
    }
}

//MARK: -文件上传
extension OSSManager {
    /// 上传图片
    func uploadData(_ data: Data?, type: OBJECT_KEY_TYPE, suffix:String, _ complete:@escaping(OSSUploadResult)->()){
        DispatchQueue.global().async {
            var uploadResult = OSSUploadResult()
            self.ossInfoCanUse { (canUse) in
                if canUse {
                    let request = OSSPutObjectRequest()
                    guard let data = data else {
                        // 失败
                        DispatchQueue.main.async {
                            uploadResult.status = .failed
                            complete(uploadResult)
                        }
                        return
                    }
                    
                    request.uploadingData = data
                    request.bucketName = self.bucketName()
                    let sha1Str = OSSUtil.sha1(with: data) ?? "aaa"
//                    let objectKey = self.getAvatarImageFileName(".png", sha1Str: sha1Str)
                    let objectKey = self.getFileName(type, sha1Str: sha1Str, suffix: suffix)
                    request.objectKey = objectKey
                    uploadResult.objectKey = objectKey
                    uploadResult.baseUrl = self.baseUrl()
                    uploadResult.fullUrl = uploadResult.baseUrl + objectKey
                    request.uploadProgress = { (bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
//                        LSLog("bytesSent:\(bytesSent),totalBytesSent:\(totalBytesSent),totalBytesExpectedToSend:\(totalBytesExpectedToSend)");
                           }
                    
                    let task = self.client?.putObject(request)
                    task?.continue({ (t) -> Any? in
                        DispatchQueue.main.async {
                            if (t.error != nil) {
                                let error: NSError = (t.error)! as NSError
                                LSLog("error:\(error.description)")
                                uploadResult.status = .failed
                                complete(uploadResult)
                            }else{
                                let result = t.result
                                LSLog("success:\(result?.description ?? "")")
                                uploadResult.status = .success
                                complete(uploadResult)
                            }
                        }
                        return nil
                        
                    }).waitUntilFinished()
                    
                } else {
                    // 失败
                    DispatchQueue.main.async {
                        uploadResult.status = .failed
                        complete(uploadResult)
                    }
                }
            }
        }
        
    }
}

fileprivate extension OSSManager {
    
    func bucketName()->String{
        guard let name = ossInfo?.bucketName else { return "" }
        return name
    }
    
    func baseUrl()->String{
        guard let baseUrl = ossInfo?.imgPrefix else { return "" }
        return baseUrl
    }
    
    func getImageFileName(_ suffix:String)->String {
        let timeStamp = Date().ls_milliStamp
        let basePath = ossInfo?.imgPrefix ?? ""
        
        let name = basePath + "/image/" + timeStamp + suffix
        return name
    }
    
    func getVideoFileName() -> String {
        let timeStamp = Date().ls_milliStamp
        let name = "\(OBJECT_KEY_TYPE.video)/\(timeStamp)"
        return name
    }
    
    func getAvatarImageFileName(_ suffix:String, sha1Str:String)->String{
        let name = "\(OBJECT_KEY_TYPE.portrait)/\(sha1Str.prefix(2))/\(sha1Str)\(suffix)"
        return name
    }
    
    func getFileSuffix(_ path:String) -> String {
        let arr = path.components(separatedBy: ".")
        if arr.count >= 2 {
            return ".\(arr.last ?? "")"
        } else {
            return ""
        }
    }
    
    func getFileName(_ type: OBJECT_KEY_TYPE, sha1Str:String, suffix:String)->String{
        let timeStamp = Date().ls_milliStamp
        let name = "\(type)/\(sha1Str.prefix(2))/\(sha1Str)\(suffix)"
        return name
    }
}

extension OSSManager {
    
    func updateClient(){
        
        guard let oss = ossInfo else {
            return
        }
        LSLog("updateClient oss:\(oss)")
        let credentialsProvider = OSSAuthCredentialProvider(authServerUrl: "https://api.juzitang.net/party/open/get_oss_sts_token")
        client = OSSClient(endpoint: oss.endPoint, credentialProvider: credentialsProvider)
    }
}

extension OSSManager {
    func loadOssInfo() {
        NetworkManager.shared.getOssInfo {(resp) in
            if resp.status == .success {
                self.ossInfo = resp.data
                self.updateClient()
            }
        }
    }
    
    func ossInfoCanUse(_ result:@escaping(Bool)->()){
        if ossInfo != nil && ((ossInfo?.bucketName) != nil) {
            result(true)
        } else {
            // 没有oss信息或是token过期的时候重新加载oss信息
            NetworkManager.shared.getOssInfo {(resp) in
                if resp.status == .success {
                    self.ossInfo = resp.data
                    self.updateClient()
                    result(true)
                }else{
                    result(false)
                }
            }
        }
    }
    
}


enum OSSResultStatus: Int {
    case success = 0
    case failed = -1
}

struct OSSUploadResult {
    
    var status:OSSResultStatus = .success
    
    var objectKey = ""
    
    var baseUrl = ""
    
    var fullUrl = ""
    
    init() {}
}
