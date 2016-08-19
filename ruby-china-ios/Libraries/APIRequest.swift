//
//  Request.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/26.
//  Copyright © 2016年 ruby-china. All rights reserved.
//
import Alamofire
import SwiftyJSON

typealias APIRequestCallback = (statusCode: Int?, result: JSON?) -> Void

class APIRequest {
    
    static private var _shared = APIRequest()
    
    static var shared : APIRequest {
        get {
            return _shared
        }
    }
    
    private var headers: [String : String]?
    
    var accessToken: String? {
        didSet {
            headers = accessToken == nil ? nil : ["Authorization": "Bearer \(accessToken!)"]
        }
    }
    
    func _request(method: Alamofire.Method, path: String, parameters: [String: AnyObject]?, callback: APIRequestCallback) {
        print("headers", headers)
        Alamofire.request(method, "\(ROOT_URL)\(path)", parameters: parameters, encoding: .URL, headers: headers).responseJSON { response in
            print(method, path, response.response?.statusCode)
            let result = response.data == nil ? nil : JSON(data: response.data!)
            callback(statusCode: response.response?.statusCode, result: result)
        }
    }
    
    func post(path: String, parameters: [String : AnyObject]?, callback: APIRequestCallback) {
        return _request(.POST, path: path, parameters: parameters, callback: callback)
    }
    
    
    func get(path: String, parameters: [String : AnyObject]?, callback: APIRequestCallback) {
        return _request(.GET, path: path, parameters: parameters, callback: callback)
    }
}
