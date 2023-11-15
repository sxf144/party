//
//  BaseController.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//
/*
 *  在特定控制器修改导航栏颜色以后，在离开页面的时候，要将导航栏颜色还原
 */

import UIKit
import SnapKit
import ImSDK_Plus_Swift

class BaseController: UIViewController {

    var showNavifationBar = true
    /// 侧滑返回是否可用，默认true
    var slideBackEnabled = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navigationView)
        view.backgroundColor = UIColor.ls_color("#FFFFFF")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.bringSubviewToFront(navigationView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func back(){
        pop()
    }

    func pushTo(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
    
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentVC(_ vc: UIViewController){
        self.present(vc, animated: true, completion: nil)
    }
    
    func presentVC(_ vc: UIViewController,style:UIModalPresentationStyle){
        vc.modalPresentationStyle = style
        self.present(vc, animated: true, completion: nil)
    }
    
    func pop(){
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        LSLog("释放了\(self)")
    }
    
    /// 标题栏
    lazy var navigationView: NavigationView = {
        let view = NavigationView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kNavBarHeight))
        view.titleLabel.text = title
        view.leftButton.addTarget(self, action: #selector(leftAction), for: .touchUpInside)
        view.rightButton.addTarget(self, action: #selector(rightAction), for: .touchUpInside)
        view.isHidden = !showNavifationBar
        return view
    }()

}

extension BaseController: UINavigationControllerDelegate {
    
    // UINavigationControllerDelegate方法，用于返回自定义的转场动画类
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            return SlideDownTransitionAnimator()
        }
        return nil
    }

    /// 左边返回按钮点击事件
    @objc func leftAction(){
        pop()
    }

    /// 导航栏右边按钮点击事件
    @objc func rightAction(){
        
    }
}

fileprivate extension BaseController{
    func navBarShadowImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: kScreenW, height: 0.5), false, 0)
        let path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: kScreenW, height: 0.5))
        UIColor.clear.setFill()
        path.fill()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsPopContext()
        return img
    }
    
}
