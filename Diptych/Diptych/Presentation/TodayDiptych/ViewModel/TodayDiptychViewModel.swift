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

enum TodayDiptychState {
    case incomplete
    case upload
    case complete
}

enum DiptychState {
    case none
    case incomplete
    case todayIncomplete
    case todayfirst
    case todaySecond
    case complete
}

final class TodayDiptychViewModel: ObservableObject {

    // MARK: - Properties

    @Published var question = ""
    @Published var currentUser: DiptychUser?
    @Published var isFirst = true
    @Published var weeklyData = [DiptychState]()
    @Published var content: Content?
    @Published var todayPhoto: Photo?
    @Published var photoFirstURL = ""
    @Published var photoSecondURL = ""
    @Published var isCompleted = false
    @Published var photoFirstState = TodayDiptychState.incomplete
    @Published var photoSecondState = TodayDiptychState.incomplete
    @Published var diptychNumber = 1
    private let db = Firestore.firestore()

    // MARK: - Network

    func fetchWeeklyCalender() async {
        guard let albumId = currentUser?.coupleAlbumId else { return }

        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: albumId) // TODO: - 유저의 앨범과 연결
                .whereField("date", isGreaterThanOrEqualTo: calculateThisMondayTimestamp())
                .whereField("date", isLessThan: calculateThisTodayTimestamp())
                .getDocuments()

            for document in querySnapshot.documents {
                let photo = try document.data(as: Photo.self)
                let isCompleted = photo.isCompleted

                weeklyData.append(isCompleted ? DiptychState.complete : DiptychState.incomplete)
            }

            guard let todayPhoto = self.todayPhoto else { return }

            if todayPhoto.isCompleted {
                weeklyData.append(.complete)
            } else if !todayPhoto.photoFirst.isEmpty && todayPhoto.photoSecond.isEmpty {
                weeklyData.append(.todayfirst)
            } else if todayPhoto.photoFirst.isEmpty && !todayPhoto.photoSecond.isEmpty {
                weeklyData.append(.todaySecond)
            } else {
                weeklyData.append(.todayIncomplete)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func fetchTodayImage() async {
        let (todayDate, _, _) = setTodayCalendar()
        let timestamp = Timestamp(date: todayDate)
        guard let albumId = currentUser?.coupleAlbumId else { return }

        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: albumId)
                .whereField("date", isGreaterThanOrEqualTo: timestamp)
                .getDocuments()

            for document in querySnapshot.documents {
                self.todayPhoto = try document.data(as: Photo.self)
            }

            await downloadImage()

            if !photoFirstURL.isEmpty && !photoSecondURL.isEmpty {
                photoFirstState = .complete
                photoSecondState = .complete
            } else if !photoFirstURL.isEmpty || !photoSecondURL.isEmpty {
                photoFirstState = photoFirstURL.isEmpty ? .incomplete : .upload
                photoSecondState = photoSecondURL.isEmpty ? .incomplete : .upload
            } else {
                photoFirstState = .incomplete
                photoSecondState = .incomplete
            }
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
            photoFirstURL = todayPhoto.photoFirst
        }

        if todayPhoto.photoSecond != "" {
            photoSecondURL = todayPhoto.photoSecond
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
        guard let albumId = currentUser?.coupleAlbumId else { return }

        do {
            let daySnapshot = try await db.collection("albums")
                .whereField("id", isEqualTo: albumId)  
                .getDocuments()

            let data = daySnapshot.documents[0].data()
            guard let startDate = data["startDate"] as? Timestamp else { return }

            let dateComponents = Calendar.current.dateComponents([.day], from: startDate.dateValue(), to: Date())
            guard var order = dateComponents.day else { return }

            if order >= 24 { order -= 24 } // TODO: - 질문 개수에 따라 초기화

            let contentSnapshot = try await db.collection("contents")
                .whereField("order", isEqualTo: order) 
                .getDocuments()

            self.content = try contentSnapshot.documents[0].data(as: Content.self)
            guard let question = content?.question else { return }
            self.question = question.replacingOccurrences(of: "\\n", with: "\n")
        } catch {
            print(error.localizedDescription)
        }
    }

    func setTodayPhoto() async {
        let (todayDate, _, _) = setTodayCalendar()
        let timestamp = Timestamp(date: todayDate)
        guard let albumId = currentUser?.coupleAlbumId else { return }

        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: albumId)
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
                          albumId: albumId,
                          isCompleted: false)
                    .convertToDictionary()
                )
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func setDiptychNumber() async {
        guard let albumId = currentUser?.coupleAlbumId else { return }

        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: albumId)
                .whereField("isCompleted", isEqualTo: true)
                .getDocuments()
            
            diptychNumber += querySnapshot.documents.count

            guard let isCompleted = todayPhoto?.isCompleted else { return }
            if isCompleted { diptychNumber -= 1 }

        } catch {
            print(error.localizedDescription)
        }
    }

    // MARK: - Custom Methods

    func setTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        let todayDateString = formatter.string(from: Date())

        return todayDateString
    }

    // TODO: - 커스텀 함수들 정리하기!!!!!!!!!!!!!!!!!!!!!!!!!!!! 

    func calculateThisMondayDate() -> Date {
        let (todayDate, calendar, daysAfterMonday) = setTodayCalendar()
        guard let thisMonday = calendar.date(byAdding: .day, value: -daysAfterMonday, to: todayDate) else { return Date() }
        return thisMonday
    }

    func calculateThisTodayTimestamp() -> Timestamp {
        let (todayDate, calendar, daysAfterMonday) = setTodayCalendar()
        let timestamp = Timestamp(date: todayDate)
        return timestamp
    }

    func calculateThisMondayTimestamp() -> Timestamp {
        let (todayDate, calendar, daysAfterMonday) = setTodayCalendar()
        guard let thisMonday = calendar.date(byAdding: .day, value: -daysAfterMonday, to: todayDate) else { return Timestamp() }
        let timestamp = Timestamp(date: thisMonday)
        return timestamp
    }

    func setTodayDate() -> Int {
        let (todayDate, calendar, _) = setTodayCalendar()
        guard let day = calendar.dateComponents([.day], from: todayDate).day else { return 0 }
        return day
    }

    func setTodayCalendar() -> (Date, Calendar, Int) {
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
