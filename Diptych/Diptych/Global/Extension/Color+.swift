//
//  UIColor+.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI
import UIKit

extension UIColor {

    // MARK: - Custom Color

    static var darkGray: UIColor? { return UIColor(named: "DarkGray") }
}

extension Color {

    // MARK: - Custom Color

    static let darkGray = Color("DarkGray")
    static let lightGray = Color("LightGray")
    static let offBlack = Color("OffBlack")
    static let offBlack50 = Color("OffBlack50")
    static let offWhite = Color("OffWhite")
    static let systemRed = Color("SystemRed")
    static let systemSalmon = Color("SystemSalmon")
    static let systemBlack = Color("SystemBlack")
    static let systemBlack85 = Color("SystemBlack85")
    static let systemWhite = Color("SystemWhite")
}
