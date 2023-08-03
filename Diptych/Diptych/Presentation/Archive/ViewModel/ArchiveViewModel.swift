//
//  AlbumViewModel.swift
//  Diptych
//
//  Created by Koo on 2023/07/26.
//

import SwiftUI
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

struct Questions{
    let id: String?
    let question: String?
}


@MainActor
final class ArchiveViewModel: ObservableObject {

    // MARK: - Properties

    @Published var currentUser: DiptychUser?
    @Published var photos: [Photos] = [Photos]()
    @Published var questions: [Questions] = [Questions]()
    @Published var truePhotos: [Photos] = []
    @Published var trueQuestions: [Questions] = []
    @Published var isLoading = false
    
    @Published var startDay = 0
    @Published var startDate: Timestamp? //fetchMonthlyCalender에서 사용
    @Published var todayPhoto: Photo?
    @Published var isCompleted = false
    private let db = Firestore.firestore()

    // MARK: - Initializer
    
    init() {
        Task {
            await fetchUser()
            await fetchStartDate()
            await fetchPhotosData()
            await fetchQuestion()
            _ = await makeTruePhotos()
            _ = await makeTrueQuestions()
            print("🥦:ArchiveViewModel")
        }
    }

    //MARK: - 컨텐츠 필드  데이터 가져오기
    func fetchQuestion() async {
        do {
            let contentSnapshot = try await db.collection("contents")
                .whereField("order", isGreaterThanOrEqualTo: 0)
                .getDocuments()
            self.questions = contentSnapshot.documents.compactMap { document in
                guard let question = document.data()["question"] as? String,
                      let id = document.data()["id"] as? String
                else {return nil}
                return Questions(id: id, question: question)
            }
        } catch { print(error.localizedDescription) }
    }
    
    // MARK: - 컨텐츠 컬랙션에서 완성된 질문만 배열 만들기
    func makeTrueQuestions() async -> [Questions] {
//        photos.forEach { photo in
//              if photo.isCompleted, let contentID = photo.contentID {
//                  let data = questions.filter { $0.id == contentID }
//                  trueQuestions.append(contentsOf: data)
//              }
//          }
        trueQuestions = photos.map { photo in
              if let contentId = photo.contentID,
                 let question = questions.first(where: { $0.id == contentId }),
                 photo.isCompleted {
                  return question
              } else {
                  return Questions(id: UUID().uuidString, question: "오늘 나에게 감명깊은 에러는?")
              }

          }
        return trueQuestions
    }
    
    // MARK: - 포토 컬랙션에서 완성된 사진만 배열 만들기
    func makeTruePhotos() async -> [Photos] {
        photos.forEach { data in
            if data.isCompleted {
                self.truePhotos.append(data)
            }
        }//】 Loop
        return truePhotos
    }
    
    // MARK: - 시작 날짜 가져오기
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
        } catch { print(error.localizedDescription) }
    }//:fetchStartDate
    
    
    
    //MARK: - 포토 컬렉션 필드 데이터 가져오기
    func fetchPhotosData() async {
        guard let albumId = currentUser?.coupleAlbumId else { return }
        guard let startDate = startDate else { return }
        do {
//            if 변화사항 있어? {
//
//            } else {
//                if 캐싱 된거 있어? {
//                    캐싱 된거 씀
//                } else {
//
//                }
//            }
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
                
                /// Photos 배열 생성
                if isCompleted {
                    await MainActor.run {
                        photos.append(Photos(isCompleted: true, thumbnail: thumbnail,
                                             photoFirstURL: firstPhoto, photoSecondURL: secondPhoto,
                                             contentID: contentId, date: date, month: month))
                    }
                } else {
                    await MainActor.run {
                        photos.append(Photos(isCompleted: false, thumbnail: nil,
                                             photoFirstURL: nil, photoSecondURL: nil,
                                             contentID: contentId, date: date, month: month))
                    }
                }
            }
        } catch { print(error.localizedDescription) }
    }//: fetchDiptychCalender
    
    
    //MARK: - 유저 정보 불러오기
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            self.currentUser = try? snapshot.data(as: DiptychUser.self)
        } catch { print(error.localizedDescription) }
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
