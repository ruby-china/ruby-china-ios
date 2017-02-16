import UIKit
import Turbolinks
import SafariServices
import WebKit
import SideMenu

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    fileprivate lazy var rootViewController: RootViewController = {
        return RootViewController()
    }()

    fileprivate func initAppearance() {
        UINavigationBar.appearance().theme = true
        UITabBar.appearance().theme = true

        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: BLACK_COLOR], for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: PRIMARY_COLOR], for: .selected)
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
            OAuth2.shared.refreshUnreadNotifications({ [weak self](count) in
                self?.setBadge(count)
            })
        } else {
            setBadge(0)
        }
    }

    func setBadge(_ count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count > 0 ? count : 0
        self.rootViewController.tabBar.items?.last?.badgeValue = count > 0 ? "\(count)" : nil
    }
}

extension UINavigationBar {
    var theme: Bool {
        get { return false }
        set {
            self.barStyle = .black
            self.isTranslucent = false
            self.tintColor = NAVBAR_TINT_COLOR
            self.barTintColor = NAVBAR_BG_COLOR

            self.backIndicatorImage = UIImage(named: "back")
            self.backIndicatorTransitionMaskImage = UIImage(named: "back")
        }
    }

    var bottomBorder: Bool {
        get { return false }
        set {
            // Border bottom line
            let navBorder = UIView(frame: CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1))
            navBorder.backgroundColor = NAVBAR_BORDER_COLOR
            self.addSubview(navBorder)

            // Shadow
            self.layer.shadowOffset = CGSize(width: 0, height: 0.5)
            self.layer.shadowRadius = 1
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.05
        }
    }
}

extension UITabBar {
    var theme: Bool {
        get { return false }
        set {
            self.barStyle = .black
            self.isTranslucent = false

            self.tintColor = PRIMARY_COLOR
            self.barTintColor = TABBAR_BG_COLOR

            // Border top line
            let navBorder = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 1))
            navBorder.backgroundColor = UIColor(red:0.93, green:0.92, blue:0.91, alpha:1.0)
            self.addSubview(navBorder)
        }
    }
}

extension UIApplication {
    /// 获取应用主UINavigationController
    static var appNavigationController: UINavigationController {
        return UIApplication.shared.keyWindow!.rootViewController as! UINavigationController
    }
}
