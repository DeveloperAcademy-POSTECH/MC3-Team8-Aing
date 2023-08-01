//
//  ImageCacheMananger.swift
//  Diptych
//
//  Created by 윤범태 on 2023/08/01.
//

import UIKit

final class ImageCacheManager {
    static private let cache = NSCache<NSString, UIImage>()
    static let shared = ImageCacheManager()
    private init() {}
    
    func loadImageFromCache(urlAbsoluteString urlString: String) -> UIImage? {
        ImageCacheManager.cache.object(forKey: NSString(string: urlString))
    }
    
    func saveImageToCache(image: UIImage, urlAbsoluteString urlString: String) {
        ImageCacheManager.cache.setObject(image, forKey: NSString(string: urlString))
    }
}
