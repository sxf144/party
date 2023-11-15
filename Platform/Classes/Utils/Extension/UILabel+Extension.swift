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
}
