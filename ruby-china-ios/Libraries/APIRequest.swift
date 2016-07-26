//
//  Request.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/26.
//  Copyright © 2016年 ruby-china. All rights reserved.
//
import Alamofire
import SwiftyJSON

class APIRequest {
    static private var _shared = APIRequest()
    
    static var shared : APIRequest {
        get {
            return _shared
        }
    }
    
    
    init() {
    }
    
    func headers() -> [String : String] {
        let token = NSUserDefaults.standardUserDefaults().valueForKey("accessToken")
        
        if token == nil {
            return [ "Authorization": "" ]
        }
        
        return [
            "Authorization": "Bearer \(token!)"
        ]

    }
    
    func _request(method: Alamofire.Method, path: String, parameters: [String: AnyObject]?, callback: (JSON? -> Void)) {
        print("headers", headers())
        Alamofire.request(method, "\(ROOT_URL)\(path)", parameters: parameters, encoding: .URL, headers: headers())
                 .responseJSON { response in
                    print(method, path, response.response?.statusCode)
                    let result = JSON.init(data: response.data!)
                    callback(result)
        }
    }
    
    func post(path: String, parameters: [String : AnyObject]?, callback: (JSON? -> Void)) {
        return _request(.POST, path: path, parameters: parameters, callback: { result in
            callback(result)
        })
    }
    
    
    func get(path: String, parameters: [String : AnyObject]?, callback: (JSON? -> Void)) {
        return _request(.GET, path: path, parameters: parameters, callback: { result in
            callback(result)
        })
    }
}
