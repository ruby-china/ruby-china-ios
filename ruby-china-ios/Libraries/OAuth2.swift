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
    
    static var shared : OAuth2 {
        return _shared
    }
    
    init() {
        accessTokenStore = OAuthAccessTokenKeychainStore(service: "org.ruby-china.turbolinks-app.oauth")
        heimdallr = Heimdallr(tokenURL: NSURL(string: "\(ROOT_URL)/oauth/token")!, credentials: OAuthClientCredentials(id: OAUTH_CLIENT_ID, secret: OAUTH_SECRET), accessTokenStore: accessTokenStore)
        
        accessToken = accessTokenStore.retrieveAccessToken()?.accessToken
        if (isLogined) {
            if let expiresAt = accessTokenStore.retrieveAccessToken()?.expiresAt where expiresAt < NSDate() {
                // 授权过期，刷新AccessToken
                heimdallr.authenticateRequest(NSURLRequest(URL: NSURL(string: "\(ROOT_URL)/api/v3/users/me.json")!), completion: { (result) in
                    switch result {
                    case .Success:
                        self.accessToken = self.accessTokenStore.retrieveAccessToken()?.accessToken
                        print("refresh accessToken", self.accessToken)
                        self.reloadCurrentUser()
                    case .Failure(let err):
                        print("refresh accessToken failure", err)
                    }
                })
            } else {
                reloadCurrentUser()
            }
        }
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
    
    func reloadCurrentUser() {
        APIRequest.shared.get("/api/v3/users/me.json", parameters: nil, callback: { (statusCode, result) in
            if let statusCode = statusCode where statusCode == 401 {
                self.logout()
                return
            }
            
            self.currentUser = User(json: result!["user"])
            print(self.currentUser)
        })
    }
    
    func refreshUnreadNotifications(callback: (Int -> Void)) {
        APIRequest.shared.get("/api/v3/notifications/unread_count", parameters: nil) { (statusCode, result) in
            if let statusCode = statusCode where statusCode == 401 {
                self.logout()
                return
            }
            
            let unreadCount = (result!["count"] as JSON).intValue
            print("Unread notification count", unreadCount)
            dispatch_async(dispatch_get_main_queue(), {
                callback(unreadCount)
            })
        }
    }
    
    func logout() {
        heimdallr.clearAccessToken()
        accessToken = nil
        currentUser = nil
    }
}