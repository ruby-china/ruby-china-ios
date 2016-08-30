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
    
    static var shared: APIRequest {
        return _shared
    }
    
    private var headers: [String: String]?
    
    private var _accessToken:  String?
    var accessToken: String? {
        get {
            return _accessToken
        }
        set {
            _accessToken = newValue
            headers = newValue == nil ? nil : ["Authorization": "Bearer \(newValue!)"]
        }
    }
    
    private func _request(method: Alamofire.Method, path: String, parameters: [String: AnyObject]?, callback: APIRequestCallback) {
        // print("headers", headers)
        Alamofire.request(method, "\(ROOT_URL)\(path)", parameters: parameters, encoding: .URL, headers: headers).responseJSON { response in
            print(method, path, response.response?.statusCode)
            let result = response.data == nil ? nil : JSON(data: response.data!)
            let statusCode = response.response?.statusCode
            if (statusCode == 401) {
                OAuth2.shared.logout()
                return
            }
            callback(statusCode: statusCode, result: result)
        }
    }
    
    func post(path: String, parameters: [String: AnyObject]?, callback: APIRequestCallback) {
        return _request(.POST, path: path, parameters: parameters, callback: callback)
    }
    
    func get(path: String, parameters: [String: AnyObject]?, callback: APIRequestCallback) {
        return _request(.GET, path: path, parameters: parameters, callback: callback)
    }
    
    func delete(path: String, parameters: [String: AnyObject]?, callback: APIRequestCallback) {
        return _request(.DELETE, path: path, parameters: parameters, callback: callback)
    }
}
