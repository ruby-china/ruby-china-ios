//
//  UIScrollView+MJRefreshDefault.swift
//  ruby-china-ios
//
//  Created by kelei on 16/10/19.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import MJRefresh

extension UIScrollView {
    
    /// 增加下拉刷新功能
    ///
    /// - parameter block: 回调：刷新操作
    func headerWithRefreshingBlock(_ block: @escaping MJRefreshComponentRefreshingBlock) -> () {
        let header = MJRefreshNormalHeader(refreshingBlock: block)
        header?.lastUpdatedTimeLabel.isHidden = true
        if let color = header?.stateLabel?.textColor, let image = UIImage(named: "refresh-arrow")?.imageWithColor(color) {
            header?.arrowView.image = image
        }
        self.mj_header = header
    }
    
    /// 增加上拉刷新功能
    ///
    /// - parameter block: 回调：刷新操作
    func footerWithRefreshingBlock(_ block: @escaping MJRefreshComponentRefreshingBlock) -> () {
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: block)
        footer?.isHidden = true
        self.mj_footer = footer
    }
}
