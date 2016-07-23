//
//  ViewController.swift
//  TurbolinksTest
//
//  Created by Jason Lee on 16/7/22.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import Turbolinks

class WebViewController: VisitableViewController {
    var navController = ApplicationController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController = self.navigationController as! ApplicationController
        
        
//        if (navigationItem) {
            navigationItem.leftBarButtonItem = navController.menuButton
//        }
        navigationItem.rightBarButtonItem = navController.notificationsButton
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func visitableDidRender() {
        title = formatTitle((visitableView.webView?.title)!)
    }
    
    func formatTitle(title: String) -> String {
        // ...
        return title.stringByReplacingOccurrencesOfString(" · Ruby China", withString: "")
    }
}

