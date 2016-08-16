//
//  MYHUD.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/8/16.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import PKHUD

class MYHUD {
    static func success(message: String?) {
        HUD.allowsInteraction = true
        HUD.flash(.LabeledSuccess(title: nil, subtitle: message), delay: 2.0)
    }
    
    static func error(message: String?) {
        HUD.allowsInteraction = true
        HUD.flash(.LabeledError(title: nil, subtitle: message), delay: 2.0)
    }
    
    static func progress(message: String?) {
        HUD.allowsInteraction = false
        HUD.show(.LabeledProgress(title: nil, subtitle: message))
    }
    
    static func progressHidden() {
        HUD.hide()
    }
}