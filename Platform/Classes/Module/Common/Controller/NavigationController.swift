//
//  NavigationController.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = .white
//        self.modalPresentationStyle = .fullScreen
        // Do any additional setup after loading the view.'
        self.isNavigationBarHidden = true;
        self.interactivePopGestureRecognizer?.delegate = self;
        self.delegate = self;
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension NavigationController: UIGestureRecognizerDelegate,UINavigationControllerDelegate{
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        //设置侧滑返回是否可用
        if navigationController.viewControllers.count == 1 {
            //如果是 rootViewController 就关闭手势响应
            self.interactivePopGestureRecognizer?.isEnabled = false
        }else{
            if viewController.isKind(of: BaseController.self){
                let vc:BaseController = viewController as! BaseController
                self.interactivePopGestureRecognizer?.isEnabled = vc.slideBackEnabled
            }else{
                self.interactivePopGestureRecognizer?.isEnabled = true
            }
        }
        
    }
    
    
}
