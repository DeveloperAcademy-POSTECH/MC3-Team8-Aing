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
    let contentID: String?
    let date: Date
    let month: Int
}

struct Questions {
    let order: Int
    let question: String?
}

@MainActor
final class ArchiveViewModel: ObservableObject {

    // MARK: - Properties

    @Published var questions = [Questions]()
    @Published var currentUser: DiptychUser?
    @Published var isFirst = true
    @Published var photos = [Photos]()
    @Published var isLoading = false
    @Published var contentId = "" //fetchQuestion에서 사용
    @Published var startDay = 0
    @Published var startDate: Timestamp? //fetchMonthlyCalender에서 사용
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
            await fetchQuestion()
        }
    }

// MARK: - Network
    /// 컨텐츠 필드  데이터 가져오기
    func fetchQuestion() async {
        var contentId = contentId
        
        do {
            let contentSnapshot = try await db.collection("contents")
                .whereField("contentId", isEqualTo: contentId )
                .whereField("order", isGreaterThanOrEqualTo: 0 )
                .getDocuments()
            
            for document in contentSnapshot.documents {
                let content = try document.data(as: Content.self)
                let order = content.order
                let question = content.question
                
                /// 질문 배열 생성
                await MainActor.run{
                    questions.append(Questions(order: order,question: question))
                }
                print("🍠:", questions)
            }
        } catch {
            print(error.localizedDescription)
        }
    }//: fetchDiptychCalender
    
    
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
                let contentId = photo.contentId
                let date = Date(timeIntervalSince1970: TimeInterval(photo.date.seconds))
                
                guard let month = Calendar.current.dateComponents([.month], from: date).month else { return }
                
                self.contentId = contentId
                
                /// Photos 배열 생성
                if isCompleted {
                    await MainActor.run {
                        photos.append(Photos(isCompleted: true,
                                             thumbnail: thumbnail,
                                             photoFirstURL: firstPhoto,
                                             photoSecondURL: secondPhoto,
                                             contentID: contentId,
                                             date: date,
                                             month: month))
                    }
                } else {
                    await MainActor.run {
                        photos.append(Photos(isCompleted: false,
                                             thumbnail: nil,
                                             photoFirstURL: nil,
                                             photoSecondURL: nil,
                                             contentID: contentId,
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
