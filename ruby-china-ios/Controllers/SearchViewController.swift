//
//  SearchViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/22.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class SearchViewController: WebViewController {
    
    private let searchPath = "/search?q="
    
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.delegate = self
        if let searchField = view.valueForKey("searchField") as? UITextField {
            searchField.textColor = NAVBAR_TINT_COLOR
            searchField.backgroundColor = NAVBAR_BG_COLOR
            searchField.attributedPlaceholder = NSAttributedString(string: "search placeholder".localized, attributes: [NSForegroundColorAttributeName: searchField.textColor!])
            // 修改左侧搜索图标颜色
            if let searchImageView = searchField.leftView as? UIImageView, searchImage = searchImageView.image {
                view.setImage(searchImage.imageWithColor(searchField.textColor!), forSearchBarIcon: .Search, state: .Normal)
            }
            // 修改右侧清除图标颜色
            if let clearButton = searchField.valueForKey("_clearButton") as? UIButton, clearImage = clearButton.imageForState(.Normal) {
                view.setImage(clearImage.imageWithColor(searchField.textColor!), forSearchBarIcon: .Clear, state: .Normal)
            }
            
        }
        return view
    }()
    
    override func viewDidLoad() {
        currentPath = searchPath
        super.viewDidLoad()
        navigationItem.titleView = searchBar
    }
    
    override func visitableDidRender() {
        super.visitableDidRender()
        visitableView.webView?.hidden = currentPath == searchPath
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if searchBar.text == nil || searchBar.text!.characters.count <= 0 {
            searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let text = searchBar.text ?? ""
        let allowedQueryParamAndKey = NSCharacterSet(charactersInString: ";/?:@&=+$, ").invertedSet
        if let encodeText = text.stringByAddingPercentEncodingWithAllowedCharacters(allowedQueryParamAndKey) {
            currentPath = "\(searchPath)\(encodeText)"
            reloadVisitable()
        }
    }
}
