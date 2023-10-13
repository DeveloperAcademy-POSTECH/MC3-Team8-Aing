//
//  DiptychPhotoComment.swift
//  Diptych
//
//  Created by 윤범태 on 2023/10/12.
//

import Foundation

struct DiptychPhotoComment: Codable {
    var id: String
    var authorID: String
    var comment: String
    var createdDate: Date
    var modifiedDate: Date
}
