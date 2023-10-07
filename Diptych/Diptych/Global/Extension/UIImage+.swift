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
    /// - Parameters:
    ///     - with: 합칠 다른 이미지
    ///     - division: 이미지 구획
    ///     - contextSize: 아웃풋 이미지의 사이즈, 지정하지 않으면 `THUMB_SIZE` 사용 (옵셔널)
    ///     - customBaseImageSize: 이미지 사이즈가 기본 이미지와 다른지 여부 (옵셔널)
    ///     - customAnotherImageSize: 이미지 사이즈가 합치는 이미지와 다른지 여부 (옵셔널)
    func merge(with anotherImage: UIImage,
               division axis: ImageDivisionAxis,
               contextSize: CGSize? = nil,
               customBaseImageSize: CGSize? = nil,
               customAnotherImageSize: CGSize? = nil) -> UIImage? {
        let baseImage = self
        
        let contextSize: CGSize = contextSize ?? .init(width: THUMB_SIZE, height: THUMB_SIZE)
        let baseImageSize: CGSize = customBaseImageSize ?? baseImage.size
        let anotherImageSize: CGSize = customAnotherImageSize ?? anotherImage.size
        
        UIGraphicsBeginImageContext(contextSize)
        
        switch axis {
        case .verticalLeft:
            baseImage.draw(in: .init(x: 0,
                                     y: 0,
                                     width: baseImageSize.width,
                                     height: baseImageSize.height))
            anotherImage.draw(in: .init(x: baseImageSize.width,
                                        y: 0, width: anotherImageSize.width,
                                        height: anotherImageSize.height))
        case .verticalRight:
            baseImage.draw(in: .init(x: anotherImageSize.width,
                                     y: 0,
                                     width: baseImageSize.width,
                                     height: baseImageSize.height))
            anotherImage.draw(in: .init(x: 0,
                                        y: 0,
                                        width: anotherImageSize.width,
                                        height: anotherImageSize.height))
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
