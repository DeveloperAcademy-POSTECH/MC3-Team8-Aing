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
    
    /// 이미지 합치기
    func merge(with anotherImage: UIImage, division axis: ImageDivisionAxis) -> UIImage? {
        let baseImage = self
        
        UIGraphicsBeginImageContext(.init(width: THUMB_SIZE, height: THUMB_SIZE))
        
        switch axis {
        case .verticalLeft:
            baseImage.draw(in: .init(x: 0, y: 0, width: baseImage.size.width, height: baseImage.size.height))
            anotherImage.draw(in: .init(x: baseImage.size.width, y: 0, width: anotherImage.size.width, height: anotherImage.size.height))
        case .verticalRight:
            baseImage.draw(in: .init(x: anotherImage.size.width, y: 0, width: baseImage.size.width, height: baseImage.size.height))
            anotherImage.draw(in: .init(x: 0, y: 0, width: anotherImage.size.width, height: anotherImage.size.height))
        case .horizontalUp:
            // TODO: - 가이드라인이 horizontal인 경우
            return nil
        case .horizontalDown:
            return nil
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
