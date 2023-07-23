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

final class TodayDiptychViewModel: ObservableObject {

    // MARK: - Properties

    @Published var question = ""
    @Published var currentUser: DiptychUser?
    @Published var isFirst = true
    @Published var weeklyData = [WeeklyData]()
    @Published var isLoading = false
    @Published var contentDay = 0
    @Published var content: Content?
    @Published var todayPhoto: Photo?
    @Published var photoFirstURL = ""
    @Published var photoSecondURL = ""
    @Published var isCompleted = false
    private  let db = Firestore.firestore()

    // MARK: - Network

    func fetchWeeklyCalender() async {
        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: "3ZtcHka4I3loqa7Xopc4") // TODO: - 유저의 앨범과 연결
                .whereField("date", isGreaterThanOrEqualTo: calculateThisMondayTimestamp())
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
    }

    func fetchTodayImage() async {
        let (todayDate, _, _) = setTodayDate()
        let timestamp = Timestamp(date: todayDate)

        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: "3ZtcHka4I3loqa7Xopc4")
                .whereField("date", isGreaterThanOrEqualTo: timestamp)
                .getDocuments()

            for document in querySnapshot.documents {
                self.todayPhoto = try document.data(as: Photo.self)
            }
            await downloadImage()
            await fetchCompleteState()
        } catch {
            print(error.localizedDescription)
        }
    }

    func fetchCompleteState() async {
        guard let todayPhoto = todayPhoto else { return }
        isCompleted = todayPhoto.isCompleted
    }

    func downloadImage() async {
        guard let todayPhoto = todayPhoto else { return }
        if todayPhoto.photoFirst != "" {
            do {
                let url = try await Storage.storage().reference(forURL: todayPhoto.photoFirst).downloadURL()
                photoFirstURL = url.absoluteString
            } catch {
                print(error.localizedDescription)
            }
        }

        if todayPhoto.photoSecond != "" {
            do {
                let url = try await Storage.storage().reference(forURL: todayPhoto.photoSecond).downloadURL()
                photoSecondURL = url.absoluteString
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try? snapshot.data(as: DiptychUser.self)
        } catch {
            print(error.localizedDescription)
        }
    }

    func setUserCameraLoactionState() async {
        guard let isFirst = currentUser?.isFirst else { return }
        self.isFirst = isFirst
    }

    func fetchContents() async {
        do {
            let daySnapshot = try await db.collection("albums")
                .whereField("id", isEqualTo: "3ZtcHka4I3loqa7Xopc4") // TODO: - 유저의 앨범과 연결
                .getDocuments()

            for document in daySnapshot.documents {
                let data = document.data()

                guard let contentDay = data["contentDay"] as? Int else { return }
                self.contentDay = contentDay
            }

            let contentSnapshot = try await db.collection("contents")
                .whereField("order", isEqualTo: contentDay) // TODO: - 유저의 앨범과 연결
                .getDocuments()

            for document in contentSnapshot.documents {
                self.content = try document.data(as: Content.self)
            }

            guard let question = content?.question else { return }
            self.question = question.replacingOccurrences(of: "\\n", with: "\n")
        } catch {
            print(error.localizedDescription)
        }
    }

    func setTodayPhoto() async {
        let (todayDate, _, _) = setTodayDate()
        let timestamp = Timestamp(date: todayDate)

        // TODO: - 유저의 albumId와 연결하기 (현재 test albumId: 4WX8aANlqOCHS9hmET6X)
        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: "4WX8aANlqOCHS9hmET6X")
                .whereField("date", isEqualTo: timestamp)
                .getDocuments()

            if querySnapshot.documents.isEmpty {
                let autoGeneratedId = self.db.collection("photos").document().documentID
                try await db.collection("photos").document(autoGeneratedId).setData(
                    Photo(id: autoGeneratedId,
                          photoFirst: "",
                          photoSecond: "",
                          thumbnail: "",
                          date: timestamp,
                          contentId: "",
                          albumId: "4WX8aANlqOCHS9hmET6X",
                          isCompleted: false)
                    .convertToDictionary()
                )
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Custom Methods

    func calculateThisWeekMondayDate() -> Int {
        let (todayDate, calendar, daysAfterMonday) = setTodayDate()
        guard let thisMonday = calendar.date(byAdding: .day, value: -daysAfterMonday, to: todayDate) else { return 0 }
        let day = calendar.component(.day, from: thisMonday)
        return day
    }

    func calculateThisMondayTimestamp() -> Timestamp {
        let (todayDate, calendar, daysAfterMonday) = setTodayDate()
        guard let thisMonday = calendar.date(byAdding: .day, value: -daysAfterMonday, to: todayDate) else { return Timestamp() }
        let timestamp = Timestamp(date: thisMonday)
        return timestamp
    }

    func setTodayDate() -> (Date, Calendar, Int) {
        let currentDate = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 00:00:00"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")

        let todayDateString = formatter.string(from: currentDate)
        let todayDate = formatter.date(from: todayDateString)!
        let currentWeekday = calendar.component(.weekday, from: todayDate)
        let daysAfterMonday = (currentWeekday + 5) % 7

        return (todayDate, calendar, daysAfterMonday)
    }
}
