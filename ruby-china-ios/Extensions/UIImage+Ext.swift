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
    static func fromColor(_ color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    
    /// 生成圆角图片
    ///
    /// - parameter imageSize:       图片大小
    /// - parameter radius:          圆角大小
    /// - parameter backgroundColor: 背景色
    /// - parameter borderWidth:     边框宽度
    /// - parameter borderColor:     边框颜色
    ///
    /// - returns: 指定大小的圆角图片
    static func roundedCorner(imageSize: CGSize, radius: CGFloat, backgroundColor: UIColor, borderWidth: CGFloat, borderColor: UIColor) -> UIImage? {
        let sizeToFit = imageSize
        let halfBorderWidth = CGFloat(borderWidth / 2.0)
        
        UIGraphicsBeginImageContextWithOptions(sizeToFit, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        context.setLineWidth(borderWidth)
        context.setStrokeColor(borderColor.cgColor)
        context.setFillColor(backgroundColor.cgColor)
        
        let width = sizeToFit.width, height = sizeToFit.height
        // 开始坐标右边开始
        context.move(to: CGPoint(x: width - halfBorderWidth, y: radius + halfBorderWidth))
        // 右下角
        context.addArc(tangent1End: CGPoint(x: width - halfBorderWidth, y: height - halfBorderWidth), tangent2End: CGPoint(x: width - radius - halfBorderWidth, y: height - halfBorderWidth), radius: radius)
        // 左下角
        context.addArc(tangent1End: CGPoint(x: halfBorderWidth, y: height - halfBorderWidth), tangent2End: CGPoint(x: halfBorderWidth, y: height - radius - halfBorderWidth), radius: radius)
        // 左上角
        context.addArc(tangent1End: CGPoint(x: halfBorderWidth, y: halfBorderWidth), tangent2End: CGPoint(x: width - halfBorderWidth, y: halfBorderWidth), radius: radius)
        // 右上角
        context.addArc(tangent1End: CGPoint(x: width - halfBorderWidth, y: halfBorderWidth), tangent2End: CGPoint(x: width - halfBorderWidth, y: radius + halfBorderWidth), radius: radius)
        
        context.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
    
    /**
     为当前图片用指定颜色填充后取得新的图片
     
     - parameter color: 填充色
     
     - returns: 新图片
     */
    func imageWithColor(_ color: UIColor) -> UIImage? {
        guard let cgimage = cgImage else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgimage)
        color.setFill()
        context.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return newImage
    }
}
