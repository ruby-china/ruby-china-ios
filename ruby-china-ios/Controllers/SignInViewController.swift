import UIKit
import WebKit
import YYKeyboardManager

protocol SignInViewControllerDelegate: class {
    func signInViewControllerDidAuthenticate(sender: SignInViewController)
}

class SignInViewController: UIViewController {
    weak var delegate: SignInViewControllerDelegate?
    var onDidAuthenticate: ((sender: SignInViewController) -> Void)?
    
    private var contentView: UIView!
    private var loginField: RBTextField!
    private var passwordField: RBTextField!
    private var loginButton: UIButton!
    
    private func setupViews() {
        let margin = CGFloat(20)
        
        loginField = RBTextField(frame: CGRectMake(margin, 0, view.frame.width - margin * 2, 44))
        loginField.clearButtonMode = .WhileEditing
        loginField.autocorrectionType = .No
        loginField.keyboardType = .EmailAddress
        loginField.autocapitalizationType = .None
        loginField.placeholder = "用户名 / Email"
        loginField.delegate = self
        loginField.returnKeyType = .Next
        loginField.addTarget(self, action: #selector(textFieldDidChanged), forControlEvents: UIControlEvents.EditingChanged)
        
        passwordField = RBTextField(frame: CGRectMake(margin, loginField.frame.maxY + margin, view.frame.width - margin * 2, 44))
        passwordField.placeholder = "密码"
        passwordField.secureTextEntry = true
        passwordField.delegate = self
        passwordField.returnKeyType = .Done
        passwordField.addTarget(self, action: #selector(textFieldDidChanged), forControlEvents: UIControlEvents.EditingChanged)
        
        loginButton = UIButton(frame: CGRectMake(margin, passwordField.frame.maxY + margin, view.frame.width - margin * 2, 44))
        loginButton.setTitle("登录", forState: .Normal)
        loginButton.setBackgroundImage(UIImage.fromColor(NAVBAR_BG_COLOR), forState: .Normal)
        loginButton.setBackgroundImage(UIImage.fromColor(NAVBAR_BORDER_COLOR), forState: .Highlighted)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        loginButton.addTarget(self, action: #selector(actionLogin), forControlEvents: .TouchDown)
        
        contentView = UIView(frame: CGRectMake(0, 0, view.frame.width, loginButton.frame.maxY))
        contentView.center = view.center
        contentView.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin]
        
        contentView.addSubview(loginField)
        contentView.addSubview(passwordField)
        contentView.addSubview(loginButton)
        view.addSubview(contentView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "登录"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(actionClose))
        view.backgroundColor = UIColor.whiteColor()
        
        setupViews()
        
        OAuth2.shared.delegate = self
        
        textFieldDidChanged()
        
        YYKeyboardManager.defaultManager().addObserver(self)
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidChanged() {
        if let username = loginField.text, let password = passwordField.text where username != "" && password != "" {
            loginButton.enabled = true
        } else {
            loginButton.enabled = false
        }
    }
}

extension SignInViewController: YYKeyboardObserver {
    func keyboardChangedWithTransition(transition: YYKeyboardTransition) {
        UIView.animateWithDuration(transition.animationDuration, delay: 0, options: transition.animationOption, animations: {
            var y: CGFloat = 0
            if transition.toVisible {
                y = (self.view.frame.height - transition.toFrame.height) * 0.5
            } else {
                y = self.view.frame.height * 0.5
            }
            self.contentView.center = CGPoint(x: self.view.frame.width * 0.5, y: y)
        }, completion: nil)
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
        dismissViewControllerAnimated(false, completion: {
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
