//
//  WebViewController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class WebViewController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupUI()
    }
    
    override func pop() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // TopView
    fileprivate lazy var webView: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
}

extension WebViewController {
    
    func setUri(_ uri: String) {
        if (uri.isEmpty) {
            return
        }
        // 设置web页面的URL
        if let url = URL(string: uri) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

extension WebViewController {
    
    fileprivate func setupUI() {
        
        view.addSubview(webView)
        
        webView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
            make.left.right.equalToSuperview()
        }
    }
}
