//
//  ThemeNavigationController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/8/22.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import AMScrollingNavbar

class ThemeNavigationController: ScrollingNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        // 修复 WebView 中点击“上传图片”按钮不能正常打开“照片图库”问题
        // http://stackoverflow.com/questions/25942676/ios-8-sdk-modal-uiwebview-and-camera-image-picker
        if presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
        }
    }
}
