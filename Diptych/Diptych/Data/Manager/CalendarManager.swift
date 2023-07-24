//
//  CalendarManager.swift
//  Diptych
//
//  Created by 김민 on 2023/07/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

class CalendarManager {

    static let shared = CalendarManager()
    private init() { }
    private let db = Firestore.firestore()
}

