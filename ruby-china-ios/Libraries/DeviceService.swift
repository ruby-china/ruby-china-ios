//
//  DeviceService.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/26.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

class DeviseService {
    static fileprivate let PATH = "/api/v3/devices.json"
    static fileprivate func parameters(_ token: String) -> [String: AnyObject] {
        return ["platform": "ios" as AnyObject, "token": token as AnyObject]
    }
    
    static func create(_ token: String) {
        APIRequest.shared.post(PATH, parameters: parameters(token)) { (response, result) in
            if let result = result, let ok = result["ok"].int, ok == 1 {
                log.info("Submit token successed.")
            }
        }
    }
    
    static func destroy(_ token: String) {
        APIRequest.shared.delete(PATH, parameters: parameters(token)) { (response, result) in
            if let result = result, let ok = result["ok"].int, ok == 1 {
                log.info("Destroy token successed.")
            }
        }
    }
}
