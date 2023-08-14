//
//  Image+.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/24.
//

import SwiftUI

extension Image {
    
    @MainActor
    func getUIImage(newSize: CGSize) -> UIImage? {
        let image = resizable()
            .scaledToFill()
            .frame(width: newSize.width, height: newSize.height)
            .clipped()
        return ImageRenderer(content: image).uiImage
    }
}

