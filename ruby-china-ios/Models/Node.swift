//
//  Node.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/15.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Node {
    let id: Int
    let name: String
    let topicsCount: Int
    let summary: String
    let sort: Int
    let sectionID: Int
    let sectionName: String
    let updatedAt: Date
    
    init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        topicsCount = json["topics_count"].intValue
        summary = json["summary"].stringValue
        sort = json["sort"].intValue
        sectionID = json["section_id"].intValue
        sectionName = json["section_name"].stringValue
        updatedAt = json["updated_at"].stringValue.dateValueFromISO8601()! as Date
    }
}
