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

private let kContentPadding = UIEdgeInsetsMake(10, 15, 10, 15)
private let kTitleTextSize: CGFloat = 14
private let kTextSize: CGFloat = 12
private let kTextFont = UIFont.systemFont(ofSize: kTextSize)
private let kTitleTextFont = UIFont.systemFont(ofSize: kTitleTextSize)
private let kAvatarSize = CGSize(width: 32, height: 32)
private let kButtonTitleColor = UIColor(red: 171.0 / 255.0, green: 168.0 / 255.0, blue: 166.0 / 255.0, alpha: 1)

class TopicCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(repliesCountLabel)
        contentView.addSubview(nodeButton)
        contentView.addSubview(separateLabel)
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
    
    var onUserClick: ((_ data: Topic?) -> ())?
    var onNodeClick: ((_ data: Topic?) -> ())?
    
    fileprivate lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
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
        view.setTitleColor(kButtonTitleColor, for: UIControlState())
        view.addTarget(self, action: #selector(nodeAction), for: .touchUpInside)
        return view
    }()
    fileprivate lazy var separateLabel: UILabel = {
        let view = UILabel()
        view.font = kTextFont
        view.textColor = kButtonTitleColor
        view.text = " • "
        return view
    }()
    fileprivate lazy var userNameButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.font = kTextFont
        view.setTitleColor(kButtonTitleColor, for: UIControlState())
        view.addTarget(self, action: #selector(userAction), for: .touchUpInside)
        return view
    }()
    
}

// MARK: - action

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
        repliesCountLabel.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview().inset(kContentPadding)
            make.width.equalTo(30)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp.right).offset(10)
            make.top.equalToSuperview().inset(kContentPadding)
            make.right.equalTo(repliesCountLabel.snp.left)
        }
        nodeButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }
        separateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nodeButton.snp.right)
            make.centerY.equalTo(nodeButton)
        }
        userNameButton.snp.makeConstraints { (make) in
            make.left.equalTo(separateLabel.snp.right)
            make.centerY.equalTo(nodeButton)
        }
    }
    
    fileprivate func titleAttributedText(_ data: Topic) -> NSAttributedString {
        let attributes = [NSFontAttributeName : kTitleTextFont]
        let attributedString = NSMutableAttributedString(string: data.title, attributes: attributes)
        
        func addIcon(name fontAwesomeName: FontAwesome, color: UIColor) {
            let attributes = [NSFontAttributeName : UIFont.fontAwesome(ofSize: kTitleTextSize),
                              NSForegroundColorAttributeName : color]
            let diamondString = " \(String.fontAwesomeIcon(name: fontAwesomeName))"
            let diamondAttributed = NSAttributedString(string: diamondString, attributes: attributes)
            attributedString.append(diamondAttributed)
        }
        
        if let _ = data.suggestedAt {
            addIcon(name: .angleDoubleUp, color: UIColor(white: 0.6, alpha: 1))
        }
        if data.excellent {
            addIcon(name: .diamond, color: PRIMARY_COLOR)
        }
        if let _ = data.closedAt {
            let iconColor = UIColor(red: 69.0 / 255.0, green: 199.0 / 255.0, blue: 34.0 / 255.0, alpha: 1)
            addIcon(name: .check, color: iconColor)
        }
        
        return attributedString
    }
    
}
