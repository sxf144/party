//
//  UIImage+Extension.swift
//  ActiveProject
//
//  Created by Lee on 2018/8/17.
//  Copyright © 2018年 7moor. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 绘制纯色图片
    class func ls_image(_ color: UIColor, viewSize: CGSize = CGSize(width: 10, height: 10)) -> UIImage{
        let rect: CGRect = CGRect(x: 0, y: 0, width: viewSize.width, height: viewSize.height)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsGetCurrentContext()
        return image!
    }
    
    // 函数用于将UIImage转换为灰度图
    static func convertToGrayScale(_ image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // 创建一个位图上下文
        let context = CGContext(data: nil, width: width, height: height,
                                bitsPerComponent: 8, bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceGray(),
                                bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        // 在位图上下文中绘制原始图像，以转换为灰度
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 从位图上下文获取灰度图像
        if let grayImage = context?.makeImage() {
            return UIImage(cgImage: grayImage)
        }
        
        return nil
    }
}
