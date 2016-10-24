//
//  MYHUD.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/8/16.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import MBProgressHUD

private var hud: MBProgressHUD?

class RBHUD {
    static func success(message: String?) {
        guard let view = UIApplication.sharedApplication().keyWindow else {
            return
        }
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.userInteractionEnabled = false
        hud.customView = UIImageView(image: UIImage(named: "hud-success"))
        hud.mode = .CustomView
        hud.label.text = message
        hud.hideAnimated(true, afterDelay: 3)
    }
    
    static func error(message: String?) {
        guard let view = UIApplication.sharedApplication().keyWindow else {
            return
        }
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.userInteractionEnabled = false
        hud.mode = .Text
        hud.label.text = message
        hud.hideAnimated(true, afterDelay: 3)
    }
    
    static func progress(message: String?) {
        guard let view = UIApplication.sharedApplication().keyWindow else {
            return
        }
        hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud?.label.text = message;
    }
    
    static func progressHidden() {
        hud?.hideAnimated(true)
    }
}
