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
    
    var loginField = RBTextField()
    var passwordField = RBTextField()
    var loginButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "登录"
        
        closeButton = UIBarButtonItem.init(barButtonSystemItem: .Cancel, target: self, action: #selector(actionClose))
        
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        navigationItem.leftBarButtonItem = closeButton

        loginField = RBTextField.init(frame: CGRectMake(15, 100, self.view.frame.width - 30, 40))
        loginField.clearButtonMode = .WhileEditing
        loginField.autocorrectionType = .No
        loginField.keyboardType = .EmailAddress
        loginField.autocapitalizationType = .None
        loginField.placeholder = "用户名 / Email"
        
        passwordField = RBTextField.init(frame: CGRectMake(15, loginField.frame.maxY + 15, self.view.frame.width - 30, 40))
        passwordField.placeholder = "密码"
        passwordField.secureTextEntry = true
        
        loginButton = UIButton.init(frame: CGRectMake(15, passwordField.frame.maxY + 25, self.view.frame.width - 30, 40))
        loginButton.setTitle("登录", forState: .Normal)
        loginButton.setBackgroundImage(UIImage.init(named: "button-normal"), forState: .Normal)
        loginButton.setBackgroundImage(UIImage.init(named: "button-down"), forState: .Highlighted)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        loginButton.layer.cornerRadius = 6
        loginButton.addTarget(self, action: #selector(actionLogin), forControlEvents: .TouchDown)
        
        loginField.layer.cornerRadius = 0
        passwordField.layer.cornerRadius = 0
        
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(loginField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        
        oauth2.delegate = self
    }
    
    func actionLogin() {
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