//
//  String+Ext.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/9.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import Foundation

extension String {
    func dateValue(_ format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    func dateValueFromISO8601() -> Date? {
        return self.dateValue("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    }
}
