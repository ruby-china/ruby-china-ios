import Heimdallr
import SwiftyJSON

protocol OAuth2Delegate: class {
    func oauth2DidLoginSuccessed(accessToken: String?)
    func oauth2DidLoginFailed(error: NSError)
}

class OAuth2 : NSObject {
    weak var delegate: OAuth2Delegate?
    let client = OAuthClientCredentials(id: OAUTH_CLIENT_ID, secret: OAUTH_SECRET)
    let accessTokenStore = OAuthAccessTokenKeychainStore()
    
    dynamic var accessToken = ""
    
    var currentUser = User.init(json: JSON.null)
    
    static private let _shared = OAuth2()
    
    static var shared : OAuth2 {
        get {
            return _shared
        }
    }
    
    override init() {
        super.init()
        let token = NSUserDefaults.standardUserDefaults().valueForKey("accessToken") as? String
        if (token != nil) {
            self.accessToken = token!
        }
        reloadCurrentUser()
    }
    
    func login(username: String, password: String) {
        let heimdallr = Heimdallr(tokenURL: NSURL(string: "\(ROOT_URL)/oauth/token")!)
        heimdallr.requestAccessToken(username: username, password: password) { result in
            switch result {
            case .Success:
                let accessTokenString = self.accessTokenStore.retrieveAccessToken()?.accessToken
                self.storeAccessToken(accessTokenString!)
                print("Login successed.")
                self.delegate?.oauth2DidLoginSuccessed(accessTokenString)
            case .Failure(let err):
                print("Login failed: ", err)
                self.delegate?.oauth2DidLoginFailed(err)
            }
        }
    }
    
    func storeAccessToken(token: String) {
        self.accessToken = token
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "accessToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let deviceToken = NSUserDefaults.standardUserDefaults().valueForKey("deviceToken") as? String
        if (deviceToken != nil) {
            DeviseService.create(deviceToken!)
        }
    }
    
    var isLogined : Bool {
        get {
            return self.accessToken != ""
        }
    }
    
    func reloadCurrentUser() {
        APIRequest.shared.get("/api/v3/users/me.json", parameters: nil, callback: { result in
            self.currentUser = User.init(json: result!["user"])
            
            print(self.currentUser)
        })
    }
    
    func logout() {
        self.accessToken = ""
        NSUserDefaults.standardUserDefaults().removeObjectForKey("accessToken")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}