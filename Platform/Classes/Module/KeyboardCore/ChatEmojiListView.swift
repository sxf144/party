//
//  ChatEmojiListView.swift
//  FY-JetChat
//
//  Created by iOS.Jet on 2019/11/14.
//  Copyright © 2019 Jett. All rights reserved.
//

import UIKit


/// 行数
fileprivate let kRowNumber = 3
/// 列数
fileprivate let kColumnNumber = 8


protocol ChatEmojiListViewDelegate {
    /// 获取的表情
    func emojiView(_ emojiView: ChatEmojiListView, DidFinish emotion: ChatEmoticon)
    /// 发送内容
    func emojiView(_ emojiView: ChatEmojiListView, DidFinish isSend: Bool)
    /// 删除上一步内容
    func emojiView(_ emojiView: ChatEmojiListView, DidDelete backward: Bool)
}

extension ChatEmojiListViewDelegate {
    func emojiView(_ emojiView: ChatEmojiListView, DidFinish emoji: String) {}
    func emojiView(_ emojiView: ChatEmojiListView, DidFinish isSend: Bool) {}
    func emojiView(_ emojiView: ChatEmojiListView, DidDelete backward: Bool) {}
}

class ChatEmojiListView: UIView {
    
    private var selectedIndex: Int = 0
    private let kBottomMargin: CGFloat = 8
    private let kBottomHeight: CGFloat = 44
    
    // MARK: - lazy var
    
    var selectedType: Int = 0
    
    /// 设置代理
    var delegate: ChatEmojiListViewDelegate?
    
    lazy var emojiButtons: [UIButton] = {
        let buttons = [self.appleEmojiBtn, self.weChatEmojiBtn]
        return buttons
    }()
    
    lazy var dataSource: [ChatEmoticon] = {
        return ChatEmotionHelper.getAppleAllEmotions()
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = ChatKeyboardFlowLayout(column: kColumnNumber, row: kRowNumber)
        // collectionView
        let collection = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collection.theme.backgroundColor = themed { $0.FYColor_BackgroundColor_V14 }
        collection.register(ChatAppleEmojiCell.self, forCellWithReuseIdentifier: "ChatAppleEmojiCell")
        collection.showsHorizontalScrollIndicator = true
        collection.showsVerticalScrollIndicator = true
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("发送", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.theme.titleColor(from: themed{ $0.FYColor_Main_TextColor_V12 }, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.theme.backgroundColor = themed { $0.FYColor_BackgroundColor_V13 }
        button.isEnabled = false
        button.addTarget(self, action: #selector(sendContent), for: .touchUpInside)
        return button
    }()
    
    lazy var bottomView: UIView = {
        let toolBar = UIView()
        toolBar.theme.backgroundColor = themed { $0.FYColor_BackgroundColor_V14 }
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }()
    
    lazy var appleEmojiBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("😊", for: .normal)
        button.addTarget(self, action: #selector(emojiAction), for: .touchUpInside)
        button.backgroundColor = .clear
        button.tag = 1000
        return button
    }()
    
    lazy var weChatEmojiBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icon_emoji_expression"), for: .normal)
        button.addTarget(self, action: #selector(emojiAction), for: .touchUpInside)
        button.backgroundColor = .clear
        button.tag = 1001
        return button
    }()
    
    lazy var emojiSelectView: UIView = {
        let v = UIView()
        v.theme.backgroundColor = themed { $0.FYColor_BackgroundColor_V15 }
        return v
    }()
    
    
    // MARK: - life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
           
        makeUI()
        reloadData()
        registerNotification()
    }
       
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        makeUI()
        reloadData()
        registerNotification()
    }
    
    func makeUI() {
        theme.backgroundColor = themed { $0.FYColor_BackgroundColor_V14 }
        
        bottomView.addSubview(emojiSelectView)
        bottomView.addSubview(appleEmojiBtn)
        bottomView.addSubview(weChatEmojiBtn)
        bottomView.addSubview(sendButton)
        
        addSubview(bottomView)
        bringSubviewToFront(bottomView)
        addSubview(collectionView)
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
            make.height.equalTo(kBottomHeight)
        }
        
        emojiSelectView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(70)
        }
        
        appleEmojiBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(emojiSelectView)
        }
        
        weChatEmojiBtn.snp.makeConstraints { (make) in
            make.left.equalTo(appleEmojiBtn.snp.right)
            make.height.equalToSuperview()
            make.width.equalTo(emojiSelectView)
        }
        
        sendButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(70)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
    
    func registerNotification() {
        // 实时监听输入值的改变
        NotificationCenter.default.addObserver(self, selector: #selector(contentDidChanged(_:)), name: .kChatTextKeyboardChanged, object: nil)
    }
    
    open func reloadData() {
        self.needsUpdateConstraints()
        self.layoutIfNeeded()
        
        self.sendButton.alpha = 1.0
        self.bottomView.alpha = 1.0
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            self.sendButton.isHidden = false
            self.bottomView.isHidden = false
        }, completion: nil)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.scrollToLeft()
        }
    }
    
    /// 发送
    @objc func sendContent() {
        
        delegate?.emojiView(self, DidFinish: true)
    }
    
    @objc func emojiAction(_ button: UIButton) {
        if self.selectedIndex == button.tag - 1000 {
            return;
        }
        
        switch button.tag {
        case 1000:
            dataSource = ChatEmotionHelper.getAppleAllEmotions()
            break
        default:
            dataSource = ChatEmotionHelper.getWeChatAllEmotions()
            break
        }
        
        selectedIndex = button.tag - 1000
        emojiSelection(index: selectedIndex)
        
        reloadData()
    }
    
    // MARK: - Action
    
    @objc
    func emojiSelection(index: Int) {
        // 选择emoji类型
        UIView.animate(withDuration: 0.25) {
            self.emojiSelectView.snp.updateConstraints { make in
                make.left.equalToSuperview().offset(70 * index)
            }
        }
        
        emojiSelectView.superview?.layoutIfNeeded()
    }
    
    @objc
    func scrollToLeft(_ animated: Bool = false) {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: animated)
    }
}

// MARK: - Notification

extension ChatEmojiListView {
    
    @objc func contentDidChanged(_ noti: Notification) {
        if (noti.object == nil) {
            return
        }
        
        if let insertText = noti.object as? String {
            LSLog("String -- \(insertText)")
            sendButton.isEnabled = insertText.count > 0
        }
        
        if let insertAttrs = noti.object as? NSAttributedString {
            LSLog("NSAttributedString -- \(insertAttrs)")
            sendButton.isEnabled = insertAttrs.length > 0
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ChatEmojiListView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatAppleEmojiCell", for: indexPath) as! ChatAppleEmojiCell
        cell.model = dataSource[indexPath.row]
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension ChatEmojiListView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if dataSource.count > indexPath.row {
            let emojiModel = dataSource[indexPath.row]
            if emojiModel.isDelete {
                delegate?.emojiView(self, DidDelete: true)
            }else {
                if (emojiModel.isSpace) {
                    return
                }
                
                delegate?.emojiView(self, DidFinish: emojiModel)
            }
        }
    }
}
