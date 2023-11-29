//
//  CustomAnnotationView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import AMapNaviKit

class CustomAnnotationView: MAAnnotationView {
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    func setupUI() {
        // 在这里设置标注视图的外观，可以设置图标等
        image = UIImage(named: "icon_location1")
    }
}

