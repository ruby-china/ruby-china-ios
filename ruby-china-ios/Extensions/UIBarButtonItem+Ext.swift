//
//  UIBarButtonItem+Ext.swift
//  ruby-china-ios
//
//  Created by kelei on 16/10/19.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    /// 生成一个窄的 UIBarButtonItem
    ///
    /// - parameter image:
    /// - parameter target:
    /// - parameter action:
    ///
    /// - returns: UIBarButtonItem
    static func narrowButtonItem(image: UIImage?, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let (item, _) = narrowButtonItem2(image: image, target: target, action: action)
        return item
    }
    
    /// 生成一个窄的 UIBarButtonItem(同时返回 UIBarButtonItem 和里面的 UIButton)
    ///
    /// - parameter image:
    /// - parameter target:
    /// - parameter action:
    ///
    /// - returns: (UIBarButtonItem, UIButton)
    static func narrowButtonItem2(image: UIImage?, target: AnyObject?, action: Selector) -> (UIBarButtonItem, UIButton) {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 44))
        button.setImage(image?.imageWithColor(PRIMARY_COLOR), for: UIControlState())
        button.addTarget(target, action: action, for: .touchUpInside)
        return (UIBarButtonItem(customView: button), button)
    }
    
    /// 返回一个负宽度的 FixedSpace，使得 leftBarButtonItem 和 rightBarButtonItem 距离屏幕边框不那么远。
    ///
    /// - returns: 负宽度的 FixedSpace
    static func fixNavigationSpacer() -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil);
        item.width = -10;
        return item
    }
    
}
