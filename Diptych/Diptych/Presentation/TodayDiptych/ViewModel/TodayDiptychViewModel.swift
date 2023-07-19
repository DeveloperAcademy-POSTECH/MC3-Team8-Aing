//
//  TodayDiptychViewModel.swift
//  Diptych
//
//  Created by 김민 on 2023/07/19.
//

import Foundation
import Firebase
import FirebaseFirestore

class TodayDiptychViewModel: ObservableObject {

    @Published var question: String = "상대방의 표정 중 당신이\n가장 좋아하는 표정은?"
    let db = Firestore.firestore()

    func fetchTodayQuestion() async {
        // TODO: nanoseconds 값까지 어떻게 고려하지?
        let timestamp = Timestamp(seconds: 1689692400, nanoseconds: 870000000)
//        let timestamp = Timestamp(seconds: 1689692400, nanoseconds: 0)

        do {
            let querySnapshot = try await db.collection("contents")
                .whereField("date", isEqualTo: timestamp)
                .getDocuments()

            for document in querySnapshot.documents {
                let data = document.data()
                if let question = data["question"] as? String {
                    await MainActor.run {
                        self.question = question
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func fetchAll() {
        db.collection("photos")
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                }
            }
    }

    func fetchWeeklyCalender() {
        // 이번 주 월요일(17) 이후의 데이터
        // <FIRTimestamp: seconds=1689552000 nanoseconds=0>
//        firebase의 7/17 timestamp: <FIRTimestamp: seconds=1689519600 nanoseconds=863000000>
        let timeStamp = Timestamp(seconds: 1689519600, nanoseconds: 863000000)
        db.collection("photos")
            .whereField("albumId", isEqualTo: "O6ulZBskeb10JC7DMhXk")
            .whereField("date", isGreaterThanOrEqualTo: timeStamp)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        print(document.data())
                    }
                }
            }
    }
}

extension Date {

    func convertToUTC() -> Date {
        let timeZoneOffset = TimeZone.current.secondsFromGMT()
        let utcDate = self.addingTimeInterval(TimeInterval(timeZoneOffset))
        return utcDate
    }
}
