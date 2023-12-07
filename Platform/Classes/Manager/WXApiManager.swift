//
//  WXApiManager.swift
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class WXApiManager: NSObject {
    
    static let shared = WXApiManager()
    public var payBlock: ((_ orderId:String, _ status:Int64) -> ())?
    /// 微信appid
    let WX_APPID = "wx4b6080cc0837f2ec"
    let WX_UNIVERSAL_LINK = "https://static.juzitang.net/app/"
    var currOrderId: String = ""
    
    private override init() {
        super.init()
    }
}

extension WXApiManager {
    
    func registerApp() -> Bool {
        return WXApi.registerApp(WX_APPID, universalLink: WX_UNIVERSAL_LINK)
    }
    
    func sendAuthRequest() {
        //构造SendAuthReq结构体
        let req: SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "auth"
        //第三方向微信终端发送一个SendAuthReq消息结构
        WXApi.send(req)
    }
    
    func sendBindRequest() {
        //构造SendAuthReq结构体
        let req: SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "bind"
        //第三方向微信终端发送一个SendAuthReq消息结构
        WXApi.send(req)
    }
    
    func sendPayRequest(_ wxOrder: WxOrderModel, orderId:String) {
        currOrderId = orderId
        let req: PayReq = PayReq()
        req.partnerId = wxOrder.partnerid
        req.prepayId = wxOrder.prepayid
        req.package = wxOrder.package
        req.nonceStr = wxOrder.noncestr
        req.timeStamp = UInt32(wxOrder.timestamp) ?? 0
        req.sign = wxOrder.sign
        WXApi.send(req)
    }
    
    func checkOrderStatus() {
        if !currOrderId.isEmpty {
            LSHUD.showLoading("查询订单状态")
            // 查询订单状态
            NetworkManager.shared.getOrderStatus(currOrderId) { (resp) in
                LSHUD.hide()
                if resp.status == .success {
                    //
                    if let payBlock = self.payBlock {
                        payBlock(self.currOrderId, resp.data?.state ?? 0)
                    }
                } else {
                    //错误提示
                    LSHUD.showError(resp.msg)
                }
            }
        }
    }
    
    func shareToWX(_ title:String, description:String, pageUrl:String, image:UIImage?) {
        let webpageObject = WXWebpageObject()
        webpageObject.webpageUrl = pageUrl
        let message = WXMediaMessage()
        message.title = title
        message.description = description
        if let image = image {
            let thumbImage = resizeImage(image: image, targetSize: CGSize(width: 100, height: 100))
            message.setThumbImage(thumbImage)
        }
        message.mediaObject = webpageObject
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        WXApi.send(req)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        // 计算调整比例
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // 选择更大的比例，确保图片完全填充目标尺寸
        let scaleFactor = max(widthRatio, heightRatio)

        // 计算调整后的大小
        let scaledWidth = size.width * scaleFactor
        let scaledHeight = size.height * scaleFactor

        // 计算裁剪的位置，使图片居中
        let x = (targetSize.width - scaledWidth) / 2.0
        let y = (targetSize.height - scaledHeight) / 2.0

        // 设置调整后的图片上下文
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        let rect = CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? UIImage()
    }
}

extension WXApiManager: WXApiDelegate {
   
    func onResp(_ resp: BaseResp) {
        LSLog("WXApiManager onResp:\(resp)")
        // SendAuthResp授权登录
        if let authResp = resp as? SendAuthResp {
            // 处理微信登录授权结果
            if authResp.errCode == WXSuccess.rawValue {
                LSLog("authResp succ")
                if authResp.state == "auth" {
                    LSLog("authResp succ auth")
                    /**
                     * 用户同意授权，获取code
                     * 登录授权返回，向自己服务器继续发起登录
                     */
                    if let code = authResp.code {
                        let grantType = GrantType.authorizationCode.rawValue
                        let source = "wx"
                        LSHUD.showLoading("登录中")
                        //发起授权登录
                        NetworkManager.shared.authorize("", smsCode: "", code: code, grantType: grantType, source: source, refreshToken: "", identityToken: "") { (resp) in
                            LSHUD.hide()
                            if resp.status == .success {
                                // 保存token
                                LoginManager.shared.saveUserToken(resp.data)
                                LSLog("authorize data:\(resp.data)")
                                LoginManager.shared.login()
                            } else {
                                //错误提示
                                LSHUD.showError(resp.msg)
                            }
                        }
                    }
                } else if authResp.state == "bind" {
                    LSLog("authResp succ bind")
                    /**
                     * 用户同意授权，获取code
                     * 绑定微信授权返回，向自己服务器继续发起绑定请求
                     */
                    if let code = authResp.code {
                        NetworkManager.shared.bindWx(code) { (resp) in
                            if resp.status == .success {
                                // 绑定成功
                                LSHUD.showInfo("绑定成功")
                                // 发送账号绑定成功通知
                                LSNotification.postAccountBindStatusChange()
                            } else {
                                //错误提示
                                LSHUD.showError(resp.msg)
                            }
                        }
                    }
                }
            } else {
                // 用户取消授权或授权失败
                // TODO: 处理取消授权或失败的情况
                LSHUD.showError(authResp.errStr)
            }
        } else if let payResp = resp as? PayResp {
            // PayResp 支付回调
            LSLog("WXApiManager payResp returnKey:\(payResp.returnKey)")
            if payResp.errCode == WXSuccess.rawValue {
                // 去查询订单成功与否
                checkOrderStatus()
            } else if payResp.errCode == WXErrCodeUserCancel.rawValue {
                // 支付失败，用户取消，不做处理
            } else {
                // 支付失败，提示错误
                LSHUD.showError(payResp.errStr)
            }
        } else if let msgResp = resp as? SendMessageToWXResp {
            // SendMessageToWXResp 分享回调
            if msgResp.errCode == WXSuccess.rawValue {
                LSLog("WXApiManager sendMessage succ")
            } else {
                LSLog("WXApiManager sendMessage fail:\(msgResp.errStr)")
                // 分享失败，提示错误
//                LSHUD.showError(msgResp.errStr)
            }
        }
    }
}
