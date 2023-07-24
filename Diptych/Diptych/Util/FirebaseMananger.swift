//
//  FirebaseMananger.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/22.
//

import Foundation
import Firebase
import FirebaseStorage

class FirebaseManager {
    /// Singleton instance
    static let shared: FirebaseManager = FirebaseManager()
    
    /// Path
    private(set) var kFirFileStorageRef = Storage.storage().reference().child("Temp_images")
    private var firestore = Firestore.firestore()
    
    /// Current Uploading Task
    var currentUploadTask: StorageUploadTask?
    
    func setChild(_ pathString: String) {
        kFirFileStorageRef = Storage.storage().reference().child(pathString)
    }
    
    func upload(data: Data, withName fileName: String) async throws -> URL? {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await kFirFileStorageRef.child(fileName).putDataAsync(data, metadata: metadata)
        return try await kFirFileStorageRef.child(fileName).downloadURL()
    }
    
    func setValue(collectionPath: String, dictionary: [String: Any]) async throws {
        let collectionReference = firestore.collection(collectionPath)
        let document = collectionReference.document()
        try await document.setData(dictionary)
    }
    
    func updateValue(collectionPath: String, documentId: String, dictionary: [String: Any]) async throws {
        let collectionReference = firestore.collection(collectionPath)
        let document = collectionReference.document(documentId)
        try await document.updateData(dictionary)
    }
}
