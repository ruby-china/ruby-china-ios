import UIKit
import Turbolinks
import SafariServices
import WebKit
import SideMenu


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var topicsController = ApplicationController()
    var popularController = ApplicationController()
    var favoritesController = ApplicationController()
    var jobsController = ApplicationController()
    var notificationsController = ApplicationController()
    
    var tabBarController = UITabBarController()
    
    var homeButton = UITabBarItem()
    var popularButton = UITabBarItem()
    var jobsButton = UITabBarItem()
    var favoritesButton = UITabBarItem()
    var notificationsButton = UITabBarItem()
    
    var session = Session()
    var becomeActivePage = String()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        window?.rootViewController = navigationController
        initAppearance()
        setupTabbar()
        
        application.delegate = self
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func setupTabbar() {
        window?.rootViewController = tabBarController
        
        homeButton = UITabBarItem(title: "讨论", image: UIImage(named: "topic"), tag: 0)
        popularButton = UITabBarItem(title: "精选", image: UIImage(named: "popular"), tag: 1)
        jobsButton = UITabBarItem(title: "招聘", image: UIImage(named: "jobs"), tag: 2)
        favoritesButton = UITabBarItem(title: "收藏", image: UIImage(named: "favorites"), tag: 3)
        notificationsButton = UITabBarItem(title: "通知", image: UIImage(named: "notifications"), tag: 99)
        
        topicsController.rootPath = "/topics"
        topicsController.tabBarItem = homeButton
        
        popularController.rootPath = "/topics/popular"
        popularController.tabBarItem = popularButton
        
        jobsController.rootPath = "/jobs"
        jobsController.tabBarItem = jobsButton
        
        favoritesController.rootPath = "/topics/favorites"
        favoritesController.tabBarItem = favoritesButton
        
        notificationsController.rootPath = "/notifications"
        notificationsController.tabBarItem = notificationsButton
        
        tabBarController.viewControllers = [topicsController, favoritesController, notificationsController]
    }
    
    
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
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if (becomeActivePage == "notifications") {
            becomeActivePage = ""
            application.applicationIconBadgeNumber = 0
            tabBarController.selectedIndex = (tabBarController.viewControllers?.count)!
//            topicsController.actionNotifications()
        }
    }
    
    func initAppearance() {
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: BLACK_LIGHT], forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: BLACK], forState: .Selected)
        
        tabBarController.tabBar.tintColor = BLACK
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: BLACK], forState: .Normal)
    }
}

extension AppDelegate: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
    }
}
