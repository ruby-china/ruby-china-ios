import UIKit
import Turbolinks
import SafariServices
import WebKit
import SideMenu
import AMScrollingNavbar
import XCGLogger

let log: XCGLogger = {
    let log = XCGLogger.default
    #if DEBUG
        log.outputLevel = .debug
        log.levelDescriptions[.verbose] = "🗯"
        log.levelDescriptions[.debug] = "🔹"
        log.levelDescriptions[.info] = "ℹ️"
        log.levelDescriptions[.warning] = "⚠️"
        log.levelDescriptions[.error] = "‼️"
        log.levelDescriptions[.severe] = "💣"
    #else
        log.outputLevel = .none
    #endif
    return log
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    fileprivate lazy var rootViewController: RootViewController = {
        return RootViewController()
    }()

    fileprivate func initAppearance() {
        UINavigationBar.appearance().theme = true
        UITabBar.appearance().theme = true
        UIToolbar.appearance().theme = true

        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: BLACK_COLOR], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: PRIMARY_COLOR], for: .selected)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initAppearance()
        let navigationController = ThemeNavigationController(rootViewController: rootViewController)
        navigationController.view.backgroundColor = UIColor.white
        window?.rootViewController = navigationController

        let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()

        if let launchOptions = launchOptions, let _ = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] {
            // 点击推送消息启动的应用
            rootViewController.displayNotifications()
        }

        return true
    }

    // MARK: - 通知相关

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString: String = deviceToken.reduce("", {$0 + String(format: "%02.2hhX", $1)})
        log.info("DeviceToken \(deviceTokenString)")

        OAuth2.shared.deviceToken = deviceTokenString
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if application.applicationState == .inactive {
            // 应用在后台时，点击系推送消息启动应用
            rootViewController.displayNotifications()
        } else {
            OAuth2.shared.refreshUnreadNotifications()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        OAuth2.shared.refreshUnreadNotifications()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = OAuth2.shared.unreadNotificationCount
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
