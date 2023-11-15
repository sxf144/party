//
//  UIView+Extension.swift
//  ActiveProject
//
//  Created by Lee on 2018/8/14.
//  Copyright © 2018年 7moor. All rights reserved.
//

import UIKit

extension UIView {

    func ls_border(color: UIColor,width: CGFloat = 0.5){
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func ls_cornerRadius(_ corner: CGFloat){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = corner
    }
    
    /// 添加指定角的圆角，添加前要先设置frame
    ///
    /// - Parameters:
    ///   - roundingCorners: let corner:UIRectCorner = [.topLeft,.topRight]
    ///   - cornerRadius: 圆角弧度
    func ls_addCorner(_ roundingCorners: UIRectCorner, cornerRadius: CGFloat) {
        let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerSize)
        let cornerLayer = CAShapeLayer()
        cornerLayer.frame = bounds
        cornerLayer.path = path.cgPath
        layer.mask = cornerLayer
    }
    
//    @discardableResult
//    func setGradient(colors: [UIColor], startPoint: CGPoint ,endPoint: CGPoint) -> CAGradientLayer {
//        func setGradient(_ layer: CAGradientLayer) {
//            self.layoutIfNeeded()
//            var colorArr = [CGColor]()
//            for color in colors {
//                colorArr.append(color.cgColor)
//            }
//            CATransaction.begin()
//            CATransaction.setDisableActions(true)
//            layer.frame = self.bounds
//            CATransaction.commit()
//
//            layer.colors = colorArr
//            layer.startPoint = startPoint
//            layer.endPoint = endPoint
//        }
//        var gradientLayerStr = "gradientLayerStr"
//        if let gradientLayer = objc_getAssociatedObject(self, &gradientLayerStr) as? CAGradientLayer {
//            setGradient(gradientLayer)
//            return gradientLayer
//        }else {
//            let gradientLayer = CAGradientLayer()
//            self.layer.insertSublayer(gradientLayer , at: 0)
//            setGradient(gradientLayer)
//            objc_setAssociatedObject(self, &gradientLayerStr, gradientLayer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            return gradientLayer
//        }
//    }

    /// 渐变色背景,从左往右
    /// - Parameters:
    ///   - begin: 开始颜色
    ///   - end: 结束颜色
    @discardableResult
    func ls_addColorLayer(_ begin:UIColor,_ end:UIColor,cornerRadius:CGFloat = 0) -> CAGradientLayer{
        let bgLayer = CAGradientLayer()
        bgLayer.colors = [begin.cgColor, end.cgColor]
        bgLayer.locations = [0, 1]
        bgLayer.frame = self.bounds
        bgLayer.startPoint = CGPoint(x: 0.97, y: 0.58)
        bgLayer.endPoint = CGPoint(x: 0.28, y: 0.28)
        bgLayer.cornerRadius = cornerRadius
        self.layer.insertSublayer(bgLayer, at: 0)
        return bgLayer
    }
    
    /// 渐变色背景,从上往下
    /// - Parameters:
    ///   - begin: 开始颜色
    ///   - end: 结束颜色
    func ls_addVerticalLayer(_ begin:UIColor,_ end:UIColor,cornerRadius:CGFloat = 0){
        let bgLayer = CAGradientLayer()
        bgLayer.colors = [begin.cgColor, end.cgColor]
        bgLayer.locations = [0, 1]
        bgLayer.frame = self.bounds
        bgLayer.startPoint = CGPoint(x: 0.45, y: 0)
        bgLayer.endPoint = CGPoint(x: 0.93, y: 0.93)
        self.layer.insertSublayer(bgLayer, at: 0)
    }
    
}
