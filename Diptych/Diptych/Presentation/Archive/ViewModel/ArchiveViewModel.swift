//
//  AlbumViewModel.swift
//  Diptych
//
//  Created by Koo on 2023/07/26.
//

import SwiftUI
import Foundation


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
    // TODO: - Photos과 Question을 같이 관리할 수는 없는지?
    @Published var photos: [Photos] = [Photos]()
    @Published var questions: [Questions] = [Questions]()
    @Published var truePhotos: [Photos] = []
    @Published var trueQuestions: [Questions] = []
    @Published var isLoading = false
    
    @Published var startDay = 0
    @Published var startDate: Date? //fetchMonthlyCalender에서 사용
    @Published var todayPhoto: Photo?
    @Published var isCompleted = false

    // MARK: - Initializer
    
    init() {
        Task {
//            await fetchQuestion()
            await fetchUser()
            await fetchStartDate()
            await fetchPhotosData()
            _ = await makeTruePhotos()
//            _ = await makeTrueQuestions()
        }
        
        // TODO: - [Mockup] 사진 한개
        photos.append(.init(isCompleted: true,
                            thumbnail: "https://avatars.githubusercontent.com/u/40187546?v=4",
                            photoFirstURL: "https://avatars.githubusercontent.com/u/40187546?v=4",
                            photoSecondURL: "https://avatars.githubusercontent.com/u/40187546?v=4",
                            contentID: "fakeID_1",
                            date: Date(timeIntervalSince1970: 1693573888),
                            month: 9))
//        questions.append(.init(id: "fakeID_1", question: "오늘 본 동그라미는?"))
//        questions.append(.init(id: "fakeID_2", question: "오늘 본 동그라미는?"))
    }

    //MARK: - 컨텐츠 필드  데이터 가져오기
//    func fetchQuestion() async {
//        // db.collection("contents")
//
//        // TODO: - [Backend] 질문 가져오기
//        self.questions = [Questions(id: UUID().uuidString, question: "서버로부터 가져온 질문")]
//    }
    
    // MARK: - 컨텐츠 컬랙션에서 완성된 질문만 배열 만들기
//    func makeTrueQuestions() async -> [Questions] {
//        trueQuestions = photos.map { photo in
//            if let contentId = photo.contentID,
//               let question = questions.first(where: { $0.id == contentId }),
//               photo.isCompleted {
//                return question
//            } else {
//                return Questions(id: UUID().uuidString, question: "오늘 나에게 감명깊은 에러는?")
//            }
//        }
//        return trueQuestions
//    }
    
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
        // db.collection("albums").whereField("id", isEqualTo: albumId)
        
        let startDate = Date(timeIntervalSince1970: 1687279445)
        let startDay = startDate.get(.day)
        self.startDay = startDay
        self.startDate = startDate
    }
    
    
    
    //MARK: - 포토 컬렉션 필드 데이터 가져오기
    func fetchPhotosData() async {
        guard let albumId = currentUser?.coupleAlbumId else { return }
        guard let startDate = startDate else { return }
        
        // db.collection("photos").whereField("albumId", isEqualTo: albumId)
        //     .whereField("date", isGreaterThanOrEqualTo: startDate)
        
        // TODO: - [Backend] photo는 서버에서 가져옴
        let photo = Photo(id: UUID().uuidString,
                          photoFirst: "",
                          photoSecond: "",
                          thumbnail: "",
                          date: Date(),
                          contentId: "",
                          albumId: "",
                          isCompleted: false)
        let isCompleted = photo.isCompleted
        let thumbnail = photo.thumbnail
        let firstPhoto = photo.photoFirst
        let secondPhoto = photo.photoSecond
        let contentId = photo.contentId
        let date = photo.date
        guard let month = Calendar.current.dateComponents([.month], from: date).month else { return }
        
        // Photos 배열 생성
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
    
    
    //MARK: - 유저 정보 불러오기
    
    func fetchUser() async {
        /*
         서버로부터 유저 정보 가져온 뒤 self.currentUser에 저장
         self.currentUser = try? snapshot.data(as: DiptychUser.self)
         */
        
        self.currentUser = DiptychUser(id: "test", email: "test@test.com", flow: "what?")
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
