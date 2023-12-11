//
//  UITableView+Extension.swift
//  ActiveProject
//
//  Created by Lee on 2018/8/14.
//  Copyright © 2018年 7moor. All rights reserved.
//

import UIKit

extension UITableView {
    
    /// 设置无数据
    func ls_setEmpty(_ bgColor: UIColor = .white) {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_empty")
        self.backgroundView?.addSubview(imageView)
    }
    
    func ls_showEmpty() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        let imageWidth = 375
        let imageHeight = 254
        let imageView = UIImageView(frame: CGRect(x: (Int(self.frame.width) - imageWidth)/2, y: (Int(self.frame.height) - imageHeight)/2 - 100, width: imageWidth, height: imageHeight))
        imageView.image = UIImage(named: "icon_empty")
        view.addSubview(imageView)
        
        self.backgroundView = view
    }
    
    func ls_hideEmpty() {
        self.backgroundView = nil
    }
}
