//
//  Content.swift
//  Diptych
//
//  Created by 김민 on 2023/07/23.
//

import Foundation

struct Content: Identifiable, Codable {
    let id: String
    let question: String
    let order: Int
    let guideline: String
    let toolTip: String
    let toolTipImage: String
}
