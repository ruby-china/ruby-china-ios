//
//  TopicCell.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/12.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import FontAwesome_swift

private let kContentPadding = UIEdgeInsetsMake(15, 25, 15, 25)
private let kTitleTextSize: CGFloat = 16
private let kTextSize: CGFloat = 14
private let kTextFont = UIFont.systemFont(ofSize: kTextSize, weight: UIFont.Weight.regular)
private let kTitleTextFont = UIFont.systemFont(ofSize: kTitleTextSize, weight: UIFont.Weight.medium)
private let kAvatarSize = CGSize(width: 18, height: 18)
private let kAvatarColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
private let kNodeColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)

class TopicCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(repliesCountLabel)
        contentView.addSubview(nodeButton)
        contentView.addSubview(userNameButton)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var data: Topic? {
        didSet {
            if let data = data {
                let avatarSize = CGSize(width: kAvatarSize.width * 2, height: kAvatarSize.height * 2)
                let imageProcessor = RoundCornerImageProcessor(cornerRadius: avatarSize.width / 2.0, targetSize: avatarSize)
                avatarImageView.kf.setImage(with: data.user.avatarUrl, options: [
                    .processor(imageProcessor),
                    .transition(ImageTransition.fade(0.5))
                ])
                
                titleLabel.attributedText = titleAttributedText(data)
                repliesCountLabel.text = data.repliesCount > 0 ? "\(data.repliesCount)" : nil
                nodeButton.setTitle(data.nodeName, for: UIControlState())
                userNameButton.setTitle(data.user.login, for: UIControlState())
            } else {
                avatarImageView.kf.setImage(with: nil)
                titleLabel.attributedText = nil
                repliesCountLabel.text = nil
                nodeButton.setTitle(nil, for: UIControlState())
                userNameButton.setTitle(nil, for: UIControlState())
            }
        }
    }
    
    var onUserClick: ((_ data: Topic?) -> ())? {
        didSet {
            avatarImageView.isUserInteractionEnabled = onUserClick != nil
            userNameButton.isEnabled = onUserClick != nil
        }
    }
    var onNodeClick: ((_ data: Topic?) -> ())? {
        didSet {
            nodeButton.isEnabled = onNodeClick != nil
        }
    }
    
    fileprivate lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userAction)))
        return view
    }()
    fileprivate lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(white: 0.13, alpha: 1)
        view.numberOfLines = 0
        return view
    }()
    fileprivate lazy var repliesCountLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(white: 0.4, alpha: 1)
        view.font = kTextFont
        view.textAlignment = .right
        return view
    }()
    fileprivate lazy var nodeButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.font = kTextFont
        view.setTitleColor(kNodeColor, for: UIControlState())
        view.addTarget(self, action: #selector(nodeAction), for: .touchUpInside)
        view.isEnabled = false
        return view
    }()
    fileprivate lazy var userNameButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.font = kTextFont
        view.setTitleColor(kAvatarColor, for: UIControlState())
        view.addTarget(self, action: #selector(userAction), for: .touchUpInside)
        view.isEnabled = false
        return view
    }()
    
}

// MARK: - action
@objc
extension TopicCell {
    
    func userAction() {
        if let action = onUserClick {
            action(data)
        }
    }
    
    func nodeAction() {
        if let action = onNodeClick {
            action(data)
        }
    }
    
}

// MARK: - private

extension TopicCell {
    
    fileprivate func setupConstraints() {
        avatarImageView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().inset(kContentPadding)
            make.size.equalTo(kAvatarSize)
        }
        userNameButton.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp.right).offset(6)
            make.centerY.equalTo(avatarImageView)
        }
        nodeButton.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview().inset(kContentPadding)
            make.centerY.equalTo(avatarImageView)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView)
            make.right.equalTo(repliesCountLabel.snp.left)
            make.top.equalTo(avatarImageView.snp.bottom).offset(5)
            make.bottom.equalToSuperview().inset(kContentPadding)
        }
        repliesCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel)
            make.right.equalToSuperview().inset(kContentPadding)
            make.width.equalTo(30)
        }
    }
    
    fileprivate func titleAttributedText(_ data: Topic) -> NSAttributedString {
        let attributes = [NSAttributedStringKey.font : kTitleTextFont]
        let attributedString = NSMutableAttributedString(string: data.title, attributes: attributes)
        
        func addIcon(name fontAwesomeName: FontAwesome, color: UIColor) {
            let attributes = [NSAttributedStringKey.font : UIFont.fontAwesome(ofSize: kTitleTextSize),
                              NSAttributedStringKey.foregroundColor : color]
            let diamondString = "  \(String.fontAwesomeIcon(name: fontAwesomeName))"
            let diamondAttributed = NSAttributedString(string: diamondString, attributes: attributes)
            attributedString.append(diamondAttributed)
        }
        
        if data.excellent {
            addIcon(name: .diamond, color: kNodeColor)
        }
        if let _ = data.closedAt {
            addIcon(name: .check, color: kNodeColor)
        }
        
        return attributedString
    }
    
}
