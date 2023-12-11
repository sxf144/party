//
//  Date+Extension.swift
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

/// 一天的秒数
let DAY_SECOND = 60*60*24
/// 一天的毫秒数
let DAY_MILLION_SECOND = 1000*60*60*24

extension Date {
   /// 获取当前 秒级 时间戳 - 10位
    var ls_timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }

    /// 获取当前 毫秒级 时间戳 - 13位
    var ls_milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    
    /// 日期格式化字符串
    /// - Parameter format: "yyyy-MM-dd HH:mm:ss"
    func ls_formatterStr(_ format:String="yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateStr = dateFormatter.string(from: self)
        return dateStr
    }
    
    /// 时间戳转换时间字符串简单方法
    /// - Parameters:
    ///   - timeInterval: 时间戳 精确到秒
    ///   - format: "yyyy-MM-dd HH:mm:ss"
    static func ls_intervalToDateStr(_ timeInterval:TimeInterval,format:String = "yyyy-MM-dd") -> String {
        let date:Date =  Date(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter.init()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    /// 公历转农历
    func ls_lunarDateStr(_ style:DateFormatter.Style = .full) -> String{
//        //设置公历日历，默认的是0时区
//        let gregorian = Calendar(identifier: .gregorian)
//        //当前时间
//        //let date = Date()
//        // 设置为8时区
//        var components = DateComponents()
//        components.hour = 8
//
//        //增加一个DateComponents 返回新的日期
//        let solarDate = gregorian.date(byAdding: components, to: self)

        //设置农历日历
        let chinese = Calendar(identifier: .chinese)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.calendar = chinese
        //日期样式
        formatter.dateStyle = style
        //公历转为农历
//        let lunar = formatter.string(from: solarDate!)
        let lunar = formatter.string(from: self)
        return lunar
    }
    
    /// 是否是今天
    var ls_isToday : Bool {
        return Calendar.current.isDateInToday(self)
    }

    /// 是否是昨天
    var ls_isYesterday : Bool {
        return Calendar.current.isDateInYesterday(self)
    }

    /// 是否是今年
    var ls_isYear: Bool {
        let nowComponent = Calendar.current.dateComponents([.year], from: Date())
        let component = Calendar.current.dateComponents([.year], from: self)
        return (nowComponent.year == component.year)
    }
    
    /// 日期格式化字符串
    func ls_formatStr() -> String {
        var str = ""
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        let interval = now - timeInterval
        if (interval < (60 * 60)) {
            // 向下取整，最小1、最大59
            var roundedDown = floor(interval/60)
            if (roundedDown == 0) {
                roundedDown = 1
            }
            str = "\(Int(roundedDown))分钟前"
        } else if (interval >= (60 * 60) && interval < (24 * 60 * 60)) {
            // 向下取整，最小1、最大23
            let roundedDown = floor(interval/(60 * 60))
            str = "\(Int(roundedDown))小时前"
        } else if (interval >= (24 * 60 * 60) && interval < (4 * 24 * 60 * 60)) {
            // 向下取整，最小1、最大3
            let roundedDown = floor(interval/(24 * 60 * 60))
            str = "\(Int(roundedDown))天前"
        } else {
            // 按时间格式输出
            let formatter = DateFormatter.init()
            formatter.dateFormat = "MM-dd HH:mm"
            str = formatter.string(from: self)
        }
        
        return str
    }
    
    /// 日期格式化字符串
    static func formatStr(_ timeInterval:TimeInterval) -> String {
        var str = ""
        if timeInterval > 0 {
            let now = Date().timeIntervalSince1970
            let interval = now - timeInterval
            if (interval < (60 * 60)) {
                // 向下取整，最小1、最大59
                var roundedDown = floor(interval/60)
                if (roundedDown == 0) {
                    roundedDown = 1
                }
                str = "\(Int(roundedDown))分钟前"
            } else if (interval >= (60 * 60) && interval < (24 * 60 * 60)) {
                // 向下取整，最小1、最大23
                let roundedDown = floor(interval/(60 * 60))
                str = "\(Int(roundedDown))小时前"
            } else if (interval >= (24 * 60 * 60) && interval < (4 * 24 * 60 * 60)) {
                // 向下取整，最小1、最大3
                let roundedDown = floor(interval/(24 * 60 * 60))
                str = "\(Int(roundedDown))天前"
            } else {
                // 按时间格式输出
                let date:Date =  Date(timeIntervalSince1970: timeInterval)
                let formatter = DateFormatter.init()
                formatter.dateFormat = "MM-dd HH:mm"
                str = formatter.string(from: date)
            }
        }
        
        return str
    }
    
    /// 日期格式化字符串
    func ls_formatSysStr() -> String {
        var str = ""
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        let interval = now - timeInterval
        let formatter = DateFormatter.init()
        if (interval < (24 * 60 * 60)) {
            // 按时间格式输出
            formatter.dateFormat = "HH:mm"
            str = formatter.string(from: self)
        } else {
            // 按时间格式输出
            formatter.dateFormat = "MM-dd HH:mm"
            str = formatter.string(from: self)
        }
        
        return str
    }
    
    static func formatDate(startTime: String?, endTime: String?) -> String {
        
        guard let startTime = startTime, !startTime.isEmpty else {
            return ""
        }
        
        // 时间
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // 使用 DateFormatter 将输入字符串转换为日期对象
        var outputDateString1 = ""
        var outputDateString2 = ""
        var outputDateString3 = ""
        
        if let inputDate1 = inputDateFormatter.date(from: startTime ) {
            let outputDateFormatter1 = DateFormatter()
            outputDateFormatter1.dateFormat = "MM-dd(E)"
            // 使用输出的 DateFormatter 格式化日期对象
            outputDateString1 = outputDateFormatter1.string(from: inputDate1)
            let outputDateFormatter2 = DateFormatter()
            outputDateFormatter2.dateFormat = "HH:mm"
            // 使用输出的 DateFormatter 格式化日期对象
            outputDateString2 = outputDateFormatter2.string(from: inputDate1)
            
            if let endTime = endTime, let inputDate2 = inputDateFormatter.date(from: endTime ) {
                // 创建另一个 DateFormatter 对象，用于将日期对象格式化为其他格式
                let outputDateFormatter = DateFormatter()
                outputDateFormatter.dateFormat = "HH:mm"
                
                // 使用输出的 DateFormatter 格式化日期对象
                outputDateString3 = outputDateFormatter.string(from: inputDate2)
                
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour], from: inputDate1, to: inputDate2)
                
                if let hours = components.hour {
                    outputDateString3 = "(\(hours)h)"
                } else {
                    outputDateString3 = ""
                }
                
            } else {
                outputDateString3 = ""
            }
            
        } else {
            outputDateString1 = ""
            outputDateString2 = ""
            outputDateString3 = ""
        }
        
        var finalDateStr = ""
        if !outputDateString1.isEmpty {
            if outputDateString3.isEmpty {
                finalDateStr = outputDateString1 + " " + outputDateString2
            } else {
                finalDateStr = outputDateString1 + " " + outputDateString2 + " " + outputDateString3
            }
        }
        
        return finalDateStr
    }
}
