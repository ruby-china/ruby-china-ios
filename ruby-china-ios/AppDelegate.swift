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
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: BLACK_LIGHT], forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: BLACK], forState: .Selected)
        UITabBar.appearance().tintColor = BLACK
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: BLACK], forState: .Normal)
    }
    
    private var becomeActivePage = String()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        initAppearance()
        window?.rootViewController = rootViewController
        
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
        
        DeviseService.create(deviceTokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFailToRegisterForRemoteNotificationsWithError", error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        becomeActivePage = "notifications"
        
        OAuth2.shared.refreshUnreadNotifications({ (count) in
            self.setBadge(count)
        });
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if (becomeActivePage == "notifications") {
            becomeActivePage = ""
            application.applicationIconBadgeNumber = 0
            rootViewController.selectedIndex = (rootViewController.viewControllers?.count)!
        } else {
            OAuth2.shared.refreshUnreadNotifications({ (count) in
                self.setBadge(count)
            });
        }
    }
    
    func setBadge(count: Int) {
        if (count > 0) {
            UIApplication.sharedApplication().applicationIconBadgeNumber = count
            self.rootViewController.tabBar.items?.last?.badgeValue = "\(count)"
        } else {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            self.rootViewController.tabBar.items?.last?.badgeValue = nil
        }
    }
    
}
