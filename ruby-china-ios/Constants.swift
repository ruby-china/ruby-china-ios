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

let PROJECT_URL = "https://github.com/ruby-china/ruby-china-ios"

let USER_AGENT = "turbolinks-app, ruby-china, official"

let BLACK = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
let BLACK_LIGHT = UIColor.grayColor()
let RED = UIColor(red:0.96, green:0.26, blue:0.21, alpha:1.0)

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