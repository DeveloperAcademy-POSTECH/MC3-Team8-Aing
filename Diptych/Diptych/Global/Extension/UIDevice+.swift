//
//  UIDevice+.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/17.
//

import UIKit

extension UIDevice {
    var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}
