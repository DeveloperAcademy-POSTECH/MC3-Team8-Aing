//
//  Font+.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI

extension Font {

    static func pretendard(_ type: PretendardType, size: CGFloat = 16) -> Font {
        return .custom(type.rawValue, size: size)
    }
}
