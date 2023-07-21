//
//  TodayDiptychViewModel.swift
//  Diptych
//
//  Created by 김민 on 2023/07/19.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct WeeklyData {
    let diptychState: DiptychState
    let thumbnail: String?
}

@MainActor
class TodayDiptychViewModel: ObservableObject {

    @Published var question = "상대방의 표정 중 당신이\n가장 좋아하는 표정은?"
    @Published var weeklyData = [WeeklyData]()
    @Published var isLoading = false

    let db = Firestore.firestore()

    func fetchTodayQuestion() async {
        // TODO: nanoseconds 값까지 어떻게 고려하지?
        let timestamp = Timestamp(seconds: 1689692400, nanoseconds: 870000000)

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

//    func fetchAll() {
//        db
//            .collection("photos")
//            .whereField("albumId", isEqualTo: "O6ulZBskeb10JC7DMhXk")
//            .whereField("date", isGreaterThanOrEqualTo: fetchThisMonday())
//            .getDocuments { querySnapshot, error in
//                for doucment in querySnapshot!.documents {
//                    print(doucment.data())
//                }
//            }
//    }

    func fetchWeeklyCalender() async {
        isLoading = true

        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: "O6ulZBskeb10JC7DMhXk") // TODO: - 유저의 앨범과 연결
                .whereField("date", isGreaterThanOrEqualTo: calcuateThisMondayTimestamp())
                .getDocuments()

            for document in querySnapshot.documents {
                let data = document.data()
                guard let photoFirst = data["photoFirst"] as? String else { return }
                guard let photoSecond = data["photoSecond"] as? String else { return }
                guard let thumbnail = data["thumbnail"] as? String else { return }

                if photoFirst != "" && photoSecond != "" {
                    await MainActor.run {
                        weeklyData.append(WeeklyData(diptychState: .complete, thumbnail: thumbnail))
                    }
                } else if photoFirst != "" {
                    await MainActor.run {
                        weeklyData.append(WeeklyData(diptychState: .half, thumbnail: nil))
                    }
                } else if photoSecond != "" {
                    await MainActor.run {
                        weeklyData.append(WeeklyData(diptychState: .half, thumbnail: nil))
                    }
                } else {
                    await MainActor.run {
                        weeklyData.append(WeeklyData(diptychState: .incomplete, thumbnail: nil))
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }

        isLoading = false
    }

    func calcuateThisMondayTimestamp() -> Timestamp {
        let currentDate = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 00:00:00"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 시간대 설정

        let todayDateString = formatter.string(from: currentDate)

        let todayDate = formatter.date(from: todayDateString)!

        let currentWeekday = calendar.component(.weekday, from: todayDate)
        let daysAfterMonday = (currentWeekday + 5) % 7

        guard let thisMonday = calendar.date(byAdding: .day, value: -daysAfterMonday, to: todayDate) else { return Timestamp() }

        let timestamp = Timestamp(date: thisMonday)
        return timestamp
    }
}
