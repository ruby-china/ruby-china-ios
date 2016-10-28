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
    func headerWithRefreshingBlock(block: MJRefreshComponentRefreshingBlock) -> () {
        let header = MJRefreshNormalHeader(refreshingBlock: block)
        header.lastUpdatedTimeLabel.hidden = true
        if let color = header.stateLabel?.textColor, image = UIImage(named: "refresh-arrow")?.imageWithColor(color) {
            header.arrowView.image = image
        }
        self.mj_header = header
    }
    
    /// 增加上拉刷新功能
    ///
    /// - parameter block: 回调：刷新操作
    func footerWithRefreshingBlock(block: MJRefreshComponentRefreshingBlock) -> () {
        let footer = MJRefreshAutoNormalFooter(refreshingBlock: block)
        footer.hidden = true
        self.mj_footer = footer
    }
    
}
