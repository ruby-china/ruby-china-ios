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
        
        navigationBar.bottomBorder = true
    }
}
