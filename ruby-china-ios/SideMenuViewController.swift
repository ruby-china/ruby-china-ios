//
//  SideMenuViewController.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/23.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {
    let menuItems = ["讨论区", "优质话题", "最近发布", "招聘"]
    let menuItemPaths = ["/topics", "/topics/popular", "/topics/last", "/jobs"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard tableView.backgroundView == nil else {
            return
        }
        
        // Set up a cool background image for demo purposes
        let imageView = UIImageView(image: UIImage(named: "Appicon"))
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.01)
        tableView.backgroundView = imageView
        
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        cell.textLabel!.text = menuItems[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let path = menuItemPaths[indexPath.row]
        
        NSNotificationCenter.defaultCenter().postNotificationName("menuClicked", object: self, userInfo: ["path": path])
    }
}