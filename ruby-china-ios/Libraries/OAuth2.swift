import Heimdallr
import SwiftyJSON

protocol OAuth2Delegate: class {
    func oauth2DidLoginSuccessed(_ accessToken: String)
    func oauth2DidLoginFailed(_ error: NSError)
}

class OAuth2 {
    weak var delegate: OAuth2Delegate?
    
    var deviceToken: String? {
        didSet {
            submitDeviceToken()
        }
    }
    
    fileprivate let accessTokenStore: OAuthAccessTokenKeychainStore
    
    fileprivate let heimdallr: Heimdallr
    
    fileprivate(set) var accessToken: String? {
        get { return APIRequest.shared.accessToken }
        set { APIRequest.shared.accessToken = newValue }
    }
    
    fileprivate(set) var currentUser: User? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_CHANGED), object: nil)
        }
    }
    
    static fileprivate let _shared = OAuth2()
    
    static var shared: OAuth2 {
        return _shared
    }
    
    init() {
        accessTokenStore = OAuthAccessTokenKeychainStore(service: "org.ruby-china.turbolinks-app.oauth")
        heimdallr = Heimdallr(tokenURL: URL(string: "\(ROOT_URL)/oauth/token")!, credentials: OAuthClientCredentials(id: OAUTH_CLIENT_ID, secret: OAUTH_SECRET), accessTokenStore: accessTokenStore)
        
        accessToken = accessTokenStore.retrieveAccessToken()?.accessToken
        if (isLogined) {
            reloadCurrentUser()
        }
    }
    
    func login(_ username: String, password: String) {
        heimdallr.requestAccessToken(username: username, password: password) { result in
            switch result {
            case .success:
                guard let accessToken = self.accessTokenStore.retrieveAccessToken()?.accessToken else {
                    print("Login is successful but the access_Token is missing")
                    let err = NSError(domain: "customize", code: -1, userInfo: [NSLocalizedDescriptionKey: "get accessToken failed".localized])
                    
                    DispatchQueue.main.async {
                        self.delegate?.oauth2DidLoginFailed(err)
                    }
                    return
                }
                print("Login successed. accessToken=\(accessToken)")
                self.accessToken = accessToken
                self.submitDeviceToken()
                self.reloadCurrentUser()
                DispatchQueue.main.async {
                    self.delegate?.oauth2DidLoginSuccessed(accessToken)
                }
            case .failure(let err):
                DispatchQueue.main.async {
                    self.delegate?.oauth2DidLoginFailed(err)
                }
            }
        }
    }
    
    var isLogined: Bool {
        return accessToken != nil
    }
    
    fileprivate func submitDeviceToken() {
        if let deviceToken = deviceToken , isLogined {
            DeviseService.create(deviceToken)
        }
    }
    
    fileprivate func reloadCurrentUser() {
        APIRequest.shared.get("/api/v3/users/me.json", parameters: nil, callback: { (response, result) in
            if let result = result , !result.isEmpty {
                let userJSON = result["user"]
                self.currentUser = User(json: userJSON)
                print(self.currentUser)
                
                UserDefaults.standard.setValue(userJSON.rawString(), forKey: "loginUserJSON")
                UserDefaults.standard.synchronize()
            } else if let loginUserJSON = UserDefaults.standard.string(forKey: "loginUserJSON"), let dataFromString = loginUserJSON.data(using: .utf8, allowLossyConversion: false) {
                let jsonObject = JSON(data: dataFromString)
                self.currentUser = User(json: jsonObject)
                print(self.currentUser)
            }
        })
    }
    
    func refreshUnreadNotifications(_ callback: @escaping ((Int) -> Void)) {
        APIRequest.shared.get("/api/v3/notifications/unread_count", parameters: nil) { (response, result) in
            if let result = result , !result.isEmpty {
                let unreadCount = result["count"].intValue
                print("Unread notification count", unreadCount)
                DispatchQueue.main.async {
                    callback(unreadCount)
                }
            }
        }
    }
    
    func logout() {
        if let deviceToken = deviceToken , isLogined {
            DeviseService.destroy(deviceToken)
        }
        
        heimdallr.clearAccessToken()
        accessToken = nil
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "loginUserJSON")
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTICE_SIGNOUT), object: nil)
    }
}
