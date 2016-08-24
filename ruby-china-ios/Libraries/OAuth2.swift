import Heimdallr
import SwiftyJSON

protocol OAuth2Delegate: class {
    func oauth2DidLoginSuccessed(accessToken: String)
    func oauth2DidLoginFailed(error: NSError)
}

class OAuth2 {
    weak var delegate: OAuth2Delegate?
    
    private let accessTokenStore: OAuthAccessTokenKeychainStore
    
    private let heimdallr: Heimdallr
    
    private(set) var accessToken: String? {
        get { return APIRequest.shared.accessToken }
        set { APIRequest.shared.accessToken = newValue }
    }
    
    private(set) var currentUser: User? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(USER_CHANGED, object: nil)
        }
    }
    
    static private let _shared = OAuth2()
    
    static var shared: OAuth2 {
        return _shared
    }
    
    init() {
        accessTokenStore = OAuthAccessTokenKeychainStore(service: "org.ruby-china.turbolinks-app.oauth")
        heimdallr = Heimdallr(tokenURL: NSURL(string: "\(ROOT_URL)/oauth/token")!, credentials: OAuthClientCredentials(id: OAUTH_CLIENT_ID, secret: OAUTH_SECRET), accessTokenStore: accessTokenStore)
        
        if let expiresAt = accessTokenStore.retrieveAccessToken()?.expiresAt where expiresAt < NSDate() {
            refreshAccessToken(success: nil, failure: nil)
        } else {
            accessToken = accessTokenStore.retrieveAccessToken()?.accessToken
            if (isLogined) {
                reloadCurrentUser()
            }
        }
    }
    
    private var refreshAccessTokenErrorCount = 0
    /// 授权过期，刷新AccessToken
    func refreshAccessToken(success success: (() -> Void)?, failure: (() -> Void)?) {
        heimdallr.authenticateRequest(NSURLRequest(URL: NSURL(string: "\(ROOT_URL)/api/v3/users/me.json")!), completion: { (result) in
            switch result {
            case .Success:
                self.accessToken = self.accessTokenStore.retrieveAccessToken()?.accessToken
                NSNotificationCenter.defaultCenter().postNotificationName(NOTICE_SIGNIN_SUCCESS, object: nil)
                print("refresh accessToken", self.accessToken)
                self.reloadCurrentUser()
                success?()
            case .Failure(let err):
                print("refresh accessToken failure", err)
                // 这里出错了再调用一次，是因为 ruby-china.org 的第一次 OAuth 认证老是拒绝连接，导致认证失败。
                self.refreshAccessTokenErrorCount += 1
                if self.refreshAccessTokenErrorCount < 2 {
                    self.refreshAccessToken(success: success, failure: failure)
                } else {
                    self.refreshAccessTokenErrorCount = 0
                    self.logout()
                    failure?()
                }
            }
        })
    }
    
    func login(username: String, password: String) {
        heimdallr.requestAccessToken(username: username, password: password) { result in
            switch result {
            case .Success:
                self.accessToken = self.accessTokenStore.retrieveAccessToken()?.accessToken
                print("accessToken", self.accessToken)
                let deviceToken = NSUserDefaults.standardUserDefaults().valueForKey("deviceToken") as? String
                if (deviceToken != nil) {
                    DeviseService.create(deviceToken!)
                }
                
                self.reloadCurrentUser()
                print("Login successed.")
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.oauth2DidLoginSuccessed(self.accessToken!)
                })
            case .Failure(let err):
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.oauth2DidLoginFailed(err)
                })
            }
        }
    }
    
    var isLogined: Bool {
        return accessToken != nil
    }
    
    private func reloadCurrentUser() {
        APIRequest.shared.get("/api/v3/users/me.json", parameters: nil, callback: { (statusCode, result) in
            if let statusCode = statusCode where statusCode == 401 {
                if self.isLogined {
                    self.refreshAccessToken(success: {
                        self.reloadCurrentUser()
                    }, failure: {
                        self.logout()
                    })
                } else {
                    self.logout()
                }
                return
            }
            
            if let result = result where !result.isEmpty {
                let userJSON = result["user"]
                self.currentUser = User(json: userJSON)
                print(self.currentUser)
                
                NSUserDefaults.standardUserDefaults().setValue(userJSON.rawString(), forKey: "loginUserJSON")
                NSUserDefaults.standardUserDefaults().synchronize()
            } else if let loginUserJSON = NSUserDefaults.standardUserDefaults().stringForKey("loginUserJSON"), dataFromString = loginUserJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                let jsonObject = JSON(data: dataFromString)
                self.currentUser = User(json: jsonObject)
                print(self.currentUser)
            }
        })
    }
    
    func refreshUnreadNotifications(callback: (Int -> Void)) {
        APIRequest.shared.get("/api/v3/notifications/unread_count", parameters: nil) { (statusCode, result) in
            if let statusCode = statusCode where statusCode == 401 {
                if self.isLogined {
                    self.refreshAccessToken(success: {
                        self.reloadCurrentUser()
                    }, failure: {
                        self.logout()
                    })
                } else {
                    self.logout()
                }
                return
            }
            
            if let result = result where !result.isEmpty {
                let unreadCount = result["count"].intValue
                print("Unread notification count", unreadCount)
                dispatch_async(dispatch_get_main_queue(), {
                    callback(unreadCount)
                })
            }
        }
    }
    
    func logout() {
        heimdallr.clearAccessToken()
        accessToken = nil
        currentUser = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey("loginUserJSON")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
