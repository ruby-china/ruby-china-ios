//
//  NotificationName+Ext.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 2018/3/9.
//  Copyright © 2018年 ruby-china. All rights reserved.
//

import Foundation

extension Notification.Name {
    /// 登录成功
    static let userSignin = Notification.Name("userSignin")
    /// 退出登录
    static let userSignout = Notification.Name("userSignout")
    /// 登录用户发生了变化
    static let userChanged = Notification.Name("userChanged")
    
    /// 用户的收藏数据发生了变化
    static let userFavoriteChanged = Notification.Name("userFavoriteChanged")
    /// 未读消息数发生了变化
    static let userUnreadNotificationChanged = Notification.Name("userUnreadNotificationChanged")
}
