//
//  PageManager.swift
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class PageManager: NSObject {
    
    static let shared = PageManager()
    
    private override init() {
        super.init()
    }
    
    func currentNav() ->UINavigationController? {
        return UIViewController.current()?.navigationController
    }
    
    func currentVC() ->UIViewController? {
        return UIViewController.current()
    }
    
//    /// 登录
//    func presentLoginVC() {
//        let vc = LoginController()
//        let nav = NavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        currentVC()?.present(nav, animated: true, completion: nil)
//    }
//
    /// 手机号登录
    func pushToPhoneLogin() {
        let vc = PhoneLoginController()
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 完善资料
    func pushToSupplyUser() {
        let vc = SupplyUserController()
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 组个局
    func pushToPublishParty() {
        let vc = PublishPartyController()
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 游戏列表
    func pushToGameList() {
        let vc = GameListController()
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 发布成功
    func pushToPublishSucc(_ uniqueCode:String, startTime:String, endTime:String) {
        let vc = PublishSuccController()
        vc.hidesBottomBarWhenPushed = true
        vc.setData(startTime: startTime, endTime: endTime, uniqueCode: uniqueCode)
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 局详情
    func pushToPartyDetail(_ uniqueCode:String) {
        let vc = PartyDetailController()
        vc.hidesBottomBarWhenPushed = true
        vc.setData(uniqueCode: uniqueCode)
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 关注列表
    func pushToFollowList(_ uniqueCode:String) {
        let vc = FollowListController()
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 个人主页
    func pushToUserPage(_ userId:String) {
        let vc = UserPageController()
        vc.hidesBottomBarWhenPushed = true
        vc.setData(userId: userId)
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 地图Controller
    func moveInMapSearch(){
        let vc = MapSearchController()
        vc.hidesBottomBarWhenPushed = true

        let transition = CATransition()
        transition.duration = 0.5 // 设置动画持续时间
        transition.type = .moveIn // 设置动画类型为
        transition.subtype = .fromTop // 设置动画子类型为从顶部向下
        transition.timingFunction = CAMediaTimingFunction(name: .easeOut) // 设置动画时间函数

        // 添加动画到导航栏的图层上
        currentNav()?.view.layer.add(transition, forKey: kCATransition)

        // 推送新视图控制器
        currentNav()?.pushViewController(vc, animated: false)
    }
    
    /// 聊天页
    func pushToChatController(_ conv:LIMConversation) {
        let vc = ChatController()
        vc.hidesBottomBarWhenPushed = true
        vc.setData(conv: conv)
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 打开网页
    func presentWebViewController(_ uri:String) {
        let vc = WebViewController()
        vc.setUri(uri)
        vc.hidesBottomBarWhenPushed = true
        currentVC()?.present(vc, animated: true, completion: nil)
    }
    
    /// 游戏轮次卡牌列表
    func presentGameRoundListController(_ gameItem:GameItem) {
        let vc = GameRoundListController()
        vc.setData(gameItem)
        vc.hidesBottomBarWhenPushed = true
        currentVC()?.present(vc, animated: true, completion: nil)
    }
    
    /// 聊天页
    func pushToSortUserController(_ uniCode:String, gameItem:GameItem, rounds:[[String:Any]]) {
        let vc = SortUserController()
        vc.setData(uniCode, gameItem: gameItem, rounds: rounds)
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 发红包
    func pushToSendRedPacketController(_ uniCode:String, personCount:Int, userId:String, taskId:Int64) {
        let vc = SendRedPacketController()
        vc.setData(uniCode, personCount: personCount, userId: userId, taskId: taskId)
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 我的钱包
    func pushToMyBagController(_ userPageData:UserPageModel) {
        let vc = MyBagController()
        vc.setData(userPageData)
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 编辑资料
    func pushToEditUserController() {
        let vc = EditUserController()
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 收支记录
    func pushToCoinLogController() {
        let vc = CoinLogController()
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 礼物记录
    func pushToGiftLogController() {
        let vc = GiftLogController()
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 设置
    func pushToSettingController() {
        let vc = SettingController()
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    /// 账号管理
    func pushToAccountManagerController() {
        let vc = AccountManagerController()
        vc.hidesBottomBarWhenPushed = true
        currentNav()?.pushViewController(vc, animated: true)
    }
    
    
//
//    /// 设置
//    func pushToSettingVC(){
//        let vc = SettingController()
//        currentNav()?.pushViewController(vc, animated: true)
//    }
//
//    /// 编辑用户资料
//    func pushToEditUserInfoVC(){
//        let vc = EditUserInfoController()
//        currentNav()?.pushViewController(vc, animated: true)
//    }
    
    
}

//MARK -会员相关
extension PageManager{
    
    /// 会员页面
//    func pushToVipInfoVC(){
//        let vc = VipInfoController()
//        currentNav()?.pushViewController(vc, animated: true)
//    }
//    
//    /// 会员充值页面
//    func pushToVipRechargeVC(){
//        let vc = RechargeController()
//        currentNav()?.pushViewController(vc, animated: true)
//    }
//
//    /// 时运势信息输入
//    func presentHourFortuneInputVC(){
//        let vc = HourFortuneInputController()
//        currentVC()?.present(vc, animated: true, completion: nil)
//    }
//    
//    /// 二选一
//    func pushToChooseOne(){
//        let vc = ChooseOneController()
//        currentNav()?.pushViewController(vc, animated: true)
//    }
}
