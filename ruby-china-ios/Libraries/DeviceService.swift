//
//  DeviceService.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/26.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

class DeviseService {
    static private let PATH = "/api/v3/devices.json"
    static private func parameters(token: String) -> [String: AnyObject] {
        return ["platform": "ios", "token": token]
    }
    
    static func create(token: String) {
        APIRequest.shared.post(PATH, parameters: parameters(token)) { (response, result) in
            if result!["ok"] == 1 {
                print("Submit token successed.")
            }
        }
    }
    
    static func destroy(token: String) {
        APIRequest.shared.delete(PATH, parameters: parameters(token)) { (response, result) in
            if result!["ok"] == 1 {
                print("Destroy token successed.")
            }
        }
    }
}
