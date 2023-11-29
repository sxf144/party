//
//  NetworkManager.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import Alamofire

enum GrantType: String {
    case authorizationCode = "authorization_code"
    case refreshToken = "refresh_token"
}

class NetworkManager: NSObject {

    static let shared = NetworkManager()
    
    private override init() {
        super.init()
    }
    
    
    /// 获取验证码
    func getVerifyCode(_ mobile: String,_ response: @escaping((RespModel) -> ()) ){
        let para:[String:Any] = ["mobile": mobile]
        Network.shared.httpGetRequest(path: "/open/send_sms_verify_code", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 授权登录
    func authorize(_ mobile: String, smsCode: String, code: String, grantType: String, source: String, refreshToken: String, identityToken: String,_ response: @escaping((MobileLoginResp) -> ()) ){
        var para:[String:Any] = ["grant_type": grantType]
        if grantType.isEqual(GrantType.authorizationCode.rawValue) {
            para["source"] = source
            if source.isEqual("wx") {
                para["code"] = code
            } else if source.isEqual("mobile") {
                para["mobile"] = mobile
                para["sms_code"] = smsCode
            } else if source.isEqual("apple") {
                para["identity_token"] = identityToken
            }
        } else if grantType.isEqual(GrantType.refreshToken.rawValue) {
            para["refresh_token"] = refreshToken
        }
        Network.shared.httpGetRequest(path: "/open/auth/authorize", para: para) { (json) in
            let resp = MobileLoginResp(json)
            response(resp)
        }
    }
    
    /// 获取用户信息
    func login(_ response: @escaping((UserInfoResp) -> ()) ){
        Network.shared.httpGetRequest(path: "/user/login", para: nil) { (json) in
            let resp = UserInfoResp(json)
            response(resp)
        }
    }
    
    /// 编辑头像
    func editPortrait(_ portrait: String,_ response: @escaping((RespModel) -> ()) ){
        let para:[String:Any] = ["portrait": portrait]
        Network.shared.httpPostRequest(path: "/user/edit_portrait", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 编辑昵称
    func editNick(_ nick: String,_ response: @escaping((RespModel) -> ()) ){
        let para:[String:Any] = ["nick": nick]
        Network.shared.httpPostRequest(path: "/user/edit_nick", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 编辑性别
    func editSex(_ sex: Int64,_ response: @escaping((RespModel) -> ()) ){
        let para:[String:Any] = ["sex": sex]
        Network.shared.httpPostRequest(path: "/user/edit_sex", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 编辑个性签名
    func editIntro(_ intro: String,_ response: @escaping((RespModel) -> ()) ){
        let para:[String:Any] = ["intro": intro]
        Network.shared.httpPostRequest(path: "/user/edit_intro", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 获取用户个人主页
    func getUserPage(_ peopleId:String = "",_ response: @escaping((UserPageResp) -> ()) ){
        let para:[String:Any] = ["people_id": peopleId]
        Network.shared.httpGetRequest(path: "/user/home_page", para: para) { (json) in
            let resp = UserPageResp(json)
            response(resp)
        }
    }
    
    /// 首页推荐列表
    func recommend(_ cursor:String = "", cityCode:Int = 5101, pageSize:Int = 10 ,_ response: @escaping((RecommendResp) -> ()) ){
        var para:[String:Any] = ["page_size": pageSize]
        para["cursor_time"] = cursor
        para["city_code"] = cityCode
        Network.shared.httpPostRequest(path: "/play/recommend", para: para) { (json) in
            let resp = RecommendResp(json)
            response(resp)
        }
    }
    
    /// 首页关注列表
    func followed(_ pageSize:Int64 = 10 ,_ response: @escaping((RecommendResp) -> ()) ){
        let para:[String:Any] = ["page_size": pageSize]
        Network.shared.httpPostRequest(path: "/play/followed", para: para) { (json) in
            let resp = RecommendResp(json)
            response(resp)
        }
    }
    
    /// 获取关注列表
    func getFollowList(_ pageNum:Int64 = 1, pageSize:Int64 = 10, _ response: @escaping((FollowListResp) -> ()) ){
        var para:[String:Any] = ["page_num": pageNum]
        para["page_size"] = pageSize
        Network.shared.httpGetRequest(path: "/user/my_follow", para: para) { (json) in
            let resp = FollowListResp(json)
            response(resp)
        }
    }
    
    /// 添加关注
    func followPeople(_ peopleId:String = "", _ response: @escaping((RespModel) -> ()) ){
        let para:[String:Any] = ["people_id": peopleId]
        Network.shared.httpPostRequest(path: "/user/follow_people", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 取消关注
    func unfollowPeople(_ peopleId:String = "", _ response: @escaping((RespModel) -> ()) ){
        let para:[String:Any] = ["people_id": peopleId]
        Network.shared.httpPostRequest(path: "/user/unfollow_people", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 游戏列表
    func getGameList(_ pageNum:Int = 1, pageSize:Int = 10,_ response: @escaping((GameListResp) -> ()) ){
        var para:[String:Any] = ["page_num": pageNum]
        para["page_size"] = pageSize
        Network.shared.httpGetRequest(path: "/play/query_game_list", para: para) { (json) in
            let resp = GameListResp(json)
            response(resp)
        }
    }
    
    /// 创建桔
    func publishParty(_ para: [String:Any]? ,_ response: @escaping((PublishResp) -> ()) ){
        Network.shared.httpPostRequest(path: "/play/create_play", para: para) { (json) in
            let resp = PublishResp(json)
            response(resp)
        }
    }
    
    /// 解散桔
    func dismissParty(_ uniqueCode:String = "", _ response: @escaping((RespModel) -> ()) ){
        let para:[String:Any] = ["unique_code": uniqueCode]
        Network.shared.httpPostRequest(path: "/play/dismiss", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 预付款局订单
    func prePayJoinOrder(_ orderId:String = "", channel:Int64 = 1, _ response: @escaping((WxOrderResp) -> ()) ){
        var para:[String:Any] = ["order_id": orderId]
        para["channel"] = channel
        Network.shared.httpPostRequest(path: "/play/pre_pay_join_order", para: para) { (json) in
            let resp = WxOrderResp(json)
            response(resp)
        }
    }
    
    /// 获取订单支付结果
    func getOrderStatus(_ orderId:String = "", source:Int64 = 1, _ response: @escaping((OrderStatusResp) -> ()) ){
        var para:[String:Any] = ["order_id": orderId]
        para["source"] = source
        Network.shared.httpGetRequest(path: "/pay/get_order_status", para: para) { (json) in
            let resp = OrderStatusResp(json)
            response(resp)
        }
    }
    
    /// 查看局详情
    func getPartyDetail(_ uniqueCode:String = "",_ response: @escaping((PartyDetailResp) -> ()) ){
        let para:[String:Any] = ["unique_code": uniqueCode]
        Network.shared.httpGetRequest(path: "/play/query_play_detail", para: para) { (json) in
            let resp = PartyDetailResp(json)
            response(resp)
        }
    }
    
    /// 获取评论
    func getComments(_ pageNum:Int64 = 1, pageSize:Int64 = 10, uniqueCode:String = "", parentId:Int64 = 0,_ response: @escaping((CommentListResp) -> ()) ){
        var para:[String:Any] = ["page_num": pageNum]
        para["page_size"] = pageSize
        para["unique_code"] = uniqueCode
        para["parent_id"] = parentId
        Network.shared.httpGetRequest(path: "/play/get_comments", para: para) { (json) in
            let resp = CommentListResp(json)
            response(resp)
        }
    }
    
    /// 发评论
    func sendComment(_ uniqueCode:String = "", toCommentId:Int64 = 0, content:String = "",_ response: @escaping((CommentResp) -> ()) ){
        var para:[String:Any] = ["unique_code": uniqueCode]
        para["to_comment_id"] = toCommentId
        para["content"] = content
        Network.shared.httpPostRequest(path: "/play/comment", para: para) { (json) in
            let resp = CommentResp(json)
            response(resp)
        }
    }
    
    /// 获取参与人信息
    func getParticipateList(_ uniqueCode:String = "", _ response: @escaping((ParticipateResp) -> ()) ){
        let para:[String:Any] = ["unique_code": uniqueCode]
        Network.shared.httpGetRequest(path: "/play/get_participate_list", para: para) { (json) in
            let resp = ParticipateResp(json)
            response(resp)
        }
    }
    
    /// 邀请加入局
    func inviteJoinParty(_ uniqueCode:String = "", peopleIds:[String],_ response: @escaping((RespModel) -> ()) ){
        var para:[String:Any] = ["unique_code": uniqueCode]
        para["people_ids"] = peopleIds
        Network.shared.httpPostRequest(path: "/play/invite", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 加入局
    func joinParty(_ uniqueCode:String = "",_ response: @escaping((JoinResp) -> ()) ){
        let para:[String:Any] = ["unique_code": uniqueCode]
        Network.shared.httpPostRequest(path: "/play/join", para: para) { (json) in
            let resp = JoinResp(json)
            response(resp)
        }
    }
    
    /// 退出局
    func leaveParty(_ uniqueCode:String = "",_ response: @escaping((RespModel) -> ()) ){
        let para:[String:Any] = ["unique_code": uniqueCode]
        Network.shared.httpPostRequest(path: "/play/leave", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 我的局
    func getMyPlay(_ pageNum:Int64 = 1, pageSize:Int64 = 10, _ response: @escaping((MyPartyResp) -> ()) ){
        var para:[String:Any] = ["page_num": pageNum]
        para["page_size"] = pageSize
        Network.shared.httpGetRequest(path: "/play/my_play", para: para) { (json) in
            let resp = MyPartyResp(json)
            response(resp)
        }
    }
    
    /// 礼物列表
    func getGiftList(_ response: @escaping((GiftListResp) -> ()) ){
        Network.shared.httpGetRequest(path: "/play/gift/get_list", para: nil) { (json) in
            let resp = GiftListResp(json)
            response(resp)
        }
    }
    
    /// 发送礼物
    func sendGift(_ uniqueCode:String = "", peopleId:String = "", giftId:Int64 = 0, _ response: @escaping((GiftGiveResp) -> ()) ){
        var para:[String:Any] = ["people_id": peopleId]
        para["unique_code"] = uniqueCode
        para["gift_id"] = giftId
        Network.shared.httpPostRequest(path: "/play/gift/give", para: para) { (json) in
            let resp = GiftGiveResp(json)
            response(resp)
        }
    }
    
    /// 充值商品列表
    func getRechargeList(_ response: @escaping((RechargeListResp) -> ()) ){
        Network.shared.httpGetRequest(path: "/settings/coin/get_goods", para: nil) { (json) in
            let resp = RechargeListResp(json)
            response(resp)
        }
    }
    
    /// 获取游戏轮次卡牌列表
    func getGameRoundList(_ gameId:Int64 = 0, _ response: @escaping((GameRoundListResp) -> ()) ){
        let para:[String:Any] = ["game_id": gameId]
        Network.shared.httpGetRequest(path: "/play/query_game_round_list", para: para) { (json) in
            let resp = GameRoundListResp(json)
            response(resp)
        }
    }
    
    /// 开始游戏
    func startGame(_ uniqueCode:String = "", gameId:Int64 = 0, rounds:[[String: Any]] = [], teams:[[String: Any]] = [], _ response: @escaping((RespModel) -> ()) ){
        var para:[String:Any] = ["unique_code": uniqueCode]
        para["game_id"] = gameId
        para["rounds"] = rounds
        para["teams"] = teams
        Network.shared.httpPostRequest(path: "/play/start_game", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 发红包
    func sendRedPacket(_ taskId:Int64 = 0, uniqueCode:String = "", toUserId:String = "", count:Int64 = 0, amount:Int64 = 0, getType:Int64 = 1, _ response: @escaping((RespModel) -> ()) ){
        var para:[String:Any] = ["amount": amount]
        para["task_id"] = taskId
        para["unique_code"] = uniqueCode
        para["to_user_id"] = toUserId
        para["count"] = count
        para["amount"] = amount
        para["get_type"] = getType
        Network.shared.httpPostRequest(path: "/play/red_packet/give", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 领取红包
    func fetchRedPacket(_ id:Int64 = 0, _ response: @escaping((FetchRedPacketResp) -> ()) ){
        let para:[String:Any] = ["id": id]
        Network.shared.httpGetRequest(path: "/play/red_packet/fetch", para: para) { (json) in
            let resp = FetchRedPacketResp(json)
            response(resp)
        }
    }
    
    /// 查询红包
    func queryRedPacket(_ id:Int64 = 0, _ response: @escaping((QueryRedPacketResp) -> ()) ){
        let para:[String:Any] = ["id": id]
        Network.shared.httpGetRequest(path: "/play/red_packet/query", para: para) { (json) in
            let resp = QueryRedPacketResp(json)
            response(resp)
        }
    }
    
    /// 完成任务
    func doneTask(_ taskId:Int64 = 0, _ response: @escaping((RespModel) -> ()) ){
        let para:[String:Any] = ["task_id": taskId]
        Network.shared.httpPostRequest(path: "/play/finish_task", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 收支记录
    func getCoinLogs(_ pageNum:Int64 = 1, pageSize:Int64 = 10, month:String = "2023-01", _ response: @escaping((CoinListResp) -> ()) ){
        var para:[String:Any] = ["page_num": pageNum]
        para["page_size"] = pageSize
        para["month"] = month
        Network.shared.httpGetRequest(path: "/settings/get_coin_logs", para: para) { (json) in
            let resp = CoinListResp(json)
            response(resp)
        }
    }
    
    /// 礼物记录
    func getGiftLogs(_ pageNum:Int64 = 1, pageSize:Int64 = 10, month:String = "2023-01", _ response: @escaping((GiftLogResp) -> ()) ){
        var para:[String:Any] = ["page_num": pageNum]
        para["page_size"] = pageSize
        para["month"] = month
        Network.shared.httpGetRequest(path: "/settings/get_gift_logs", para: para) { (json) in
            let resp = GiftLogResp(json)
            response(resp)
        }
    }
    
    /// 绑定手机
    func bindMobile(_ mobile:String, code:String,_ response: @escaping((RespModel) -> ()) ){
        var para:[String:Any] = ["mobile": mobile]
        para["code"] = code
        Network.shared.httpPostRequest(path: "/settings/bind_mobile", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /// 绑定微信
    func bindWx(_ code:String,_ response: @escaping((RespModel) -> ()) ){
        let para:[String:Any] = ["code": code]
        Network.shared.httpPostRequest(path: "/settings/bind_wx", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    
    /**************************************************** 废弃接口 ****************************************************/
    /// QQ登录
    func loginWithQQ(_ token: String,openId: String?,nickName: String?,photo: String? ,gender: Int?,_ response:@escaping((QQLoginResp)->())){
        var para:[String:Any] = ["accessToken":token]
        if let openId = openId {
            para["openId"] = openId
        }
        para["nickName"] = nickName
        para["photo"] = photo
        para["gender"] = gender
        
        Network.shared.httpPostRequest(path: "/platform/qq/web/login", para: para) { (json) in
            let resp = QQLoginResp(json)
            response(resp)
        }
    }
    
    /// 登录用户的简略信息
    func getUserInfo(_ response:@escaping((UserInfoResp)->())){
        Network.shared.httpGetRequest(path: "/platform/user", para: nil) { (json) in
            let resp = UserInfoResp(json)
            response(resp)
        }
    }
    
    /// 查询指定用户的信息
    /// - Parameters:
    ///   - userId: 用户的uid
    func getUserInfo(userId: Int,_ response:@escaping((UserInfoResp)->())){
        let para = ["userId":userId]
        Network.shared.httpGetRequest(path: "/platform/user/\(userId)", para: para) { (json) in
            let resp = UserInfoResp(json)
            response(resp)
        }
    }
    
    /// 修改用户的信息
    /// - Parameters:
    ///   - userId: 用户的uid
    func modifyUserInfo(para: [String:Any]?,_ response:@escaping((RespModel)->())){
        Network.shared.httpPostRequest(path: "/platform/user", para: para) { (json) in
            let resp = RespModel(json)
            response(resp)
        }
    }
    /**************************************************** 废弃接口 ****************************************************/
}


//MARK: -公共资源、配置
extension NetworkManager{
    
    /// 获取阿里oss的Token
    func getOssInfo(_ response:@escaping((OSSResp)->())) {
        Network.shared.httpGetRequest(path: "/open/get_configs", para: nil) { (json) in
            LSLog("getOssInfo json:\(json)")
            let resp = OSSResp(json)
            response(resp)
        }
    }
}

fileprivate class RequestPath: NSObject {
    
}
