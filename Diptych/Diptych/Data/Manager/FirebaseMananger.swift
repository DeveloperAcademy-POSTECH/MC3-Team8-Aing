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
    private init() {}
    
    /// Path
    private(set) var kFirFileStorageRef = Storage.storage().reference().child("images")
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
    
    /// 새로운 값 세팅에 사용. 모든 키값에 적용되므로 업데이트는 지양
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
    
    /// 이미지 데이터 다운로드(Firebase 캐시 사용)
    func downloadImageDataFromFirebase(childPath: String) async throws -> Data {
        let reference = Storage.storage().reference().child(childPath)
        
        let url = try await reference.downloadURL()
        return try Data(contentsOf: url)
    }
    
    func downloadImageDataFromFirebaseImageURL(urlAbsoluteString: String) async throws -> Data {
        let reference = Storage.storage().reference(forURL: urlAbsoluteString)
        
        let url = try await reference.downloadURL()
        return try Data(contentsOf: url)
    }
    
    func md5HashOfImageURL(from urlAbsoluteString: String) async throws -> String? {
        let reference = Storage.storage().reference(forURL: urlAbsoluteString)
        
        let storageMetadata = try await reference.getMetadata()
        return storageMetadata.md5Hash
    }
    
    func uploadDateOfImageURL(from urlAbsoluteString: String) async throws -> Date? {
        let reference = Storage.storage().reference(forURL: urlAbsoluteString)
        
        let storageMetadata = try await reference.getMetadata()
        return storageMetadata.updated
    }
    
    func 데모에쓰기_끝나면삭제해라() {
        Task {
            for i in 1...13 {
                let ref = firestore.collection("photos")
                let document = ref.document("demo\(i)")
                
                let fileNameIndex = i < 10 ? "0\(i)" : "\(i)"
                let dict: [String: Any] = [
                    "albumId": "3ZtcHka4I3loqa7Xopc4",
                    "id": "demo\(i)",
                    "contentId": "FQmWBOl68GLCPeHmhtQ7",
                    "date": Date(timeIntervalSince1970: 1688982720 + (Double(i) * 86400)),
                    "isCompleted": true,
                    "photoFirst": "gs://diptych2-a8726.appspot.com/demo/sliced/\(fileNameIndex)_first.png",
                    "photoSecond":"gs://diptych2-a8726.appspot.com/demo/sliced/\(fileNameIndex)_second.png",
                    "thumbnail": "gs://diptych2-a8726.appspot.com/demo/\(fileNameIndex)_thumbnail.jpg",
                ]
                try await document.updateData(dict)
            }
        }
        
        
    }
}

