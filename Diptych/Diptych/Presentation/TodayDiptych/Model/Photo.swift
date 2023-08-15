//
//  Photo.swift
//  Diptych
//
//  Created by 김민 on 2023/07/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Photo: Identifiable, Codable {
    let id: String
    let photoFirst: String
    let photoSecond: String
    let thumbnail: String
    let date: Timestamp
    // @ServerTimestamp var date: Timestamp?
    let contentId: String
    let albumId: String
    let isCompleted: Bool

    func convertToDictionary() -> [String: Any] {
        return [
            "id": id,
            "photoFirst": photoFirst,
            "photoSecond": photoSecond,
            "thumbnail": thumbnail,
            "date": date,
            "contentId": contentId,
            "albumId": albumId,
            "isCompleted": isCompleted
        ]
    }
}
