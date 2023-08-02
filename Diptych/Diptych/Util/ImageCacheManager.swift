//
//  ImageCacheMananger.swift
//  Diptych
//
//  Created by 윤범태 on 2023/08/01.
//

import UIKit

final class ImageCacheManager {
    static private let memoryCache = NSCache<NSString, UIImage>()
    static let shared = ImageCacheManager()
    private init() {}
    
    func loadImageFromCache(urlAbsoluteString urlString: String) -> UIImage? {
        ImageCacheManager.memoryCache.object(forKey: NSString(string: urlString))
    }
    
    func saveImageToCache(image: UIImage, urlAbsoluteString urlString: String) {
        ImageCacheManager.memoryCache.setObject(image, forKey: NSString(string: urlString))
    }
}
