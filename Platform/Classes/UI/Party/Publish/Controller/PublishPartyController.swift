//
//  PublishPartyController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import ZLPhotoBrowser
import Kingfisher
import AMapSearchKit

class PublishPartyController: BaseController {
    
    let leftMargin = 16
    let cellHeight = 52
    let mapHeight = 66
    let maxCharacterCount = 20
    let keyBordHeight = 300.0
    var userInfo = LoginManager.shared.getUserInfo()
    var beginTime: String = ""
    var endTime: String = ""
    // 创建一个闭包属性来处理时间选择器的值变化
    var timePickerHandler: ((Date) -> Void)?
    var maleCnt: Int = 5
    var femaleCnt: Int = 5
    var selectGameItem: GameItem = GameListResp.defaultGameItem()
    var coverImage: UIImage?
    var coverUrl: String = ""
    var mediaData: Data?
    var suffix: String = ""
    var publicType: Int64 = 1
    var locationItem: AMapPOI?
    var mediaType: OBJECT_KEY_TYPE = .img
    
    override func viewDidLoad() {
        title = "组个桔"
        super.viewDidLoad()
        setupUI()
        
        // 初始化条件
        clickType1Btn(type1Btn)
        
        // 弹出照片选择，延迟是因为直接弹出，会导致tab不会消失的bug
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.imageTapped()
        }
    }
    
    // scrollView
    fileprivate lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: view.bounds)
        sv.delegate = self
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()
    
    // contentView
    fileprivate lazy var contentView: UIView = {
        let view = UIView(frame: view.bounds)
        return view
    }()
    
    // 封面
    fileprivate lazy var cover: UIImageView = {
        let placeHolder = UIImage(named: "default_small")
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.kf.setImage(with: URL(string: ""), placeholder: placeHolder)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        iv.addGestureRecognizer(tapGestureRecognizer)
        return iv
    }()
    
    // 描述
    fileprivate lazy var introduce: UITextView = {
        let textView = UITextView()
        textView.textColor = kColorTextBlack
        textView.font = UIFont.ls_font(14)
        // 将UILabel添加到UITextView的子视图中
        textView.addSubview(introducePlaceHolderLabel)
        textView.delegate = self
        return textView
    }()
    
    // 创建占位文本的UILabel
    fileprivate lazy var introducePlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.text = "简单介绍一下～"
        label.textColor = UIColor.ls_color("#aaaaaa") // 自定义字体颜色
        label.font = UIFont.ls_font(14) // 自定义字体
        
        // 设置UILabel的位置和大小
        label.frame.origin = CGPoint(x: 5, y: 8)
        label.sizeToFit()
        return label
    }()
    
    // 类型
    fileprivate lazy var typeView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var typeTitle: UILabel = {
        let label = UILabel()
        label.text = "类型"
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_mediumFont(14)
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var type1Btn: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#f7f7f7")), for: .normal)
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#FE9C5B")), for: .highlighted)
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#FE9C5B")), for: .selected)
        button.setTitleColor(UIColor.ls_color("#333333"), for: .normal)
        button.setTitleColor(UIColor.ls_color("#ffffff"), for: .highlighted)
        button.setTitleColor(UIColor.ls_color("#ffffff"), for: .selected)
        button.titleLabel?.font = UIFont.ls_mediumFont(14)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.setTitle("公开", for: .normal)
        button.addTarget(self, action: #selector(clickType1Btn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var type2Btn: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#f7f7f7")), for: .normal)
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#FE9C5B")), for: .highlighted)
        button.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#FE9C5B")), for: .selected)
        button.setTitleColor(UIColor.ls_color("#333333"), for: .normal)
        button.setTitleColor(UIColor.ls_color("#ffffff"), for: .highlighted)
        button.setTitleColor(UIColor.ls_color("#ffffff"), for: .selected)
        button.titleLabel?.font = UIFont.ls_mediumFont(14)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.setTitle("私密", for: .normal)
        button.addTarget(self, action: #selector(clickType2Btn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 时间
    fileprivate lazy var timeView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var timeTitle: UILabel = {
        let label = UILabel()
        label.text = "时间"
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_mediumFont(14)
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var timeArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_arrow_right")
        return imageView
    }()
    
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "请选择"
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_font(14)
        label.isUserInteractionEnabled = true
        label.sizeToFit()
        // 添加点击手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTimeTap))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    // 创建时间选择器
    fileprivate lazy var pickerView: PickerView = {
        // 最小时间为当前时间+10分钟，最大时间为当前+14天
        let minDate = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate + 600)
        let maxDate = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate + 14*24*3600)
        let pickerView = PickerView(frame: self.view.frame, minDate: minDate, maxDate: maxDate, selectDate: nil, showOnlyValidDates: true)
        return pickerView
    }()
    
    // 地点
    fileprivate lazy var addressView: UIView = {
        let view = UIView()
        // 添加点击手势识别器
        let addressSelectTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAddressSelect))
        view.addGestureRecognizer(addressSelectTapGesture)
        return view
    }()
    
    // 地图选点
    fileprivate lazy var addressSelectView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var addressTitle: UILabel = {
        let label = UILabel()
        label.text = "地点"
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_mediumFont(14)
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var addressArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_arrow_right")
        return imageView
    }()
    
    // 已经选定位置
    fileprivate lazy var addressMapView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.ls_color("#F9F9F9")
        return view
    }()
    
    fileprivate lazy var addressLocalIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_location1")
        return imageView
    }()
    
    // 名称
    fileprivate lazy var addressNameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium16
        label.textColor = UIColor.ls_color("#333333")
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    // 地址
    fileprivate lazy var addressDetailLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    // 创建地图选择器
    fileprivate lazy var chooseLocationView: ChooseLocationView = {
        let clView = ChooseLocationView(frame: self.view.frame)
        return clView
    }()
    
    // 游戏
    fileprivate lazy var gameView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var gameTitle: UILabel = {
        let label = UILabel()
        label.text = "游戏（可选）"
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_mediumFont(14)
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var gameArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_arrow_right")
        return imageView
    }()
    
    fileprivate lazy var gameLabel: UILabel = {
        let label = UILabel()
        label.text = selectGameItem.name
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_font(14)
        label.isUserInteractionEnabled = true
        label.sizeToFit()
        // 添加点击手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGameTap))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    // 人数
    fileprivate lazy var personView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var personTitle: UILabel = {
        let label = UILabel()
        label.text = "总人数（\(femaleCnt + maleCnt)）"
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_mediumFont(14)
        label.sizeToFit()
        return label
    }()
    
    // 女人数
    fileprivate lazy var femaleView: StepView = {
        let view = StepView()
        view.count = femaleCnt
        view.iconName = "icon_female"
        view.initUI()
        view.actionBlock = { [weak self] count in
            self?.femaleCnt = count
            let total = self!.femaleCnt + self!.maleCnt
            self?.personTitle.text = "总人数（\(total)）"
            self?.personTitle.sizeToFit()
        }
        
        return view
    }()
    
    // 男人数
    fileprivate lazy var maleView: StepView = {
        let view = StepView()
        view.count = maleCnt
        view.iconName = "icon_male"
        view.initUI()
        view.actionBlock = { [weak self] count in
            self?.maleCnt = count
            let total = self!.femaleCnt + self!.maleCnt
            self?.personTitle.text = "总人数（\(total)）"
            self?.personTitle.sizeToFit()
        }
        
        return view
    }()
    
    // 费用
    fileprivate lazy var feeView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var feeTitle: UILabel = {
        let label = UILabel()
        label.text = "每人收费"
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_mediumFont(14)
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var feeTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.ls_color("#FFFFFF")
        textField.textColor = UIColor.ls_color("#FE9C5B")
        textField.delegate = self
        textField.font = UIFont.ls_mediumFont(14)
        textField.textAlignment = .right
        textField.keyboardType = .numberPad
        textField.attributedPlaceholder = NSAttributedString(string: "¥0.00", attributes: [NSAttributedString.Key.foregroundColor: kColorTextGray])
        return textField
    }()
    
    fileprivate lazy var publishBtn: UIButton = {
        let button = UIButton()
        button.setTitleColor(kColorTextWhite, for: .normal)
        button.titleLabel?.font = UIFont.ls_mediumFont(18)
        button.layer.cornerRadius = 24
        button.clipsToBounds = true
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitle("发布", for: .normal)
        button.addTarget(self, action: #selector(clickPublishBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension PublishPartyController {
    
    // 显示图片选择器
    @objc func imageTapped() {
        resignResponders()
        // 重置数据
        coverImage = nil
        mediaData = nil
        
        let pickerConfig = ZLPhotoConfiguration.default()
        pickerConfig.maxSelectCount = 1 // 设置最大选择数量为 1
        let ps = ZLPhotoPreviewSheet()
        ps.selectImageBlock = { [weak self] results, isOriginal in
            // your code
            if results.count > 0 {
                let zlResultModel:ZLResultModel = results[0]
                let asset = zlResultModel.asset
                self?.coverImage = zlResultModel.image
                self?.cover.image = self?.coverImage
                PhotoManager.shared.fetchAssetData(asset: asset) { (data, duration, fileExtension) in
                    if let data = data {
                        // 处理获取到的图片或视频数据
                        LSLog("Successfully fetched data.")
                        if let duration = duration {
                            LSLog("Video duration: \(duration) seconds")
                        }
                        if let fileExtension = fileExtension {
                            LSLog("File extension: \(fileExtension)")
                            self?.suffix = ".\(fileExtension)"
                        }
                        
                        if asset.mediaType == .image {
                            self?.mediaType = .img
                        } else if asset.mediaType == .video {
                            self?.mediaType = .video
                        }
                        self?.mediaData = data
                    } else {
                        // 处理获取数据失败的情况
                        LSLog("Failed to fetch data.")
                    }
                }
            }
        }
        
        ps.showPreview(sender: self)
    }
    
    @objc func clickType1Btn(_ sender:UIButton) {
        resignResponders()
        type2Btn.isSelected = false
        type1Btn.isSelected = true
        publicType = 1
    }
    
    @objc func clickType2Btn(_ sender:UIButton) {
        resignResponders()
        type1Btn.isSelected = false
        type2Btn.isSelected = true
        publicType = 0
    }
    
    @objc func handleTimeTap() {
        resignResponders()
        // 显示时间选择器
        pickerView.showInWindow { [weak self] (date, hourCnt) in
            LSLog("date:\(date), hourCnt:\(hourCnt)")
            let beginTimeStamp:Int? = Int(date.ls_timeStamp)
            var endDate:Date?
            
            if hourCnt != 0 {
                let endTimeStamp: TimeInterval = TimeInterval((beginTimeStamp ?? 0) + hourCnt*3600)
                endDate = Date(timeIntervalSince1970: endTimeStamp)
            }
            
            let dateFormat: String = "yyyy-MM-dd HH:mm:ss"
            let dateFormat1: String = "yyyy-MM-dd HH:mm"
            let dateFormat2: String = " HH:mm"
            let beginDateStr = date.ls_formatterStr(dateFormat1)
            let endDateStr = endDate?.ls_formatterStr(dateFormat2)
            
            self?.beginTime = date.ls_formatterStr(dateFormat)
            self?.endTime = endDate?.ls_formatterStr(dateFormat) ?? ""
            
            LSLog("beginDate:\(beginDateStr), endDate:\(endDateStr ?? "")")
            
            // 展示时间
            self?.timeLabel.text = Date.formatDate(startTime: self?.beginTime, endTime: self?.endTime)
            self?.timeLabel.sizeToFit()
        }
    }
    
    @objc func handleAddressSelect() {
        resignResponders()
        
        // 显示地图
        chooseLocationView.showInWindow { [weak self] poiItem in
            LSLog("showInWindow poiItem:\(poiItem)")
            self?.locationItem = poiItem
            self?.addressNameLabel.text = poiItem.name
            self?.addressNameLabel.sizeToFit()
            
            self?.addressDetailLabel.text = poiItem.address
            self?.addressDetailLabel.sizeToFit()
        }
    }
    
    @objc func handleGameTap() {
        resignResponders()
        
        // 选择游戏类型
        let vc = GameListController()
        vc.gameSelectedBlock = { [weak self] gameItem in
            LSLog("gameSelectedBlock gameItem:\(gameItem)")
            self?.selectGameItem = gameItem
            self?.gameLabel.text = self?.selectGameItem.name
            self?.gameLabel.sizeToFit()
        }
        vc.hidesBottomBarWhenPushed = true
        PageManager.shared.currentNav()?.pushViewController(vc, animated: true)
    }
    
    // 点击发布按钮
    @objc func clickPublishBtn(_ sender:UIButton) {
        // 取消聚焦
        resignResponders()
        
        // 检查各个字段是否有效
        if !checkParam() {
            return
        }
        
        LSHUD.showLoading("发布中...")
        OSSManager.shared.uploadData(mediaData, type: mediaType, suffix: suffix) { [weak self] resp in
            LSLog("uploadData resp:\(resp)")
            if (resp.status == .success) {
                //
                self?.coverUrl = resp.fullUrl
                
                // 发布
                self?.publishParty()
            } else {
                LSHUD.hide()
            }
        }
    }
    
    func publishParty() {
        // 发布组局信息
        var para:[String:Any] = ["cover": coverUrl]
        para["introduction"] = introduce.text
        para["public"] = publicType
        para["start_time"] = beginTime
        para["end_time"] = endTime
        para["address"] = locationItem?.address
        para["landmark"] = locationItem?.name
        para["city_name"] = locationItem?.city
        para["address_code"] = Int64(locationItem?.adcode.prefix(6) ?? "")
        para["latitude"] = locationItem?.location.latitude
        para["longitude"] = locationItem?.location.longitude
        para["relation_game_id"] = selectGameItem.id
        para["male_cnt"] = maleCnt
        para["female_cnt"] = femaleCnt
        para["fee"] = Int64(feeTextField.text ?? "")
        
        NetworkManager.shared.publishParty(para) { [weak self] resp in
            LSHUD.hide()
            if resp.status == .success {
                LSLog("createPlay succ")
                // 跳转到发布成功界面
                let name = "\(self?.userInfo?.nick ?? "")的桔"
                PageManager.shared.pushToPublishSucc(resp.data.uniqueCode, startTime: resp.data.startTime, endTime: resp.data.endTime, name: name, cover: self?.coverImage ?? nil)
                // 发送局状态变更通知
                LSNotification.postPartyStatusChange()
            } else {
                LSLog("createPlay fail")
                LSHUD.showError(resp.msg)
            }
        }
    }
    
    func checkParam() -> Bool {
        if (mediaData == nil) {
            LSLog("checkParam mediaData err")
            LSHUD.showInfo("请选择图片/视频")
            return false
        }
        
//        if (introduce.text.isEmpty) {
//            LSLog("checkParam introduce err")
//            LSHUD.showInfo("请添加描述")
//            return false
//        }
        
        if (beginTime.isEmpty) {
            LSLog("checkParam beginTime err")
            LSHUD.showInfo("请选择时间")
            return false
        }
        
//        if (endTime.isEmpty) {
//            LSLog("checkParam endTime err")
//            LSHUD.showInfo("请选择时间")
//            return false
//        }
        
        if ((locationItem == nil) || (locationItem?.location == nil)) {
            LSLog("checkParam locationItem err")
            LSHUD.showInfo("请选择位置")
            return false
        }
        
        if (maleCnt == 0 || femaleCnt == 0) {
            LSLog("checkParam maleCnt err")
            LSHUD.showInfo("请设置人数")
            return false
        }
        
        return true
    }
    
    func resignResponders() {
        if (introduce.isFirstResponder) {
            introduce.resignFirstResponder()
        }
        if (feeTextField.isFirstResponder) {
            feeTextField.resignFirstResponder()
        }
    }
}

extension PublishPartyController: UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        resignResponders()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 获取当前文本字段的文本
        guard let currentText = textField.text else {
            return true
        }
        
        // 计算新的文本长度
        let newLength = currentText.count + string.count - range.length
        
        // 检查是否超过了最大字符数
        return newLength <= maxCharacterCount
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 当UITextView中有文本时，隐藏占位文本
        introducePlaceHolderLabel.isHidden = !textView.text.isEmpty
    }
}


extension PublishPartyController {
    
    fileprivate func setupUI() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cover)
        contentView.addSubview(introduce)
        contentView.addSubview(typeView)
        typeView.addSubview(typeTitle)
        typeView.addSubview(type1Btn)
        typeView.addSubview(type2Btn)
        contentView.addSubview(timeView)
        timeView.addSubview(timeTitle)
        timeView.addSubview(timeArrow)
        timeView.addSubview(timeLabel)
        contentView.addSubview(addressView)
        addressView.addSubview(addressSelectView)
        addressSelectView.addSubview(addressTitle)
        addressSelectView.addSubview(addressArrow)
        addressView.addSubview(addressMapView)
        addressMapView.addSubview(addressLocalIcon)
        addressMapView.addSubview(addressNameLabel)
        addressMapView.addSubview(addressDetailLabel)
        contentView.addSubview(gameView)
        gameView.addSubview(gameTitle)
        gameView.addSubview(gameArrow)
        gameView.addSubview(gameLabel)
        contentView.addSubview(personView)
        personView.addSubview(personTitle)
        personView.addSubview(femaleView)
        personView.addSubview(maleView)
        contentView.addSubview(feeView)
        feeView.addSubview(feeTitle)
        feeView.addSubview(feeTextField)
        view.addSubview(publishBtn)
        
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(keyBordHeight)
        }
        
        cover.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight + 10)
            make.left.equalToSuperview().offset(leftMargin)
            make.size.equalTo(CGSize(width: 90, height: 120))
        }
        
        introduce.snp.makeConstraints { (make) in
            make.top.equalTo(cover)
            make.left.equalTo(cover.snp.right).offset(10)
            make.bottom.equalTo(cover)
            make.right.equalToSuperview().offset(-leftMargin)
        }
        
        typeView.snp.makeConstraints { (make) in
            make.top.equalTo(cover.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(cellHeight)
        }
        
        typeTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }

        type2Btn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 68, height: 28))
        }

        type1Btn.snp.makeConstraints { (make) in
            make.right.equalTo(type2Btn.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 68, height: 28))
        }

        timeView.snp.makeConstraints { (make) in
            make.top.equalTo(typeView.snp.bottom)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(cellHeight)
        }

        timeTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }

        timeArrow.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }

        timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(timeArrow.snp.left).offset(-4)
            make.centerY.equalToSuperview()
        }

        addressView.snp.makeConstraints { (make) in
            make.top.equalTo(timeView.snp.bottom)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(cellHeight + mapHeight + 16)
        }

        addressSelectView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(cellHeight)
        }

        addressTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }

        addressArrow.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }

        addressMapView.snp.makeConstraints { (make) in
            make.top.equalTo(addressSelectView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(66)
        }

        addressLocalIcon.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }

        addressNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(addressLocalIcon.snp.right).offset(12)
            make.top.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-16)
        }

        addressDetailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(addressNameLabel)
            make.top.equalTo(addressNameLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
        }

        gameView.snp.makeConstraints { (make) in
            make.top.equalTo(addressView.snp.bottom)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(cellHeight)
        }

        gameTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }

        gameArrow.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }

        gameLabel.snp.makeConstraints { (make) in
            make.right.equalTo(gameArrow.snp.left).offset(-4)
            make.centerY.equalToSuperview()
        }

        personView.snp.makeConstraints { (make) in
            make.top.equalTo(gameView.snp.bottom)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(cellHeight)
        }

        personTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }

        femaleView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 88, height: 20))
        }

        maleView.snp.makeConstraints { (make) in
            make.right.equalTo(femaleView.snp.left).offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 88, height: 20))
        }

        feeView.snp.makeConstraints { (make) in
            make.top.equalTo(personView.snp.bottom)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(cellHeight)
        }

        feeTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }

        feeTextField.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
        }

        publishBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-leftMargin*2)
            make.height.equalTo(48)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height + keyBordHeight)
    }
}
