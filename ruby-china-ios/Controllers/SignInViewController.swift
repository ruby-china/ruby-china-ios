import UIKit
import WebKit

protocol SignInViewControllerDelegate: class {
    func signInViewControllerDidAuthenticate(sender: SignInViewController)
}

class SignInViewController: UIViewController {
    weak var delegate: SignInViewControllerDelegate?
    var onDidAuthenticate: ((sender: SignInViewController) -> Void)?
    
    private var closeButton: UIBarButtonItem?
    
    private var loginField: RBTextField!
    private var passwordField: RBTextField!
    private var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "登录"
        
        closeButton = UIBarButtonItem.init(barButtonSystemItem: .Cancel, target: self, action: #selector(actionClose))
        
        navigationItem.leftBarButtonItem = closeButton
        
        let boxTop = CGFloat(120)
        let margin = CGFloat(20)
        
        loginField = RBTextField.init(frame: CGRectMake(margin, boxTop, self.view.frame.width - margin * 2, 44))
        loginField.clearButtonMode = .WhileEditing
        loginField.autocorrectionType = .No
        loginField.keyboardType = .EmailAddress
        loginField.autocapitalizationType = .None
        loginField.placeholder = "用户名 / Email"
        loginField.delegate = self
        loginField.returnKeyType = .Next
        loginField.addTarget(self, action: #selector(textFieldDidChanged), forControlEvents: UIControlEvents.EditingChanged)
        
        passwordField = RBTextField.init(frame: CGRectMake(margin, loginField.frame.maxY + margin, self.view.frame.width - margin * 2, 44))
        passwordField.placeholder = "密码"
        passwordField.secureTextEntry = true
        passwordField.delegate = self
        passwordField.returnKeyType = .Done
        passwordField.addTarget(self, action: #selector(textFieldDidChanged), forControlEvents: UIControlEvents.EditingChanged)
        
        loginButton = UIButton.init(frame: CGRectMake(margin, passwordField.frame.maxY + margin, self.view.frame.width - margin * 2, 44))
        loginButton.setTitle("登录", forState: .Normal)
        loginButton.setBackgroundImage(UIImage.fromColor(NAVBAR_BG_COLOR), forState: .Normal)
        loginButton.setBackgroundImage(UIImage.fromColor(NAVBAR_BORDER_COLOR), forState: .Highlighted)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        loginButton.layer.cornerRadius = 6
        loginButton.addTarget(self, action: #selector(actionLogin), forControlEvents: .TouchDown)
        
        loginField.layer.cornerRadius = 0
        passwordField.layer.cornerRadius = 0
        
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(loginField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        
        OAuth2.shared.delegate = self
        
        textFieldDidChanged()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loginField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        loginField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    func actionLogin() {
        if loginButton.enabled {
            loginField.resignFirstResponder()
            passwordField.resignFirstResponder()
            
            RBHUD.progress(nil)
            OAuth2.shared.login(loginField.text!, password: passwordField.text!)
        }
    }
    
    func actionClose() {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidChanged() {
        if let username = loginField.text, let password = passwordField.text where username != "" && password != "" {
            loginButton.enabled = true
        } else {
            loginButton.enabled = false
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == loginField) {
            passwordField.becomeFirstResponder()
        }
        
        if (textField == passwordField) {
            actionLogin()
        }
        return true
    }
}

extension SignInViewController: OAuth2Delegate {
    func oauth2DidLoginSuccessed(accessToken: String) {
        RBHUD.progressHidden()
        print("Login successed", OAuth2.shared.accessToken)
        self.navigationController?.dismissViewControllerAnimated(false, completion: {
            self.delegate?.signInViewControllerDidAuthenticate(self)
            self.onDidAuthenticate?(sender: self)
            NSNotificationCenter.defaultCenter().postNotificationName(NOTICE_SIGNIN_SUCCESS, object: nil)
        })
    }
    
    func oauth2DidLoginFailed(error: NSError) {
        print("Login failed", error.localizedFailureReason)
        
        var errorMessage = ""
        if error.code == 3 {
            errorMessage = "帐号或密码错误，请重试"
        } else {
            errorMessage = error.localizedDescription
            if let failureReason = error.localizedFailureReason {
                errorMessage += "\n" + failureReason
            }
        }
        
        RBHUD.error(errorMessage)
    }
}
