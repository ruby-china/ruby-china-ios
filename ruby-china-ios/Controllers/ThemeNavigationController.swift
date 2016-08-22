//
//  ThemeNavigationController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/8/22.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class ThemeNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barStyle = .Black
        navigationBar.translucent = false
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barTintColor = RED
        
        navigationBar.layer.shadowOffset = CGSizeMake(0, 1)
        navigationBar.layer.shadowRadius = 2.0
        navigationBar.layer.shadowColor = UIColor.blackColor().CGColor
        navigationBar.layer.shadowOpacity = 0.20
    }
}
