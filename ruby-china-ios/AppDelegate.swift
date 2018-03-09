import UIKit
import Turbolinks
import SafariServices
import WebKit
import SideMenu
import AMScrollingNavbar

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private(set) var unreadNotificationCount: Int = 0

    fileprivate lazy var rootViewController: RootViewController = {
        return RootViewController()
    }()

    fileprivate func initAppearance() {
        UINavigationBar.appearance().theme = true
        UITabBar.appearance().theme = true
        UIToolbar.appearance().theme = true

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: BLACK_COLOR], for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: PRIMARY_COLOR], for: .selected)
    }

    fileprivate var becomeActivePage = String()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        initAppearance()
        let navigationController = ThemeNavigationController(rootViewController: rootViewController)
        navigationController.view.backgroundColor = UIColor.white
        window?.rootViewController = navigationController

        let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()

        if let launchOptions = launchOptions, let _ = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] {
            // 点击推送消息启动的应用
            rootViewController.displayNotifications()
        }

        return true
    }

    // MARK: - 通知相关

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString: String = deviceToken.reduce("", {$0 + String(format: "%02.2hhX", $1)})
        print("DeviceToken \(deviceTokenString)")

        OAuth2.shared.deviceToken = deviceTokenString
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState == .inactive {
            // 应用在后台时，点击系推送消息启动应用
            rootViewController.displayNotifications()
        } else {
            refreshUnreadNotificationCount()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        refreshUnreadNotificationCount()
    }

    func refreshUnreadNotificationCount() {
        if OAuth2.shared.isLogined {
            OAuth2.shared.refreshUnreadNotifications({ [weak self] (count) in
                self?.setBadge(count)
            })
        } else {
            setBadge(0)
        }
    }

    func setBadge(_ count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count > 0 ? count : 0
        if unreadNotificationCount != count {
            unreadNotificationCount = count
            NotificationCenter.default.post(name: NSNotification.Name.userUnreadNotificationChanged, object: nil)
        }
    }
}

extension UINavigationBar {
    var theme: Bool {
        get { return false }
        set {
            self.barStyle = .default
            self.isTranslucent = false
            self.tintColor = PRIMARY_COLOR
            self.barTintColor = NAVBAR_BG_COLOR

            self.backIndicatorImage = UIImage(named: "back")
            self.backIndicatorTransitionMaskImage = UIImage(named: "back")
        }
    }
}

extension UIToolbar {
    var theme: Bool {
        get { return false }
        set {
            self.barStyle = .default
            self.tintColor = PRIMARY_COLOR
            self.barTintColor = TABBAR_BG_COLOR
            
            let navBorder = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 1))
            navBorder.backgroundColor = NAVBAR_BORDER_COLOR
            self.addSubview(navBorder)
        }
    }
}

extension UITabBar {
    var theme: Bool {
        get { return false }
        set {
            self.barStyle = .default
            self.isTranslucent = false

            self.tintColor = PRIMARY_COLOR
            self.barTintColor = TABBAR_BG_COLOR

            // Border top line
            let navBorder = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 1))
            navBorder.backgroundColor = NAVBAR_BORDER_COLOR
            self.addSubview(navBorder)
        }
    }
}

extension UIApplication {
    /// 获取应用主UINavigationController
    static var appNavigationController: ScrollingNavigationController {
        return UIApplication.shared.keyWindow!.rootViewController as! ScrollingNavigationController
    }
}
