//
//  DiptychUser.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/18.
//

import Foundation

struct DiptychUser: Identifiable, Codable {
    let id: String
    let email: String
    let name: String
    
    var flow: String
    var sharedAlbumId: String?
    var nickname: String?
    var phoneNumber: String?
    var couplingCode: String?
    var loverId: String?
    var startDay: Date?
    var isFirst: Bool?
}
