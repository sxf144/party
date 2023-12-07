//
//  THAgePickerView.swift
//  HealthCloud
//
//  Created by 李宝龙 on 16/9/6.
//  Copyright © 2016年 thealth. All rights reserved.
//

import UIKit

// 屏幕的宽
private let SCREEN_WIDTH:CGFloat = UIScreen.main.bounds.size.width
// 屏幕的高
private let SCREEN_HEIGHT:CGFloat = UIScreen.main.bounds.size.height
private let FONTSYS14 = UIFont.systemFont(ofSize: 14)       //H9：28px
// 工具栏高度
private let TOOL_HEIGHT: CGFloat = 40
// PickerView高度
private let PICKER_HEIGHT: CGFloat = SCREEN_HEIGHT/3
private let BOTTOM_HEIGHT: CGFloat = 34
// PickerView高度
private let CONTENT_HEIGHT: CGFloat = PICKER_HEIGHT + TOOL_HEIGHT*2 + BOTTOM_HEIGHT


class PickerView: UIView {
    
    /// 回调闭包
    fileprivate var btnCallBackBlock: ((_ date: Date, _ hourCnt: Int) -> ())?
    
    /// 遮幕
    fileprivate lazy var coverView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        view.alpha = 0.2
        view.backgroundColor = UIColor.darkGray
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(yesBtnDidClick))
        view.addGestureRecognizer(tapGes)
        return view
    }()
    
    /// 主体view
    fileprivate lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: CONTENT_HEIGHT))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()
    
    /// 工具栏
    fileprivate lazy var toolView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: TOOL_HEIGHT))
        setToolView(toolView: view)
        return view
    }()
    
    /// 时间pickerView
    fileprivate lazy var pickerView: UIPickerView = {
        let pickerview = UIPickerView(frame: CGRect(x: 0, y: toolView.frame.maxY, width: SCREEN_WIDTH, height: PICKER_HEIGHT))
        pickerview.delegate = self
        pickerview.dataSource = self
        return pickerview
    }()
    
    /// progress
    fileprivate lazy var timeSlider: UISlider = {
        let slider = UISlider(frame: CGRect(x: 20, y: pickerView.frame.maxY + 20, width: SCREEN_WIDTH - 40, height: TOOL_HEIGHT))
        // 设置UISlider的属性
        slider.minimumValue = 0 // 最小值
        slider.maximumValue = 10 // 最大值
        slider.value = Float(hourCnt ?? 0) // 当前值
        slider.isContinuous = true // 是否连续触发值变化事件
        
        // 添加值变化事件处理函数
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        // 设置UISlider的位置和尺寸
//        slider.frame = CGRect(x: 50, y: 100, width: 200, height: 20)
        return slider
    }()
    
    /// 日历
    fileprivate lazy var calendar: NSCalendar = {
        return NSCalendar(calendarIdentifier: NSCalendar.Identifier.chinese)!
    }()
    
    /// 最小日期
    fileprivate lazy var minDate = Date()
    /// 最大日期
    fileprivate lazy var maxDate = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate + 180*24*3600)
    /// 默认最早的日期
    fileprivate lazy var earliestPresentedDate: Date = {
        return self.showOnlyValidDates ? self.minDate : Date(timeIntervalSince1970: 0)
    }()
    /// 显示日期行数
    fileprivate var nDays:Int?
    /// 是否只显示有效日期
    fileprivate var showOnlyValidDates:Bool = true
    /// 保存最终返回的日期
    fileprivate var date:Date?
    /// 保存最终返回的时长
    fileprivate var hourCnt:Int? = 0
    /// 字体配色
    fileprivate var color:UIColor = UIColor.white
    fileprivate var bgColor:UIColor = UIColor.black
    
    /// 初始化
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - minDate: 最小时间
    ///   - maxDate: 最大时间
    ///   - showOnlyValidDates: 是否显示有效时间
    init(frame: CGRect,
         minDate: Date? = nil,
         maxDate: Date? = nil,
         selectDate: Date? = nil,
         showOnlyValidDates: Bool = true)
    {
        super.init(frame: frame)
        
        //设置最小的时间
        if minDate != nil{
            self.minDate = minDate!
        }
        //设置最大的时间
        if maxDate != nil{
            self.maxDate = maxDate!
        }
        //是否只显示有效日期
        self.showOnlyValidDates = showOnlyValidDates
        
        //设置当前应该选中的时间
        initDate(selectDate: selectDate)
        
        //添加遮罩
        addSubview(coverView)
        
        //添加主体view
        addSubview(contentView)
        
        //添加工具栏
        contentView.addSubview(toolView)
        
        //添加时间选择器
        contentView.addSubview(pickerView)
        
        //添加进度条
        contentView.addSubview(timeSlider)
    }
    
    /// 显示pickerView
    func showInWindow(btnCallBackBlock: @escaping ((_ date:Date, _ hourCnt:Int) -> ())){
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        keyWindow!.addSubview(self)
        keyWindow!.bringSubviewToFront(self)
        self.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        self.btnCallBackBlock = btnCallBackBlock
        //显示页面
        showDateOnPicker(date: self.date!)
        UIView.animate(withDuration: 0.3) {
            self.contentView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - CONTENT_HEIGHT, width: SCREEN_WIDTH, height: CONTENT_HEIGHT)
            self.coverView.alpha = 0.6
        }
    }
    
    /// 移除view
    func removePickerView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.frame = CGRect(x: 0, y: SCREEN_HEIGHT, width: SCREEN_WIDTH, height: CONTENT_HEIGHT)
            self.coverView.alpha = 0.2
            UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
        }) { (suc) in
            self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 初始化返回日期
extension PickerView
{
    /// 初始化返回日期
    fileprivate func initDate(selectDate: Date?) {
        var startDay = 0
        var startHour = 0
        var startMinute = 0
        
        // 创建一个包含天数,从最小日期到最大日期的组件
        let components = self.calendar.components(.day, from: self.minDate as Date, to: self.maxDate as Date, options: NSCalendar.Options(rawValue: 0))
        // 拿到天数的行数
        nDays = components.day! + 1
        
        // 赋值给返回的日期
        if selectDate != nil {
            self.date = selectDate!
            return
        }
        
        // 最大的日期
        var dateToPresent:Date?
        if self.minDate.compare(Date() as Date) == ComparisonResult.orderedDescending{
            dateToPresent = self.minDate
        } else if self.maxDate.compare(Date() as Date) == ComparisonResult.orderedAscending {
            dateToPresent = self.maxDate
        } else {
            dateToPresent = Date()
        }
        // 创建一个包含天时分,从最早日期到最大日期的组件
        let todaysComponents = self.calendar.components([.day,.hour,.minute], from: self.earliestPresentedDate as Date, to: dateToPresent! as Date, options: NSCalendar.Options(rawValue: 0))
        // 转换为时间戳并赋值
        startDay = todaysComponents.day! * 60 * 60 * 24
        startHour = todaysComponents.hour! * 60 * 60
        startMinute = todaysComponents.minute! * 60
        // 计算总时间戳
        let timeInterval:TimeInterval = Double(startDay + startHour + startMinute)
        // 赋值给返回的日期
        self.date = Date(timeInterval: timeInterval, since: self.earliestPresentedDate as Date)
    }
}

// MARK: - 设置顶部view：[确定、取消]按钮
extension PickerView
{
    /// 设置pakerview第一栏样式
    ///
    /// - Parameter toolView: [确定、取消]按钮
    fileprivate func setToolView(toolView: UIView){
        toolView.backgroundColor = UIColor.white
        //取消按钮
        let cancleBtn = UIButton()
        cancleBtn.frame = CGRect(x: 10, y: 0, width: 50, height: toolView.frame.size.height)
        cancleBtn.setTitleColor(UIColor.gray, for: .normal)
        cancleBtn.setTitle("取消", for: .normal)
        cancleBtn.titleLabel?.font = FONTSYS14
        cancleBtn.addTarget(self, action: #selector(yesBtnDidClick), for: .touchUpInside)
        toolView.addSubview(cancleBtn)
        
        //选择时间
        let titleLb = UILabel(frame: CGRect(x: cancleBtn.frame.maxX, y: 0, width: toolView.frame.width-cancleBtn.frame.maxX * 2, height: toolView.frame.size.height))
        titleLb.text = "选择时间"
        titleLb.textAlignment = .center
        toolView.addSubview(titleLb)
        
        //确定按钮
        let yesBtn = UIButton()
        yesBtn.frame = CGRect(x: titleLb.frame.maxX, y: cancleBtn.frame.origin.y, width: cancleBtn.frame.size.width, height: cancleBtn.frame.size.height)
        yesBtn.setTitle("确定", for: .normal)
        yesBtn.setTitleColor(UIColor.gray, for: .normal)
        yesBtn.titleLabel?.font = FONTSYS14
        yesBtn.addTarget(self, action: #selector(yesBtnDidClick), for: .touchUpInside)
        toolView.addSubview(yesBtn)
        
        //横线
        let lineView = UIView(frame: CGRect(x: 0, y: toolView.frame.size.height-0.5, width: toolView.frame.size.width, height: 0.5))
        lineView.backgroundColor = UIColor.gray
        lineView.alpha = 0.3
        toolView.addSubview(lineView)
    }
    
    //点击 [确认 | 取消] 按钮
    @objc fileprivate func yesBtnDidClick(){
        print("确定")
        //        let format = DateFormatter()
        //        format.dateFormat = "yyyy-MM-dd"
        //        // 获取系统当前时区
        //        let zone = NSTimeZone.system
        //        // 计算与GMT时区的差
        //        let interval = zone.secondsFromGMT(for: date! as Date)
        //        // 加上差的时时间戳
        //        let localeDate = date?.addingTimeInterval(Double(interval))
        // 回调闭包
        self.btnCallBackBlock?(date!, hourCnt!)
        // 移除view
        removePickerView()
    }
    
    // 值变化事件处理函数
    @objc func sliderValueChanged(_ sender: UISlider) {
        // 根据步进值来调整滑块的值
        let roundedValue = round(sender.value)
        sender.value = roundedValue
        hourCnt = Int(roundedValue)

        // 更新标签显示的值
//        updateValueLabel()
        LSLog("当前值: \(String(describing: hourCnt))")
    }
}

// MARK: - 根据日期滑动到对于的row
extension PickerView
{
    /// 根据日期滑动到对于的row
    ///
    /// - Parameter date: 滑动日期
    func showDateOnPicker(date:Date) {
        self.date = date
        // 创一个由年月日,最早的日期组成的组件
        var components = self.calendar.components([NSCalendar.Unit.year,.month,.day], from: self.earliestPresentedDate as Date)
        // 根据组件从日历中拿到NSDate
        let fromDate = self.calendar.date(from: components)
        // 创建一个日时分,从fromDate到需要显示的date的组件
        components = self.calendar.components([.day,.hour,.minute], from: fromDate!, to: date as Date, options: NSCalendar.Options(rawValue: 0))
        // 计算行数,在计算分钟和小时的时候,为避免滑动到第0行,加上x * (Int(INT16_MAX) / 120),其中x等于对于的进制
        let hoursRow = components.hour! + 24 * (Int(INT16_MAX) / 120)
        let minutesRow = components.minute! + 60 * (Int(INT16_MAX) / 120)
        let daysRow = components.day
        // 滑动到对于的行
        pickerView.selectRow(daysRow!, inComponent: 0, animated: true)
        pickerView.selectRow(hoursRow, inComponent: 1, animated: true)
        pickerView.selectRow(minutesRow, inComponent: 2, animated: true)
    }
}

// MARK: - UIPickerView的代理
extension PickerView: UIPickerViewDelegate,UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return nDays ?? 0
        }
        else if component == 1 {
            return Int(INT16_MAX)
        } else {
            return Int(INT16_MAX)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return SCREEN_WIDTH/2
        case 1:
            return SCREEN_WIDTH/4
        case 2:
            return SCREEN_WIDTH/4
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        // 定义一个label用于展示时间
        let dateLabel = UILabel()
        // 字体大小
        dateLabel.font = UIFont.systemFont(ofSize: 25)
        
        if component == 0 {// 天数
            // 根据当前的行数转换为时间戳,记录当前行数所表示的日期
            let aDate = Date(timeInterval: Double(row * 24 * 60 * 60), since: self.earliestPresentedDate as Date)
            // 创建一个有纪元年月日组成的,当前时间的组件
            var components = self.calendar.components([.era,.year,.month,.day], from: Date())
            // 根据组件从日历里拿到今天的NSDate()
            let toDay = self.calendar.date(from: components)
            // 组件变为由当前行数所表示的日期组成的组件
            components = self.calendar.components([.era,.year,.month,.day], from: aDate)
            // 根据组件从日历拿到当前行数表示的NSDate
            let otherDate = self.calendar.date(from: components)
            // 如果今天的NSDate等于当前行数表示的NSDate,就设置文字为今天
            
            if toDay!.compare(otherDate!) == ComparisonResult.orderedSame{
                dateLabel.text = "今天"
            } else {
                // 如果不是,创建一个NSDateFormatter
                let formatter = DateFormatter()
                // 地区设置
                formatter.locale = NSLocale.current
                // 日期格式设置
                formatter.dateFormat = "M月d日"
                // label文字设置
                dateLabel.text = formatter.string(from: aDate)
            }
            dateLabel.textAlignment = NSTextAlignment.center
        } else if component == 1 {// 小时
            // 小时的范围0-23,长度是24
            let max = self.calendar.maximumRange(of: NSCalendar.Unit.hour).length
            // label文字
            dateLabel.text = String(format:"%02ld",row % max)
            dateLabel.textAlignment = NSTextAlignment.left
        } else if component == 2 {// 分钟
            // 分钟的范围0-59,长度是60
            let max = self.calendar.maximumRange(of: NSCalendar.Unit.minute).length
            dateLabel.text = String(format:"%02ld",row % max)
            dateLabel.textAlignment = NSTextAlignment.left
        }
        return dateLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 选择的日的行数
        let daysRow = pickerView.selectedRow(inComponent: 0)
        // 根据行数转换为时间戳
        let chosenDate = Date(timeInterval: Double(daysRow * 24 * 60 * 60), since: self.earliestPresentedDate as Date)
        // 选择的小时的行数
        let hoursRow = pickerView.selectedRow(inComponent: 1)
        // 选择的分钟的行数
        let minutesRow = pickerView.selectedRow(inComponent: 2)
        // 根据选择的日期的时间戳,创建一个有年月日的日历组件
        var components = self.calendar.components([.day,.month,.year], from: chosenDate)
        // 设置组件的小时
        components.hour = hoursRow % 24
        // 设置组件的分钟
        components.minute = minutesRow % 60
        // 根据组件从日历中拿到对应的NSDate,赋值给date
        self.date = self.calendar.date(from: components)!
        // 比较date与限定的最大最小时间,如果超过最大时间或小于最小时间,就回滚到有效时间内
        if self.date!.compare(self.minDate as Date) == ComparisonResult.orderedAscending {
            self.showDateOnPicker(date: self.minDate)
        } else if self.date!.compare(self.maxDate as Date) == ComparisonResult.orderedDescending {
            self.showDateOnPicker(date: self.maxDate)
        }
    }
    
}

