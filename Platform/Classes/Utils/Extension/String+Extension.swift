//
//  String+Extension.swift
//  ActiveProject
//
//  Created by Lee on 2018/8/10.
//  Copyright © 2018年 7moor. All rights reserved.
//

import UIKit
import CommonCrypto

extension String {
    /// 将字符串md5处理
    var ls_md5 : String{
        let strEncoding = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        guard let str = strEncoding else {
            assert(strEncoding != nil, "字符串md5过程出现为空现象")
            return self
        }
        CC_MD5(str, strLen, result)

        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        //result.deinitialize() //这个方法过期了，从网上找的新方法free(result)
        free(result)
        return String(format: hash as String)
    }
    
    func ls_urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }

    /// 根据字符获取宽度
    func ls_width(_ font: UIFont, maxHeight: CGFloat, maxWidth: CGFloat = kScreenW) -> CGFloat {
        let tempStr = self as NSString
        return tempStr.boundingRect(with: CGSize.init(width: maxWidth, height: maxHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).size.width
    }
    
    /// 根据字符获取高度
    func ls_height(_ font: UIFont, maxWith: CGFloat) -> CGFloat {
        let tempStr = self as NSString
        return tempStr.boundingRect(with: CGSize.init(width: maxWith, height: 10000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).size.height
    }
    
//    /// 根据字符获取高度
//    func height(_ font: UIFont, maxWidth: CGFloat = kkScreenWidth) ->CGFloat {
//        let size = CGSize(width: maxWidth, height: 0)
//        let attribute = [NSAttributedStringKey.font: font]
//        let option: NSStringDrawingOptions = .usesLineFragmentOrigin
//        let strRect = (self as NSString).boundingRect(with: size, options: option, attributes: attribute, context: nil)
//        return strRect.height
//    }
    
    /// 随机字符串
    static func ls_randomStr(len : Int) -> String{
        let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ开发好风景啊就分开了发号施令是开挂了第九十六回事记得给老公链家时光，。！；辣椒不撒娇啊飞就到了发福利"
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
    
    ///移动手机号判断
    func ls_isMobile()-> Bool {
        
        // 手机号以 13 14 15 18 开头   八个 \d 数字字符
        
        let phoneRegex = "^((13[0-9])|(17[0-9])|(14[^4,\\D])|(15[^4,\\D])|(18[0-9]))\\d{8}$|^1(7[0-9])\\d{8}$"
        
        let phoneTest = NSPredicate(format: "SELF MATCHES %@" , phoneRegex)
        
        return (phoneTest.evaluate(with: self));
    }

    /// 计算字符串长度，中文只算两个字符，英文、数字算一个字符
    func ls_length()->Int{
        var length = 0
        for char in self {
         length += "\(char)".lengthOfBytes(using: String.Encoding.utf8) == 3 ? 2:1
        }
        return length
    }
     
     /// 裁剪到指定长度，字母长度为1，汉字为2
     func ls_reduceTo(_ length:Int) -> String{
        var strlength = 0
        var targetLength = 0
        for char in self.enumerated() {
         strlength += "\(char.element)".lengthOfBytes(using: String.Encoding.utf8) == 3 ? 2:1
         if strlength > length {
             break
         }
         targetLength = char.offset + 1
        }
        return String(self.prefix(targetLength))
     }
     
     
     /// 文本是否包含汉字
     func ls_hasChinese() -> Bool {
         
         for (_, value) in self.enumerated() {
             
             if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                 return true
             }
         }
         
         return false
     }
     
    /// 时间戳转换时间字符串
    /// - Parameters:
    ///   - format: "yyyy-MM-dd HH:mm:ss"
    func ls_intervaltoDateStr(format:String = "yyyy-MM-dd") -> String? {
        //如果服务端返回的时间戳精确到毫秒，需要除以1000,否则不需要
        guard let timeInterval = TimeInterval(self) else { return nil }
        let date:Date =  Date(timeIntervalSince1970: timeInterval/1000)
        let formatter = DateFormatter.init()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    /// 时间戳转换时间
    /// - Parameters:
    ///   - format: "yyyy-MM-dd HH:mm:ss"
    func ls_toDate(format:String = "yyyy-MM-dd") -> Date? {
        //如果服务端返回的时间戳精确到毫秒，需要除以1000,否则不需要
        guard let timeInterval = TimeInterval(self) else { return nil }
        let date:Date =  Date(timeIntervalSince1970: timeInterval/1000)
        return date
    }
    
    /// 去掉字符串中所有的空格
    var ls_removeAllSapce: String {
        return self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
    }
    
    /// 去掉首尾空格
    var ls_removeHeadAndTailSpace:String {
        let whitespace = NSCharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespace)
    }
    
    static func genImageName(_ uid:String) -> String? {
        var uuid = uid
        if(uuid.isEmpty){
            let value:Int = Int(arc4random() % 1000)
            let timestamp = Date().ls_timeStamp
            uuid = "\(timestamp)\(value)"
        }
        let name = "image_\(uuid)"
        return name;
    }
}
