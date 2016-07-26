import UIKit
import WebKit
import NXOAuth2Client

protocol SignInViewControllerDelegate: class {
    func signInViewControllerDidAuthenticate(controller: SignInViewController)
}

class SignInViewController: UIViewController {
    weak var delegate: SignInViewControllerDelegate?
    let oauth2 = OAuth2()
    
    var closeButton: UIBarButtonItem?
    
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "登录"
        
        closeButton = UIBarButtonItem.init(barButtonSystemItem: .Cancel, target: self, action: #selector(actionClose))
        
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        navigationItem.leftBarButtonItem = closeButton

        loginButton.backgroundColor = UIColor.whiteColor()
        loginButton.layer.cornerRadius = 6
        
        loginField.layer.cornerRadius = 0
        passwordField.layer.cornerRadius = 0
        
        oauth2.delegate = self
    }
    
    @IBAction func actionLogin() {
        oauth2.login(loginField.text!, password: passwordField.text!)
    }
    
    func actionClose() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SignInViewController: OAuth2Delegate {
    func oauth2DidLoginSuccessed(accessToken: NXOAuth2AccessToken) {
        print("Login successed", OAuth2.accessToken)
//        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        delegate?.signInViewControllerDidAuthenticate(self)
    }
    
    func oauth2DidLoginFailed(error: NSError) {
        print("Login failed", error)
    }
}
