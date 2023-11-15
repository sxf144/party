//
//  UIFont+Extension.swift
//  ActiveProject
//
//  Created by Lee on 2018/8/14.
//  Copyright © 2018年 7moor. All rights reserved.
//

import UIKit

extension UIFont {
    /// 常规体（Regular）
    ///
    /// - Parameter size: 字体大小
    class func ls_font(_ size:CGFloat) -> UIFont {
        return UIFont.init(name: "PingFangSC-Regular", size: size) ?? UIFont.systemFont(ofSize:size)
    }
    
    /// Medium（Medium）
    ///
    /// - Parameter size: 字体大小
    class func ls_mediumFont(_ size:CGFloat) -> UIFont {
        return UIFont.init(name: "PingFangSC-Medium", size: size) ?? UIFont.boldSystemFont(ofSize:size)
    }
    
    /// Semibold（PingFangSC-Semibold）
    ///
    /// - Parameter size: 字体大小
    class func ls_boldFont(_ size:CGFloat) -> UIFont {
        return UIFont.init(name: "PingFangSC-Semibold", size: size) ?? UIFont.boldSystemFont(ofSize:size)
    }
    
//    /// 思源宋体
//    ///
//    /// - Parameter size: 字体大小
//    class func ls_fontSong(_ size:CGFloat) -> UIFont {
//        return UIFont.init(name: "Source Han Serif TC", size: size) ?? UIFont.boldSystemFont(ofSize:size)
//    }
    
}
