//
//  FirebaseFileMananger.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/22.
//

import Foundation
import FirebaseStorage

class FirebaseFileManager {
    /// Singleton instance
    static let shared: FirebaseFileManager = FirebaseFileManager()
    
    /// Path
    private(set) var kFirFileStorageRef = Storage.storage().reference().child("Temp_images")
    
    /// Current Uploading Task
    var currentUploadTask: StorageUploadTask?
    
    func setChild(_ pathString: String) {
        kFirFileStorageRef = Storage.storage().reference().child(pathString)
    }
    
    func upload(data: Data, withName fileName: String) async throws -> URL? {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await kFirFileStorageRef.child(fileName).putDataAsync(data, metadata: metadata)
        return try await kFirFileStorageRef.downloadURL()
    }
}
