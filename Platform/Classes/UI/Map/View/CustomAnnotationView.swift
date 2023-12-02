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
        self.image = (annotation as! CustomAnnotation).customImage
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomAnnotation: NSObject, MAAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var customImage: UIImage?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, customImage: UIImage?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.customImage = customImage
    }
}
