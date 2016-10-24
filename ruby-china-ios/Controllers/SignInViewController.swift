import UIKit
import WebKit
import YYKeyboardManager

protocol SignInViewControllerDelegate: class {
    func signInViewControllerDidAuthenticate(sender: SignInViewController)
}

class SignInViewController: UIViewController {
    weak var delegate: SignInViewControllerDelegate?
    var onDidAuthenticate: ((sender: SignInViewController) -> Void)?
    
    static func show() -> SignInViewController {
        let controller = SignInViewController()
        let navController = ThemeNavigationController(rootViewController: controller)
        UIApplication.currentViewController()?.presentViewController(navController, animated: true, completion: nil)
        return controller
    }
    
    private var appNameLabel: UILabel!
    private var contentView: UIView!
    private var loginField: RBTextField!
    private var passwordField: RBTextField!
    private var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(actionClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "sign up".localized, style: .Plain, target: self, action: #selector(actionSignup))
        view.backgroundColor = UIColor.whiteColor()
        
        setupViews()
        
        OAuth2.shared.delegate = self
        
        textFieldDidChanged()
        
        YYKeyboardManager.defaultManager().addObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let text = loginField.text where text != "" {
            passwordField.becomeFirstResponder()
        } else {
            loginField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        loginField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
}

// MARK: - Actions

extension SignInViewController {
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
    
    func actionSignup() {
        let url = NSURL(string: "\(ROOT_URL)/account/sign_up")!
        UIApplication.sharedApplication().openURL(url)
    }
}

// MARK: - private

extension SignInViewController {
    
    private func setupViews() {
        appNameLabel = UILabel()
        appNameLabel.text = "Ruby China"
        appNameLabel.textColor = PRIMARY_COLOR
        appNameLabel.font = UIFont.boldSystemFontOfSize(40)
        appNameLabel.sizeToFit()
        
        let margin = CGFloat(20)
        
        loginField = RBTextField(frame: CGRectMake(margin, 0, view.frame.width - margin * 2, 44))
        loginField.clearButtonMode = .WhileEditing
        loginField.autocorrectionType = .No
        loginField.keyboardType = .EmailAddress
        loginField.autocapitalizationType = .None
        loginField.placeholder = "login name".localized
        loginField.delegate = self
        loginField.returnKeyType = .Next
        loginField.addTarget(self, action: #selector(textFieldDidChanged), forControlEvents: UIControlEvents.EditingChanged)
        loginField.text = NSUserDefaults.standardUserDefaults().stringForKey("loginName")
        
        passwordField = RBTextField(frame: CGRectMake(margin, loginField.frame.maxY + margin, view.frame.width - margin * 2, 44))
        passwordField.placeholder = "password".localized
        passwordField.secureTextEntry = true
        passwordField.delegate = self
        passwordField.returnKeyType = .Done
        passwordField.addTarget(self, action: #selector(textFieldDidChanged), forControlEvents: UIControlEvents.EditingChanged)
        
        loginButton = UIButton(frame: CGRectMake(margin, passwordField.frame.maxY + margin, view.frame.width - margin * 2, 44))
        loginButton.setTitle("sign in".localized, forState: .Normal)
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
        view.addSubview(appNameLabel)
        view.addSubview(contentView)
        
        refreshAppNameLabelCenter()
    }
    
    private func refreshAppNameLabelCenter() {
        appNameLabel.center = CGPoint(x: contentView.center.x, y: contentView.frame.minY / 2.0)
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
            self.refreshAppNameLabelCenter()
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
        NSUserDefaults.standardUserDefaults().setValue(loginField.text, forKey: "loginName")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        print("Login successed", OAuth2.shared.accessToken)
        dismissViewControllerAnimated(false, completion: {
            self.delegate?.signInViewControllerDidAuthenticate(self)
            self.onDidAuthenticate?(sender: self)
            NSNotificationCenter.defaultCenter().postNotificationName(NOTICE_SIGNIN_SUCCESS, object: nil)
        })
    }
    
    func oauth2DidLoginFailed(error: NSError) {
        print("Login failed", error)
        
        var errorMessage = ""
        if error.code == 3 {
            errorMessage = "login error message".localized
        } else {
            errorMessage = error.localizedDescription
            if let failureReason = error.localizedFailureReason {
                errorMessage += "\n" + failureReason
            }
        }
        
        RBHUD.progressHidden()
        RBHUD.error(errorMessage)
    }
}
