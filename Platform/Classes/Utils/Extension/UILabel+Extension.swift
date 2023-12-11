//
//  UILabel+Extension.swift
//  PadSole
//
//  Created by apple on 2019/4/11.
//  Copyright © 2019 Lee. All rights reserved.
//

import UIKit
extension UILabel {
    func ls_set(_ textColor: UIColor, _ textFont: UIFont ,_ textAligent: NSTextAlignment = .left) {
        self.textAlignment = textAligent
        self.textColor = textColor
        self.font = textFont
    }
    
    func ls_shadow(_ text: String) {
        self.clipsToBounds = false
        self.backgroundColor = .Color_Black_333333
//        // 设置阴影
//        let shadow = NSShadow()
//        shadow.shadowBlurRadius = 3;
//        shadow.shadowColor = UIColor.red
//        shadow.shadowOffset = CGSize(width: 2, height: 2)
//        
//        self.attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.shadow: shadow])
        
        self.layer.shadowColor = UIColor.red.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2
    }
}
