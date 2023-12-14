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
    
    func ls_shadow() {
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2
        self.layer.masksToBounds = false
    }
}
