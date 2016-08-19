//
//  DeviceService.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/26.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

class DeviseService {
    static func create(token: String) {
        APIRequest.shared.post("/api/v3/devices.json", parameters: ["platform": "ios", "token": token]) { (statusCode, result) in
            if result!["ok"] == 1 {
                print("Submit token successed.")
            }
        }
    }
}
