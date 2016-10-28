//
//  Request.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/26.
//  Copyright © 2016年 ruby-china. All rights reserved.
//
import Alamofire
import SwiftyJSON

typealias APICallbackResponse = Response<NSData, NSError>
typealias APICallback = (APICallbackResponse, json: JSON?) -> Void

class APIRequest {
    
    static private var _shared = APIRequest()
    
    static var shared: APIRequest {
        return _shared
    }
    
    private lazy var alamofireManager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        return Alamofire.Manager(configuration: configuration)
    }()
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
    
    private func _request(method: Alamofire.Method, path: String, parameters: [String: AnyObject]?, callback: APICallback) {
        // print("headers", headers)
        alamofireManager.request(method, "\(ROOT_URL)\(path)", parameters: parameters, encoding: .URL, headers: headers).responseData { response in
            switch response.result {
            case .Success:
                print(method, path, response.response?.statusCode)
                let result = response.data == nil ? nil : JSON(data: response.data!)
                let statusCode = response.response?.statusCode
                if (statusCode == 401) {
                    OAuth2.shared.logout()
                    return
                }
                callback(response, json: result)
                break
            case .Failure(let error):
                print(method, path, error)
                callback(response, json: nil)
                break
            }
        }
    }
    
    func post(path: String, parameters: [String: AnyObject]?, callback: APICallback) {
        return _request(.POST, path: path, parameters: parameters, callback: callback)
    }
    
    func get(path: String, parameters: [String: AnyObject]?, callback: APICallback) {
        return _request(.GET, path: path, parameters: parameters, callback: callback)
    }
    
    func delete(path: String, parameters: [String: AnyObject]?, callback: APICallback) {
        return _request(.DELETE, path: path, parameters: parameters, callback: callback)
    }
}
