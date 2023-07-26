//
//  PhotoViewModel.swift
//  Diptych
//
//  Created by Koo on 2023/07/24.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore


struct Photo3: Identifiable {
    let id: String
    let imageURL: String
    let date: Date
    let dayNum: Int
    let monthNum : Int
}

class PhotoViewModel: ObservableObject {
    @Published var photos: [Photo3] = []

    
    init(){
        fetchPhotos()
        print("📍",self.photos)
    }
    
    
    func fetchPhotos() {
        // Assuming you have already configured Firebase in your app
        let firestore = Firestore.firestore()
        
        // Assuming you have a collection called "photos" and each document has "imageURL" and "date" fields
        firestore.collection("testphotos")
            .getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                print("Error fetching photos: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.photos = documents.compactMap { document in
                guard let imageURL = document.data()["imageURL"] as? String,
                      let timestamp = document.data()["date"] as? Timestamp else {return nil}
                
                let day = timestamp.dateValue().get(.day)
                let month = timestamp.dateValue().get(.month)
                return Photo3(id: document.documentID, imageURL: imageURL, date: timestamp.dateValue(),
                              dayNum: day, monthNum: month)
            }
        }//: getDocuments
        
    }
}
