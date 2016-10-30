//
//  Request.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/26.
//  Copyright © 2016年 ruby-china. All rights reserved.
//
import Alamofire
import SwiftyJSON

typealias APICallbackResponse = DataResponse<Data>
typealias APICallback = (APICallbackResponse, _ json: JSON?) -> Void

class APIRequest {
    
    static fileprivate var _shared = APIRequest()
    
    static var shared: APIRequest {
        return _shared
    }
    
    fileprivate lazy var manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        
        let ret = SessionManager(configuration: configuration)
        ret.adapter = self
        return ret
    }()
//    fileprivate var headers: [String: String]?
    
//    fileprivate var _accessToken:  String?
    var accessToken: String?
//        {
//        get {
//            return _accessToken
//        }
//        set {
//            _accessToken = newValue
//            headers = newValue == nil ? nil : ["Authorization": "Bearer \(newValue!)"]
//        }
//    }
    
    fileprivate func _request(_ method: HTTPMethod, path: String, parameters: [String: AnyObject]?, callback: @escaping APICallback) {
        // print("headers", headers)
        manager.request("\(ROOT_URL)\(path)", method: method, parameters: parameters).responseData { response in
            switch response.result {
            case .success:
                print(method, path, response.response?.statusCode)
                let result = response.data == nil ? nil : JSON(data: response.data!)
                let statusCode = response.response?.statusCode
                if (statusCode == 401) {
                    OAuth2.shared.logout()
                    return
                }
                callback(response, result)
                break
            case .failure(let error):
                print(method, path, error)
                callback(response, nil)
                break
            }
        }
    }
    
    func post(_ path: String, parameters: [String: AnyObject]?, callback: @escaping APICallback) {
        return _request(.post, path: path, parameters: parameters, callback: callback)
    }
    
    func get(_ path: String, parameters: [String: AnyObject]?, callback: @escaping APICallback) {
        return _request(.get, path: path, parameters: parameters, callback: callback)
    }
    
    func delete(_ path: String, parameters: [String: AnyObject]?, callback: @escaping APICallback) {
        return _request(.delete, path: path, parameters: parameters, callback: callback)
    }
}

extension APIRequest: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let accessToken = accessToken, let url = urlRequest.url, url.absoluteString.hasPrefix(ROOT_URL) {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}
