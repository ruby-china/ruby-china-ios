//
//  UIBarButtonItem+Ext.swift
//  ruby-china-ios
//
//  Created by kelei on 16/10/19.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    static func customView(image image: UIImage?, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        let (item, _) = customView2(image: image, target: target, action: action)
        return item
    }
    
    static func customView2(image image: UIImage?, target: AnyObject?, action: Selector) -> (UIBarButtonItem, UIButton) {
        let button = UIButton(frame: CGRectMake(0, 0, 30, 44))
        button.setImage(image?.imageWithColor(NAVBAR_TINT_COLOR), forState: .Normal)
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        return (UIBarButtonItem(customView: button), button)
    }
    
    static func fixNavigationSpacer() -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
        item.width = -10;
        return item
    }
    
}
