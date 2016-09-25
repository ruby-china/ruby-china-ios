import Heimdallr
import SwiftyJSON

protocol OAuth2Delegate: class {
    func oauth2DidLoginSuccessed(accessToken: String)
    func oauth2DidLoginFailed(error: NSError)
}

class OAuth2 {
    weak var delegate: OAuth2Delegate?
    
    var deviceToken: String? {
        didSet {
            submitDeviceToken()
        }
    }
    
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
        
        accessToken = accessTokenStore.retrieveAccessToken()?.accessToken
        if (isLogined) {
            reloadCurrentUser()
        }
    }
    
    func login(username: String, password: String) {
        heimdallr.requestAccessToken(username: username, password: password) { result in
            switch result {
            case .Success:
                guard let accessToken = self.accessTokenStore.retrieveAccessToken()?.accessToken else {
                    print("Login is successful but the access_Token is missing")
                    let err = NSError(domain: "customize", code: -1, userInfo: [NSLocalizedDescriptionKey: "get accessToken failed".localized])
                    dispatch_async(dispatch_get_main_queue(), {
                        self.delegate?.oauth2DidLoginFailed(err)
                    })
                    return
                }
                print("Login successed. accessToken=\(accessToken)")
                self.accessToken = accessToken
                self.submitDeviceToken()
                self.reloadCurrentUser()
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.oauth2DidLoginSuccessed(accessToken)
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
    
    private func submitDeviceToken() {
        if let deviceToken = deviceToken where isLogined {
            DeviseService.create(deviceToken)
        }
    }
    
    private func reloadCurrentUser() {
        APIRequest.shared.get("/api/v3/users/me.json", parameters: nil, callback: { (statusCode, result) in
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
        if let deviceToken = deviceToken where isLogined {
            DeviseService.destroy(deviceToken)
        }
        
        heimdallr.clearAccessToken()
        accessToken = nil
        currentUser = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey("loginUserJSON")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(NOTICE_SIGNOUT, object: nil)
    }
}
