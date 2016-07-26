import NXOAuth2Client
import SwiftyJSON

protocol OAuth2Delegate: class {
    func oauth2DidLoginSuccessed(accessToken: NXOAuth2AccessToken)
    func oauth2DidLoginFailed(error: NSError)
}

class OAuth2 : NSObject {
    weak var delegate: OAuth2Delegate?
    let client = NXOAuth2AccountStore.sharedStore()
    
    var currentUser = User.init(json: JSON.null)
    
    static private let _shared = OAuth2()
    
    static var shared : OAuth2 {
        get {
            return _shared
        }
    }
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserverForName(NXOAuth2AccountStoreAccountsDidChangeNotification,
                                                                object: client, queue: nil) { (note) in
            let account = note.userInfo![NXOAuth2AccountStoreNewAccountUserInfoKey] as! NXOAuth2Account
            self.storeLogin(account.accessToken)
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
        
        reloadCurrentUser()
    }
    
    func login(username: String, password: String) {
        client.requestAccessToAccountWithType("all", username: username, password: password)
    }
    
    var accessToken : String? {
        get {
            let token = NSUserDefaults.standardUserDefaults().valueForKey("accessToken") as? String
            return token
        }
    }
    
    var isLogined : Bool {
        get {
            return self.accessToken != nil
        }
    }
    
    private func storeLogin(accessToken: NXOAuth2AccessToken) {
        NSUserDefaults.standardUserDefaults().setValue(accessToken.accessToken, forKey: "accessToken")
        NSUserDefaults.standardUserDefaults().setValue(accessToken.refreshToken, forKey: "refreshToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        reloadCurrentUser()
        
    }
    
    func reloadCurrentUser() {
        APIRequest.shared.get("/api/v3/users/me.json", parameters: nil, callback: { result in
            self.currentUser = User.init(json: result!["user"])
            
            print(self.currentUser)
        })
    }
    
    func logout() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("accessToken")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}