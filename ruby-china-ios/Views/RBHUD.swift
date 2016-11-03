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
    static func success(_ message: String?) {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.isUserInteractionEnabled = false
        hud.customView = UIImageView(image: UIImage(named: "hud-success"))
        hud.mode = .customView
        hud.label.text = message
        hud.hide(animated: true, afterDelay: 3)
    }
    
    static func error(_ message: String?) {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.isUserInteractionEnabled = false
        hud.mode = .text
        hud.label.text = message
        hud.label.numberOfLines = 0
        hud.hide(animated: true, afterDelay: 3)
    }
    
    static func progress(_ message: String?) {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.label.text = message;
    }
    
    static func progressHidden() {
        hud?.hide(animated: true)
    }
}
