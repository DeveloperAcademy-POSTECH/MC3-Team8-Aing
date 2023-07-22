//
//  AlbumViewModel.swift
//  Diptych
//
//  Created by Koo on 2023/07/18.


import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore

//enum DiptychComplete {
//    case incomplete
//    case complete
//}

struct DiptychData {
    let diptychComplete: DiptychComplete
    let thumbnail: String?
}


@MainActor
class AlbumViewModel: ObservableObject {

    @Published var question = "상대방의 표정 중 당신이\n가장 좋아하는 표정은?"
    @Published var diptychData = [DiptychData]()
    @Published var isLoading = false
    @Published var diptychTimeStamp: Int = 0
    @Published var day : Int = 0
    @Published var month : Int = 0
    let db = Firestore.firestore()

        
    // Firebase Timestamp를 Int로 변환하는 함수
     private func convertTimestampToInt(date: Date) -> Int {
         let timestamp = Int(date.timeIntervalSince1970)
         return timestamp
     }
     
     // 날짜의 '일' 정보를 Int로 변환하는 함수
     private func extractDayFromDate(date: Date) -> Int {
         let calendar = Calendar(identifier: .gregorian)
         let day = calendar.component(.day, from: date)
         return day
     }
     
     // 날짜의 '달' 정보를 Int로 변환하는 함수
     private func extractMonthFromDate(date: Date) -> Int {
         let calendar = Calendar(identifier: .gregorian)
         let month = calendar.component(.month, from: date)
         return month
     }
    
    
    func fetchDiptychCalender() async {

        isLoading = true

        day = extractDayFromDate(date: Date(timeIntervalSince1970: TimeInterval(diptychTimeStamp)))
        month = extractMonthFromDate(date: Date(timeIntervalSince1970: TimeInterval(diptychTimeStamp)))

        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: "O6ulZBskeb10JC7DMhXk")
                .whereField("date", isEqualTo: diptychTimeStamp)
                .getDocuments()

            for document in querySnapshot.documents {
                let data = document.data()
                guard let photoFirst = data["photoFirst"] as? String else { return }
                guard let photoSecond = data["photoSecond"] as? String else { return }
                guard let thumbnail = data["thumbnail"] as? String else { return }

                if photoFirst != "" && photoSecond != "" {
                    await MainActor.run {
                        diptychData.append(DiptychData(diptychComplete: .complete, thumbnail: thumbnail))
                    }
                } else {
                    await MainActor.run {
                        diptychData.append(DiptychData(diptychComplete: .incomplete, thumbnail: nil))
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }

        isLoading = false
    }
    
   
}
