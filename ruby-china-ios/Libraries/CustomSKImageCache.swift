//
//  CustomSKImageCache.swift
//  ruby-china-ios
//
//  Created by kelei on 16/10/27.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import SKPhotoBrowser
import Kingfisher

class CustomImageCache: SKImageCacheable {
    fileprivate let cache = KingfisherManager.shared.cache
    
    func imageForKey(_ key: String) -> UIImage? {
        switch cache.imageCachedType(forKey: key) {
        case .disk: return cache.retrieveImageInDiskCache(forKey: key)
        case .memory: return cache.retrieveImageInMemoryCache(forKey: key)
        case .none: return nil
        }
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.store(image, forKey: key)
    }
    
    func removeImageForKey(_ key: String) {
        cache.removeImage(forKey: key)
    }
}
