//
//  AlbumViewModel.swift
//  Diptych
//
//  Created by Koo on 2023/07/18.


import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore


struct Photo2: Identifiable, Codable {
    let id: String
    let albumId: String
    let isCompleted: Bool
    let thumbnail: String
    let date: Date
    let day: Int
    let month: Int
}

struct StartDay: Identifiable, Codable {
    let id: String
    let date: Date
    let day: Int
}

@MainActor
class AlbumViewModel: ObservableObject {
    
    @Published var photos : [Photo2] = []
    @Published var startDay : [StartDay] = []
    
    init(){ 
        fetchDiptychCalender()
        fetchStartDate()
    }
    
    /// 포토 컬렉션 필드 데이터 가져오기
    func fetchDiptychCalender() {
        let firestore = Firestore.firestore()
        
        firestore.collection("photos")
            .whereField("albumId", isEqualTo: "albumTest")
            .getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching photos: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.photos = documents.compactMap { document in
                    guard let thumbnail = document.data()["thumbnail"] as? String,
                          let isCompleted = document.data()["isCompleted"] as? Bool,
                          let timestamp = document.data()["date"] as? Timestamp else {
                            return nil
                          }
                    
                    let day = timestamp.dateValue().get(.day)
                    let month = timestamp.dateValue().get(.month)
                    
                    return Photo2(id: document.documentID, albumId: "3ZtcHka4I3loqa7Xopc4",
                                  isCompleted: isCompleted, thumbnail: thumbnail,
                                  date: timestamp.dateValue(), day: day, month: month)
                }
            }//: getDocuments
    }//: fetchDiptychCalender
    
    
    /// 앨범 생성된 날짜 가져오기
    func fetchStartDate() {
        let firestore = Firestore.firestore()
        
        firestore.collection("albums")
            .whereField("id", isEqualTo: "albumTest")
            .getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching photos: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.startDay = documents.compactMap { document in
                    guard let timestamp = document.data()["date"] as? Timestamp else {
                        return nil
                    }
                    let day = timestamp.dateValue().get(.day)
                    
                    return StartDay(id: document.documentID, date: timestamp.dateValue(), day: day)
                }
            }//: getDocument
    }//: fetchStartDate
    
    
    
}
