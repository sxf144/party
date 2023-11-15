//
//  LoginTextFieldView.swift
//  constellation
//
//  Created by Lee on 2020/4/11.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class LoginTextFieldView: UIView,UITextFieldDelegate {

     let textField = UITextField()
       var limitCount = 4
       override init(frame: CGRect) {
           super.init(frame: frame)
           createUI()
       }
       
       private func createUI(){
           addSubview(textField)
           textField.keyboardType = .numberPad
           textField.borderStyle = .none
           textField.clearButtonMode = .always
           textField.font = kFontRegualer15
           textField.textColor = kColorTextBlack
           textField.delegate = self
           textField.snp.makeConstraints { (make) in
               make.left.equalTo(16)
               make.right.equalTo(0)
               make.centerY.equalToSuperview()
           }
           
           self.ls_cornerRadius(bounds.height/2)
           self.ls_border(color: kColorGray)
       }
       
       func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           guard let text = textField.text else {
               return true
           }
           let textLength = text.count + string.count - range.length
           return textLength <= limitCount
       }
       
       required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
}
