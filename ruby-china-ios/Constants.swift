import UIKit

#if DEBUG
    let ROOT_URL = "http://localhost:3000"
    let OAUTH_CLIENT_ID = "1b034acf"
    let OAUTH_SECRET = "2d44bae75daaa88f2b8226a0205318b6ccf79b09e80fbfb461d191001d7b3c7b"
#else
    let ROOT_URL = "https://ruby-china.org"
    let OAUTH_CLIENT_ID = "1b034acf"
    let OAUTH_SECRET = "2d44bae75daaa88f2b8226a0205318b6ccf79b09e80fbfb461d191001d7b3c7b"
#endif

let COPYRIGHT_URL = "https://github.com/ruby-china/ruby-china-ios/blob/master/copyright.md"
let PROJECT_URL = "https://github.com/ruby-china/ruby-china-ios"

let USER_AGENT = "turbolinks-app, ruby-china, official"

let BLACK = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.0)
let BLACK_LIGHT = UIColor.grayColor()

// Blue Theme
//let NAVBAR_BG_COLOR = UIColor(red:0.25, green:0.32, blue:0.71, alpha:1.0)
//let NAVBAR_BORDER_COLOR = UIColor(red:0.25, green:0.32, blue:0.61, alpha:1.0)
//let NAVBAR_TINT_COLOR = UIColor(red:1.00, green:1.00, blue:0.93, alpha:1.0)
//let SEGMENT_BG_COLOR = UIColor(red:0.10, green:0.14, blue:0.39, alpha:1.0)
//let TABBAR_BG_COLOR = UIColor(red:0.88, green:0.96, blue:1.00, alpha:1.0)

// Red Theme
let PRIMARY_COLOR = UIColor(red: 0.91, green: 0.33, blue: 0.23, alpha: 1.0)
let NAVBAR_BG_COLOR = PRIMARY_COLOR
let SIDEMENU_NAVBAR_BG_COLOR = UIColor(red: 0.74, green: 0.24, blue: 0.13, alpha: 1.0)
let NAVBAR_BORDER_COLOR = UIColor(red: 0.72, green: 0.30, blue: 0.26, alpha: 1.0)
let NAVBAR_TINT_COLOR = UIColor(red: 1.00, green: 1.00, blue: 0.98, alpha: 1.0)
let SEGMENT_BG_COLOR = UIColor(red: 0.23, green: 0.05, blue: 0.02, alpha: 1.0)
let TABBAR_BG_COLOR = UIColor(red: 1.00, green: 0.98, blue: 0.96, alpha: 1.0)

// - 消息定义
/// 显示侧栏
let NOTICE_DISPLAY_MENU = "NOTICE_DISPLAY_MENU"
/// 侧栏菜单项被点击
let NOTICE_MENU_CLICKED = "NOTICE_MENU_CLICKED"
/// 侧栏菜单项被点击通知 userInfo中的信息
let NOTICE_MENU_CLICKED_PATH = "PATH"

/// 登录成功
let NOTICE_SIGNIN_SUCCESS = "NOTICE_SIGNIN_SUCCESS"

/// 登录用户发生了变化
let USER_CHANGED = "USER_CHANGED"
