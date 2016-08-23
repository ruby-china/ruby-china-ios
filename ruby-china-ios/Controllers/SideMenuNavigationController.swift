//
//  SideMenuNavigationController.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/23.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import SideMenu

class SideMenuNavigationController: UISideMenuNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgFrame = CGRectMake(0, -24, navigationBar.frame.width, navigationBar.frame.height + 24)
        let bgView = UIView(frame: bgFrame);
        
        bgView.backgroundColor = SIDEMENU_NAVBAR_BG_COLOR
        navigationBar.addSubview(bgView)
    }
}
