//
//  String+Localize.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/8/30.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}