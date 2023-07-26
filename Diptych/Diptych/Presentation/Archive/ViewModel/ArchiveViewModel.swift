//
//  AlbumViewModel.swift
//  Diptych
//
//  Created by Koo on 2023/07/26.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage


struct Photos {
    let isCompleted: Bool
    let thumbnail: String?
    let photoFirstURL: String?
    let photoSecondURL: String?
    let date: Date
    let month: Int
    
}

@MainActor
final class ArchiveViewModel: ObservableObject {

    // MARK: - Properties

    @Published var question = ""
    @Published var currentUser: DiptychUser?
    @Published var isFirst = true
    @Published var photos = [Photos]()
    @Published var isLoading = false
    @Published var contentDay = 0
    @Published var startDay = 0
    @Published var startDate: Timestamp?
    @Published var content: Content?
    @Published var todayPhoto: Photo?
    @Published var isCompleted = false
    private let db = Firestore.firestore()

    // MARK: - Initializer
    
    init() {
        Task {
            await fetchUser()
            await fetchStartDate()
            await fetchMonthlyCalender()
            await fetchContents()
        }
    }

    // MARK: - Network

    /// 포토 컬렉션 필드 데이터 가져오기
    func fetchMonthlyCalender() async {
        guard let albumId = currentUser?.coupleAlbumId else { return }
        guard let startDate = startDate else { return }
        
        do {
            let querySnapshot = try await db.collection("photos")
                .whereField("albumId", isEqualTo: albumId)
                .whereField("date", isGreaterThanOrEqualTo: startDate)
                .getDocuments()

            for document in querySnapshot.documents {
                let photo = try document.data(as: Photo.self)

                let isCompleted = photo.isCompleted
                let thumbnail = photo.thumbnail
                let firstPhoto = photo.photoFirst
                let secondPhoto = photo.photoSecond
                let date = Date(timeIntervalSince1970: TimeInterval(photo.date.seconds))
                
                guard let month = Calendar.current.dateComponents([.month], from: date).month else { return }
                
                if isCompleted {
                    await MainActor.run {
                        photos.append(Photos(isCompleted: true,
                                             thumbnail: thumbnail,
                                             photoFirstURL: firstPhoto,
                                             photoSecondURL: secondPhoto,
                                             date: date,
                                             month: month))
                    }
                } else {
                    await MainActor.run {
                        photos.append(Photos(isCompleted: false,
                                             thumbnail: nil,
                                             photoFirstURL: nil,
                                             photoSecondURL: nil,
                                             date: date,
                                             month: month))
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }//: fetchDiptychCalender
    
    
    /// 시작 날짜 가져오기
    func fetchStartDate() async {
        guard let albumId = currentUser?.coupleAlbumId else { return }
        do {
            let startDaySnapshot = try await db.collection("albums")
                .whereField("id", isEqualTo: albumId)
                .getDocuments()

            
            let data = startDaySnapshot.documents[0].data()
            guard let startDate = data["startDate"] as? Timestamp else { return }
            
            let startDay = startDate.dateValue().get(.day)
            self.startDay = startDay
            self.startDate = startDate

        } catch {
            print(error.localizedDescription)
        }
       
    }//:fetchStartDate
    
    
    


//MARK: - User
    
    /// 유저 정보 불러오기
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try? snapshot.data(as: DiptychUser.self)
        } catch {
            print(error.localizedDescription)
        }
    }
    
  

    
//MARK: - Contents
    func fetchContents() async {
        guard let albumId = currentUser?.coupleAlbumId else { return }

        do {
            let daySnapshot = try await db.collection("albums")
                .whereField("id", isEqualTo: albumId)
                .getDocuments()

            let data = daySnapshot.documents[0].data()
            guard let contentDay = data["contentDay"] as? Int else { return }
            self.contentDay = contentDay

            
            let contentSnapshot = try await db.collection("contents")
                .whereField("order", isEqualTo: contentDay) 
                .getDocuments()

            self.content = try contentSnapshot.documents[0].data(as: Content.self)
            guard let question = content?.question else { return }
            self.question = question.replacingOccurrences(of: "\\n", with: "\n")
        } catch {
            print(error.localizedDescription)
        }
    }

//    func setTodayPhoto() async {
//        let (todayDate, _, _) = setTodayCalendar()
//        let timestamp = Timestamp(date: todayDate)
//        guard let albumId = currentUser?.coupleAlbumId else { return }
//
//        do {
//            let querySnapshot = try await db.collection("photos")
//                .whereField("albumId", isEqualTo: albumId)
//                .whereField("date", isEqualTo: timestamp)
//                .getDocuments()
//
//            if querySnapshot.documents.isEmpty {
//                let autoGeneratedId = self.db.collection("photos").document().documentID
//                try await db.collection("photos").document(autoGeneratedId).setData(
//                    Photo(id: autoGeneratedId,
//                          photoFirst: "",
//                          photoSecond: "",
//                          thumbnail: "",
//                          date: timestamp,
//                          contentId: "",
//                          albumId: albumId,
//                          isCompleted: false)
//                    .convertToDictionary()
//                )
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//    }

// MARK: - Custom Methods

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
