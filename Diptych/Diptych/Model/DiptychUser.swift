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
    var flow: String
    
    var couplingCode: String?
    var loverId: String?
    var isFirst: Bool?
    var sharedAlbumId: String?
    var name: String?
    var startDate: Date?
    var phoneNumber: String?
}
