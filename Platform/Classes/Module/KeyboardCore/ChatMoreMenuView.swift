//
//  ChatMoreMenuView.swift
//  FY-JetChat
//
//  Created by iOS.Jet on 2019/11/14.
//  Copyright © 2019 Jett. All rights reserved.
//

import UIKit

/// 行数
fileprivate let kRowNumber = 2
/// 列数
fileprivate let kColumnNumber = 4

fileprivate let kMoreMenuCellNumberOfOnePage = kRowNumber * kColumnNumber

protocol ChatMoreMenuViewDelegate {
    /// 获取选择的菜单
    func menu(_ view: ChatMoreMenuView, DidSelected type: ChatMoreMenuType)
}

extension ChatMoreMenuViewDelegate {
    
    func menu(_ view: ChatMoreMenuView, DidSelected type: ChatMoreMenuType) {}
}

class ChatMoreMenuView: UIView {
    
    // MARK: - lazy var
    
    var delegate: ChatMoreMenuViewDelegate?

    lazy var dataSource: [ChatMoreMnueConfig] = {
        let configs = [
            ChatMoreMnueConfig(title: "图片", image: "ic_more_album", type: .album),
            ChatMoreMnueConfig(title: "拍照", image: "ic_more_camera", type: .camera),
            ChatMoreMnueConfig(title: "视频", image: "ic_more_video", type: .video),
            ChatMoreMnueConfig(title: "位置", image: "ic_more_location", type: .location),
            ChatMoreMnueConfig(title: "语音", image: "ic_more_voice", type: .voice),
            ChatMoreMnueConfig(title: "钱包", image: "ic_more_wallet", type: .wallet),
            ChatMoreMnueConfig(title: "转账", image: "ic_more_pay", type: .pay),
            ChatMoreMnueConfig(title: "名片", image: "ic_more_friendcard", type: .friendcard),
            ChatMoreMnueConfig(title: "收藏", image: "ic_more_favorite", type: .favorite),
            ChatMoreMnueConfig(title: "隐藏", image: "ic_more_sight", type: .sight)]
        return configs
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = ChatKeyboardFlowLayout(column: kColumnNumber, row: kRowNumber)
        // collectionView
        let collection = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collection.theme.backgroundColor = themed { $0.FYColor_BackgroundColor_V14 }
        collection.register(ChatMoreMenuCell.self, forCellWithReuseIdentifier: "ChatMoreMenuCell")
        collection.showsHorizontalScrollIndicator = true
        collection.showsVerticalScrollIndicator = true
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    // MARK: - life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
           
        makeUI()
        reloadData()
    }
       
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        makeUI()
        reloadData()
    }
    
    func makeUI() {
        self.theme.backgroundColor = themed { $0.FYColor_BackgroundColor_V14 }
        
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
        }
    }
    
    open func reloadData() {
        self.needsUpdateConstraints()
        self.layoutIfNeeded()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}


// MARK: - UICollectionViewDataSource

extension ChatMoreMenuView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"ChatMoreMenuCell", for: indexPath) as! ChatMoreMenuCell
        cell.model = dataSource[indexPath.row]
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension ChatMoreMenuView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        delegate?.menu(self, DidSelected: model.type!)
        
    }
}

