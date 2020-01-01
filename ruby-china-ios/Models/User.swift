//
// Created by 姜军 on 12/7/15.
// Copyright (c) 2015 RubyChina. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User {
    let id: Int
    
    let login: String
    let name: String?
    let avatarUrl: URL
    
    let location: String?
    let company: String?
    let twitter: String?
    let website: URL?
    let bio: String?
    let tagline: String?
    let github: String?
    let email: String?
    
    let topicsCount: Int?
    let repliesCount: Int?
    let followingCount: Int?
    let followersCount: Int?
    let favoritesCount: Int?
    
//    let level: LevelValue?
    let levelName: String?
    
//    let createdAt: NSDate?
    
    var isFollowed = false
    var isBlocked = false
    
    var identifier: String {
        return "User#\(self.id)"
    }
    
    init?(json: JSON) {
        if json.type == .null { return nil }
        
        self.id = json["id"].intValue
        
        self.login = json["login"].stringValue
        self.name = json["name"].string
        self.avatarUrl = NSURL(string: json["avatar_url"].stringValue)! as URL
        
        // details
        self.location = json["location"].string
        self.company = json["company"].string
        self.twitter = json["twitter"].string
        if let website = json["website"].string {
            self.website = NSURL(string: website) as URL?
        } else {
            self.website = nil
        }
        self.bio = json["bio"].string
        self.tagline = json["tagline"].string
        self.github = json["github"].string
        self.email = json["email"].string
        
        self.topicsCount = json["topics_count"].int
        self.repliesCount = json["replies_count"].int
        self.followingCount = json["following_count"].int
        self.followersCount = json["followers_count"].int
        self.favoritesCount = json["favorites_count"].int
        
//        self.level = LevelValue(byJSON: json["level"])
        self.levelName = json["level_name"].string
        
//        self.createdAt = json["created_at"].string?.toDate(DateFormat.ISO8601Format(.Extended))
    }
}

extension User: Hashable {
    internal func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension User: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
