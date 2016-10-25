//
//  ImageTitleView.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/25.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class ImageTitleView: UIView {

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(titleLabel)
        imageView.snp_makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
        }
        titleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(imageView.snp_bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showImageZoomAnimation() {
        imageView.transform = CGAffineTransformMakeScale(0.0, 0.0)
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 20, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.imageView.transform = CGAffineTransformMakeScale(1, 1)
        }, completion: nil)
    }
}
