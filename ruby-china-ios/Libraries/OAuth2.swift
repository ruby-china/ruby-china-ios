import NXOAuth2Client

protocol OAuth2Delegate: class {
    func oauth2DidLoginSuccessed(accessToken: NXOAuth2AccessToken)
    func oauth2DidLoginFailed(error: NSError)
}

class OAuth2 {
    weak var delegate: OAuth2Delegate?
    let client = NXOAuth2AccountStore.sharedStore()
    
    init() {
        NSNotificationCenter.defaultCenter().addObserverForName(NXOAuth2AccountStoreAccountsDidChangeNotification,
                                                                object: client, queue: nil) { (note) in
            let account = note.userInfo![NXOAuth2AccountStoreNewAccountUserInfoKey] as! NXOAuth2Account
            OAuth2.storeLogin(account.accessToken)
            self.delegate?.oauth2DidLoginSuccessed(account.accessToken)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(NXOAuth2AccountStoreDidFailToRequestAccessNotification,
                                                                object: client, queue: nil) { (note) in
            let error = note.userInfo![NXOAuth2AccountStoreErrorKey] as! NSError
            self.delegate?.oauth2DidLoginFailed(error)
        }
        
        client.setClientID(OAUTH_CLIENT_ID,
                           secret: OAUTH_SECRET,
                           authorizationURL: NSURL(string: "\(ROOT_URL)/oauth/authorize"),
                           tokenURL: NSURL(string: "\(ROOT_URL)/oauth/token"),
                           redirectURL: nil,
                           forAccountType: "all")
    }
    
    func login(username: String, password: String) {
        client.requestAccessToAccountWithType("all", username: username, password: password)
    }
    
    static var accessToken : String? {
        get {
            let token = NSUserDefaults.standardUserDefaults().valueForKey("accessToken") as? String
            return token
        }
    }
    
    static var isLogined : Bool {
        get {
            return self.accessToken != nil
        }
    }
    
    static private func storeLogin(accessToken: NXOAuth2AccessToken) {
        NSUserDefaults.standardUserDefaults().setValue(accessToken.accessToken, forKey: "accessToken")
        NSUserDefaults.standardUserDefaults().setValue(accessToken.refreshToken, forKey: "refreshToken")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func logout() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("accessToken")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}