import UIKit
import WebKit
import YYKeyboardManager

protocol SignInViewControllerDelegate: class {
    func signInViewControllerDidAuthenticate(_ sender: SignInViewController)
}

class SignInViewController: UIViewController {
    weak var delegate: SignInViewControllerDelegate?
    var onDidAuthenticate: ((_ sender: SignInViewController) -> Void)?
    
    @discardableResult static func show() -> SignInViewController {
        let controller = SignInViewController()
        let navController = ThemeNavigationController(rootViewController: controller)
        UIApplication.currentViewController()?.present(navController, animated: true, completion: nil)
        return controller
    }
    
    fileprivate var webView: WKWebView!
    fileprivate var appNameLabel: UILabel!
    fileprivate var contentView: UIView!
    fileprivate var loginField: RBTextField!
    fileprivate var passwordField: RBTextField!
    fileprivate var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "sign up".localized, style: .plain, target: self, action: #selector(actionSignup))
        view.backgroundColor = UIColor.white
        
        setupViews()
        
        OAuth2.shared.delegate = self
        
        textFieldDidChanged()
        
        YYKeyboardManager.default().add(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let text = loginField.text , text != "" {
            passwordField.becomeFirstResponder()
        } else {
            loginField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loginField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
}

// MARK: - Actions
@objc
extension SignInViewController {
    func actionLogin() {
        if loginButton.isEnabled {
            loginField.resignFirstResponder()
            passwordField.resignFirstResponder()
            
            RBHUD.progress(nil)
            OAuth2.shared.login(loginField.text!, password: passwordField.text!)
        }
    }
    
    func actionClose() {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidChanged() {
        if let username = loginField.text, let password = passwordField.text , username != "" && password != "" {
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
    func actionSignup() {
        SignUpViewController.show()
    }
}

// MARK: - private

extension SignInViewController {
    
    fileprivate func setupViews() {
        webView = WKWebView(frame: view.bounds, configuration: TurbolinksSessionLib.shared.webViewConfiguration)
        webView.frame.origin.x = -webView.frame.width;
        webView.navigationDelegate = self
        
        appNameLabel = UILabel()
        appNameLabel.text = "Ruby China"
        appNameLabel.textColor = PRIMARY_COLOR
        appNameLabel.font = UIFont.boldSystemFont(ofSize: 40)
        appNameLabel.sizeToFit()
        
        let margin = CGFloat(20)
        
        loginField = RBTextField(frame: CGRect(x: margin, y: 0, width: view.frame.width - margin * 2, height: 44))
        loginField.clearButtonMode = .whileEditing
        loginField.autocorrectionType = .no
        loginField.keyboardType = .emailAddress
        loginField.autocapitalizationType = .none
        loginField.placeholder = "login name".localized
        loginField.delegate = self
        loginField.returnKeyType = .next
        loginField.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        loginField.text = UserDefaults.standard.string(forKey: "loginName")
        
        passwordField = RBTextField(frame: CGRect(x: margin, y: loginField.frame.maxY + margin, width: view.frame.width - margin * 2, height: 44))
        passwordField.placeholder = "password".localized
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
        passwordField.returnKeyType = .done
        passwordField.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
        
        loginButton = UIButton(frame: CGRect(x: margin, y: passwordField.frame.maxY + margin, width: view.frame.width - margin * 2, height: 44))
        loginButton.setTitle("sign in".localized, for: .normal)
        loginButton.setBackgroundImage(UIImage.fromColor(NAVBAR_BG_COLOR), for: .normal)
        loginButton.setBackgroundImage(UIImage.fromColor(NAVBAR_BORDER_COLOR), for: .highlighted)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.addTarget(self, action: #selector(actionLogin), for: .touchDown)
        
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: loginButton.frame.maxY))
        contentView.center = view.center
        contentView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        
        contentView.addSubview(loginField)
        contentView.addSubview(passwordField)
        contentView.addSubview(loginButton)
        view.addSubview(webView)
        view.addSubview(appNameLabel)
        view.addSubview(contentView)
        
        refreshAppNameLabelCenter()
    }
    
    fileprivate func refreshAppNameLabelCenter() {
        appNameLabel.center = CGPoint(x: contentView.center.x, y: contentView.frame.minY / 2.0)
    }
    
}

extension SignInViewController: YYKeyboardObserver {
    func keyboardChanged(with transition: YYKeyboardTransition) {
        UIView.animate(withDuration: transition.animationDuration, delay: 0, options: transition.animationOption, animations: {
            var y: CGFloat = 0
            if transition.toVisible.boolValue {
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    func oauth2DidLoginSuccessed(_ accessToken: String) {
        log.info(["API Login successed", accessToken])
        
        var request = URLRequest(url: URL(string: ROOT_URL)!)
        request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        webView.load(request)
    }
    
    func oauth2DidLoginFailed(_ error: NSError) {
        log.error(["Login failed", error])
        
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

extension SignInViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        log.info("webView login successed")
        RBHUD.progressHidden()
        UserDefaults.standard.setValue(loginField.text, forKey: "loginName")
        UserDefaults.standard.synchronize()

        dismiss(animated: false, completion: {
            self.delegate?.signInViewControllerDidAuthenticate(self)
            self.onDidAuthenticate?(self)
            NotificationCenter.default.post(name: .userSignin, object: nil)
        })
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        log.error(["webView login failed", error])

        RBHUD.progressHidden()
        RBHUD.error((error as NSError).localizedDescription)
    }
}
