//
//  DiptychUser.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/18.
//

import Foundation

struct DiptychUser: Identifiable, Codable {
    let id: String
    let name: String
    let nickname: String
    let email: String
    let phoneNumber: String
    let couplingCode: Int
    let loverId: String
}
