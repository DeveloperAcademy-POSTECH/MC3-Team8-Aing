//
//  UIImage+.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/18.
//

import UIKit

extension UIImage {
    func resize(width: CGFloat, height: CGFloat) -> UIImage {
        let image = self
        
        let rect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.pngData()
        UIGraphicsEndImageContext()
        
        return UIImage(data: imageData!) ?? UIImage()
    }
}
