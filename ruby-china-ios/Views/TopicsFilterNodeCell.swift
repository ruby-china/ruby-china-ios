//
//  TopicsFilterNodeCell.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/22.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class TopicsFilterNodeCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.textAlignment = .Center
        view.font = UIFont.systemFontOfSize(12)
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    var normalImage: UIImage?
    var selectedImage: UIImage?
    var name: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    override var selected: Bool {
        didSet {
            label.textColor = selected ? NAVBAR_TINT_COLOR : SEGMENT_BG_COLOR
            imageView.image = selected ? selectedImage : normalImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        imageView.snp_makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        label.snp_makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
