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

struct Content: Identifiable, Codable {
    let id: String
    let question: String
    let order: Int
    let guideline: String
    let toolTip: String
    let toolTipImage: String
}

struct Photo: Identifiable, Codable {
    let id: String
    let photoFirst: String
    let photoSecond: String
    let thumbnail: String
    let date: Timestamp
    let contentId: String
    let albumId: String
    let isCompleted: Bool
}

@MainActor
class TodayDiptychViewModel: ObservableObject {

    @Published var question = ""
    @Published var currentUser: DiptychUser?
    @Published var isFirst = true
    @Published var weeklyData = [WeeklyData]()
    @Published var isLoading = false
    @Published var contentDay = 0
    @Published var content: Content?
    @Published var todayPhoto: Photo?
    @Published var photoFirstURL: String = ""
    @Published var photoSecondURL: String = ""

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

    func fetchWeeklyCalender() async {
        isLoading = true

        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: "3ZtcHka4I3loqa7Xopc4") // TODO: - 유저의 앨범과 연결
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

    func fetchTodayImage() async {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 00:00:00"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let todayDateString = formatter.string(from: currentDate)
        let todayDate = formatter.date(from: todayDateString)!
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
        } catch {
            print(error.localizedDescription)
        }
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

        print(photoFirstURL, photoSecondURL)
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
}
