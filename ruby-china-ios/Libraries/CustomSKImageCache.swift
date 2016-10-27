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
    private let cache = KingfisherManager.sharedManager.cache
    
    func imageForKey(key: String) -> UIImage? {
        guard let cacheType = cache.isImageCachedForKey(key).cacheType else { return nil }
        
        switch cacheType {
        case .Disk: return cache.retrieveImageInDiskCacheForKey(key)
        case .Memory: return cache.retrieveImageInMemoryCacheForKey(key)
        default: return nil
        }
    }
    
    func setImage(image: UIImage, forKey key: String) {
        cache.storeImage(image, forKey: key)
    }
    
    func removeImageForKey(key: String) {
        cache.removeImageForKey(key)
    }
}
