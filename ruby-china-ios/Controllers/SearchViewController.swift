//
//  SearchViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/22.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class SearchViewController: WebViewController {
    
    fileprivate let searchPath = "/search?q="
    
    fileprivate lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.delegate = self
        if let searchField = view.value(forKey: "searchField") as? UITextField {
            searchField.textColor = PRIMARY_COLOR
            searchField.backgroundColor = NAVBAR_BG_COLOR
            searchField.attributedPlaceholder = NSAttributedString(string: "search placeholder".localized, attributes: [NSAttributedStringKey.foregroundColor: searchField.textColor!])
            // 修改左侧搜索图标颜色
            if let searchImageView = searchField.leftView as? UIImageView, let searchImage = searchImageView.image {
                view.setImage(searchImage.imageWithColor(searchField.textColor!), for: .search, state: UIControlState())
            }
            // 修改右侧清除图标颜色
            if let clearButton = searchField.value(forKey: "_clearButton") as? UIButton, let clearImage = clearButton.image(for: UIControlState()) {
                view.setImage(clearImage.imageWithColor(searchField.textColor!), for: .clear, state: UIControlState())
            }
        }
        return view
    }()
    
    var onCancel: ((SearchViewController) -> ())?
    
    override func viewDidLoad() {
        currentPath = searchPath
        super.viewDidLoad()
        navigationItem.titleView = searchBar
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonAction))
        navigationItem.rightBarButtonItem = cancelItem
    }
    
    override func visitableDidRender() {
        super.visitableDidRender()
        visitableView.webView?.isHidden = currentPath == searchPath
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if searchBar.text == nil || searchBar.text!.count <= 0 {
            searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let text = searchBar.text ?? ""
        let allowedQueryParamAndKey = CharacterSet(charactersIn: ";/?:@&=+$, ").inverted
        if let encodeText = text.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) {
            currentPath = "\(searchPath)\(encodeText)"
            reloadVisitable()
        }
    }
    
}

// MARK: - action
@objc
extension SearchViewController {
    
    func cancelButtonAction() {
        onCancel?(self)
    }
    
}
