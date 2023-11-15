//
//  DashedView.swift
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class DashedView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        // 这里控制虚线的样式
        /*
         虚线设置两个重要参数:
         ①phase表示开始绘制之前跳过多少点进行绘制，默认一般设置为0，第二张图片是设置5的实际效果图.

    ②lengths通常都包含两个数字，第一个是绘制的宽度，第二个表示跳过的宽度，也可以设置多个，第三张图是设置为三个参数的实际效果图.绘制按照先绘制，跳过，再绘制，再跳过，无限循环.
         */
        context?.setLineDash(phase: 0, lengths: [4,4])
        context?.fill(self.bounds)

        context?.setStrokeColor(UIColor.lightGray.cgColor)
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.addLine(to: CGPoint(x: self.frame.size.width, y: 0))

        context?.strokePath()

    }

}
