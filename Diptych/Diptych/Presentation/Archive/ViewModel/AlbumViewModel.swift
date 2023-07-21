//
//  AlbumViewModel.swift
//  Diptych
//
//  Created by Koo on 2023/07/18.


import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore

//enum DiptychState {
//    case incomplete
//    case half
//    case complete
//}

struct DiptychData {
    let diptychState: DiptychState
    let thumbnail: String?
}


@MainActor
class AlbumViewModel: ObservableObject {

    @Published var question = "상대방의 표정 중 당신이\n가장 좋아하는 표정은?"
    @Published var diptychData = [DiptychData]()
    @Published var isLoading = false

    let db = Firestore.firestore()



    func fetchDiptychCalender() async {

        isLoading = true

//        let timeStamp = Timestamp(seconds: 1689519600, nanoseconds: 0)
        let timeStamp = Timestamp(seconds: 1689519600, nanoseconds: 0)

        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: "O6ulZBskeb10JC7DMhXk")
                .whereField("date", isGreaterThanOrEqualTo: timeStamp)
                .getDocuments()

            for document in querySnapshot.documents {
                let data = document.data()
                guard let photoFirst = data["photoFirst"] as? String else { return }
                guard let photoSecond = data["photoSecond"] as? String else { return }
                guard let thumbnail = data["thumbnail"] as? String else { return }

                if photoFirst != "" && photoSecond != "" {
                    await MainActor.run {
                        diptychData.append(DiptychData(diptychState: .complete, thumbnail: thumbnail))
                    }
                } else if photoFirst != "" {
                    await MainActor.run {
                        diptychData.append(DiptychData(diptychState: .half, thumbnail: nil))
                    }
                } else if photoSecond != " "{
                    await MainActor.run {
                        diptychData.append(DiptychData(diptychState: .half, thumbnail: nil))
                    }
                } else {
                    await MainActor.run {
                        diptychData.append(DiptychData(diptychState: .incomplete, thumbnail: nil))
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }

        isLoading = false
    }

    
    
}
