import Heimdallr
import SwiftyJSON

protocol OAuth2Delegate: class {
    func oauth2DidLoginSuccessed(accessToken: String)
    func oauth2DidLoginFailed(error: NSError)
}

class OAuth2 : NSObject {
    weak var delegate: OAuth2Delegate?
    
    private let client = OAuthClientCredentials(id: OAUTH_CLIENT_ID, secret: OAUTH_SECRET)
    private let accessTokenStore = OAuthAccessTokenKeychainStore()
    private let heimdallr = Heimdallr(tokenURL: NSURL(string: "\(ROOT_URL)/oauth/token")!)
    
    private(set) var accessToken: String?
    
    private(set) var currentUser: User? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(USER_CHANGED, object: nil)
        }
    }
    
    static private let _shared = OAuth2()
    
    static var shared : OAuth2 {
        return _shared
    }
    
    override init() {
        super.init()
        accessToken = NSUserDefaults.standardUserDefaults().valueForKey("accessToken") as? String
        APIRequest.shared.accessToken = accessToken
        if (isLogined) {
            reloadCurrentUser()
        }
    }
    
    func login(username: String, password: String) {
        heimdallr.requestAccessToken(username: username, password: password) { result in
            switch result {
            case .Success:
                let accessTokenString = self.accessTokenStore.retrieveAccessToken()?.accessToken
                print("accessToken", accessTokenString)
                self.storeAccessToken(accessTokenString!)
                self.reloadCurrentUser()
                print("Login successed.")
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.oauth2DidLoginSuccessed(accessTokenString!)
                })
            case .Failure(let err):
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.oauth2DidLoginFailed(err)
                })
            }
        }
    }
    
    private func storeAccessToken(token: String) {
        accessToken = token
        APIRequest.shared.accessToken = token
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "accessToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let deviceToken = NSUserDefaults.standardUserDefaults().valueForKey("deviceToken") as? String
        if (deviceToken != nil) {
            DeviseService.create(deviceToken!)
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
        if accessToken != nil {
            accessToken = nil
        }
        APIRequest.shared.accessToken = nil
        heimdallr.clearAccessToken()
        NSUserDefaults.standardUserDefaults().removeObjectForKey("accessToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        currentUser = nil
    }
}