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
    static func fromColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    static func roundedCorner(imageSize imageSize: CGSize, radius: CGFloat, backgroundColor: UIColor, borderWidth: CGFloat, borderColor: UIColor) -> UIImage? {
        let sizeToFit = imageSize
        let halfBorderWidth = CGFloat(borderWidth / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(sizeToFit, false, UIScreen.mainScreen().scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        CGContextSetLineWidth(context, borderWidth)
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor)
        
        let width = sizeToFit.width, height = sizeToFit.height
        CGContextMoveToPoint(context, width - halfBorderWidth, radius + halfBorderWidth)  // 开始坐标右边开始
        CGContextAddArcToPoint(context, width - halfBorderWidth, height - halfBorderWidth, width - radius - halfBorderWidth, height - halfBorderWidth, radius)  // 右下角角度
        CGContextAddArcToPoint(context, halfBorderWidth, height - halfBorderWidth, halfBorderWidth, height - radius - halfBorderWidth, radius) // 左下角角度
        CGContextAddArcToPoint(context, halfBorderWidth, halfBorderWidth, width - halfBorderWidth, halfBorderWidth, radius) // 左上角
        CGContextAddArcToPoint(context, width - halfBorderWidth, halfBorderWidth, width - halfBorderWidth, radius + halfBorderWidth, radius) // 右上角
        
        CGContextDrawPath(context, .FillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
    
    /**
     将当前图片裁成圆角图
     
     - parameter radius:    圆角尺寸
     - parameter sizetoFit: 裁成的图片宽高
     
     - returns: 圆角图片
     */
    func drawRectWithRoundedCorner(radius radius: CGFloat, _ sizetoFit: CGSize) -> UIImage? {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .AllCorners, cornerRadii: CGSize(width: radius, height: radius))
        CGContextAddPath(context, path.CGPath)
        CGContextClip(context)
        
        self.drawInRect(rect)
        CGContextDrawPath(context, .FillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return output
    }
    
    /**
     为当前图片用指定颜色填充后取得新的图片
     
     - parameter color: 填充色
     
     - returns: 新图片
     */
    func imageWithColor(color: UIColor) -> UIImage? {
        guard let cgimage = CGImage else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        CGContextTranslateCTM(context, 0, size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextSetBlendMode(context, .Normal)
        let rect = CGRectMake(0, 0, size.width, size.height)
        CGContextClipToMask(context, rect, cgimage)
        color.setFill()
        CGContextFillRect(context, rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return newImage
    }
}
