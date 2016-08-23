//
//  UIImage+Ext.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/8/15.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
     生成指定颜色大小为1*1的图片
     
     - parameter color: 颜色
     
     - returns: 图片
     */
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    /**
     将当前图片裁成圆角图
     
     - parameter radius:    圆角尺寸
     - parameter sizetoFit: 裁成的图片宽高
     
     - returns: 圆角图片
     */
    func drawRectWithRoundedCorner(radius radius: CGFloat, _ sizetoFit: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        CGContextAddPath(UIGraphicsGetCurrentContext(),
                         UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners,
                            cornerRadii: CGSize(width: radius, height: radius)).CGPath)
        CGContextClip(UIGraphicsGetCurrentContext())
        
        self.drawInRect(rect)
        CGContextDrawPath(UIGraphicsGetCurrentContext(), .FillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return output
    }
    
}