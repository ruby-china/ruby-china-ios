import UIKit
import Turbolinks
import SafariServices
import WebKit
import SideMenu


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private lazy var rootViewController: RootViewController = {
        return RootViewController()
    }()
    
    private func initAppearance() {
        UINavigationBar.appearance().theme = true
        UISegmentedControl.appearance().theme = true
        
        UITabBar.appearance().tintColor = BLACK
    }
    
    private var becomeActivePage = String()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        initAppearance()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.view.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = navigationController
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // MARK: - 通知相关
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let characterSet: NSCharacterSet = NSCharacterSet(charactersInString: "<>")
        
        let deviceTokenString: String = (deviceToken.description as NSString)
            .stringByTrimmingCharactersInSet(characterSet)
            .stringByReplacingOccurrencesOfString( " ", withString: "") as String
        
        print("DeviceToken \(deviceTokenString)")
        
        NSUserDefaults.standardUserDefaults().setValue(deviceTokenString, forKey: "deviceToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        if OAuth2.shared.isLogined {
            DeviseService.create(deviceTokenString)
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFailToRegisterForRemoteNotificationsWithError", error)
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("deviceToken")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        becomeActivePage = "notifications"
        
        refreshUnreadNotificationCount()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if (becomeActivePage == "notifications") {
            becomeActivePage = ""
            application.applicationIconBadgeNumber = 0
            rootViewController.selectedIndex = (rootViewController.viewControllers?.count)!
        } else {
            refreshUnreadNotificationCount()
        }
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
    
    private func setBadge(count: Int) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = count > 0 ? count : 0
        self.rootViewController.tabBar.items?.last?.badgeValue = count > 0 ? "\(count)" : nil
    }
}

extension UINavigationBar {
    var theme : Bool {
        get { return false }
        set {
            self.barStyle = .Black
            self.translucent = false
            self.tintColor = UIColor.whiteColor()
            self.barTintColor = RED
            
            self.layer.shadowOffset = CGSizeMake(0, 1)
            self.layer.shadowRadius = 1.0
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowOpacity = 0.20
        }
    }
}

extension UISegmentedControl {
    var theme : Bool {
        get { return false }
        set {
            self.tintColor = RED_DARK
        }
    }
}
