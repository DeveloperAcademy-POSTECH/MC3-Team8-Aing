//
//  TransformImageBasedOnContainerView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/17.
//

import UIKit

func transformImageBasedOnContainerView(imageView: UIImageView, containerView: UIView) -> UIImage? {
    // https://stackoverflow.com/a/11177322
    
    guard let image = imageView.image else {
        return nil
    }
    
    let imageScale = sqrtf(powf(Float(containerView.transform.a), 2) + powf(Float(imageView.transform.c), 2))
    let widthScale = imageView.bounds.size.width / image.size.width
    let heightScale = imageView.bounds.size.height / image.size.height
    let contentScale = min(widthScale, heightScale)
    let effectiveScale = CGFloat(imageScale) * contentScale
    let captureSize = CGSizeMake(containerView.bounds.size.width / effectiveScale, containerView.bounds.size.height / effectiveScale)
    
    debugPrint("effectiveScale = \(effectiveScale), captureSize = \(captureSize)")
    
    UIGraphicsBeginImageContextWithOptions(captureSize, true, 0.0)
    
    guard let context = UIGraphicsGetCurrentContext() else {
        return nil
    }
    
    // CGContextScaleCTM(context, 1 / effectiveScale, 1 / effectiveScale)
    context.scaleBy(x: 1 / effectiveScale, y: 1 / effectiveScale)
    containerView.layer.render(in: context)
    
    let outputImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return outputImage
}
