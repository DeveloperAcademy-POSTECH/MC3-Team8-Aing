//
//  TodayDiptychViewModel.swift
//  Diptych
//
//  Created by 김민 on 2023/07/19.
//

import Foundation

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
    @Published var weeklyData = [WeeklyData]()
    @Published var content: Content?
    @Published var todayPhoto: Photo?
    @Published var photoFirstURL = ""
    @Published var photoSecondURL = ""
    @Published var isCompleted = false
    @Published var photoFirstState = TodayDiptychState.incomplete
    @Published var photoSecondState = TodayDiptychState.incomplete
    @Published var diptychNumber = 1
    
    // MARK: - Network
    
    func fetchWeeklyCalender() async {
        guard let albumId = currentUser?.coupleAlbumId else { return }
        
        // TODO: - [Backend]
        weeklyData.append(WeeklyData(date: 0, diptychState: isCompleted ? .complete : .incomplete))
        
        guard let todayPhoto = self.todayPhoto else { return }
        let date = Date()
        guard let day = Calendar.current.dateComponents([.day], from: date).day else { return }
        
        if todayPhoto.isCompleted {
            weeklyData.append(WeeklyData(date: day, diptychState: .complete))
        } else if !todayPhoto.photoFirst.isEmpty && todayPhoto.photoSecond.isEmpty {
            weeklyData.append(WeeklyData(date: day, diptychState: .todayfirst))
        } else if todayPhoto.photoFirst.isEmpty && !todayPhoto.photoSecond.isEmpty {
            weeklyData.append(WeeklyData(date: day, diptychState: .todaySecond))
        } else {
            weeklyData.append(WeeklyData(date: day, diptychState: .todayIncomplete))
        }
    }
    
    func fetchTodayImage() async {
        guard let albumId = currentUser?.coupleAlbumId else { return }
        
        // let querySnapshot = try await db.collection("photos")
        //     .whereField("albumId", isEqualTo: albumId)
        //     .whereField("date", isGreaterThanOrEqualTo: timestamp)
        //     .getDocuments()
        
        // TODO: - [Backend]
        self.todayPhoto = Photo(id: "", photoFirst: "", photoSecond: "", thumbnail: "", date: Date(), contentId: "", albumId: "", isCompleted: false)
        
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
        // TODO: - [Backend]
        self.currentUser = DiptychUser(id: "", email: "", flow: "")
    }
    
    func setUserCameraLoactionState() async {
        guard let isFirst = currentUser?.isFirst else { return }
        self.isFirst = isFirst
    }
    
    func fetchContents() async {
        guard let albumId = currentUser?.coupleAlbumId else { return }
        
        // let daySnapshot = try await db.collection("albums")
        //     .whereField("id", isEqualTo: albumId)
        //     .getDocuments()
        
        // TODO: - [Backend]
        let startDate = Date(timeIntervalSince1970: 1695228245)
        let dateComponents = Calendar.current.dateComponents([.day], from: startDate, to: Date())
        guard var order = dateComponents.day else { return }
        
        let contentsCount = 5
        // let contentSnapshot = try await db.collection("contents")
        //     .whereField("order", isEqualTo: order % contentsCount)
        //     .getDocuments()
        
        // TODO: - [Backend]
        self.content = Content(id: "", question: "", order: 0, guideline: "", toolTip: "", toolTipImage: "")
        guard let question = content?.question else { return }
        self.question = question.replacingOccurrences(of: "\\n", with: "\n")
    }
    
    func setTodayPhoto() async {
        let (todayDate, _, _) = setTodayCalendar()
        guard let albumId = currentUser?.coupleAlbumId else { return }
        
        // let querySnapshot = try await db.collection("photos")
        //     .whereField("albumId", isEqualTo: albumId)
        //     .whereField("date", isEqualTo: timestamp)
        //     .getDocuments()
        
        // TODO: - [Backend]
        Photo(id: UUID().uuidString,
              photoFirst: "",
              photoSecond: "",
              thumbnail: "",
              date: Date(),
              contentId: "",
              albumId: albumId,
              isCompleted: false)
    }
    
    func setDiptychNumber() async {
        guard let albumId = currentUser?.coupleAlbumId else { return }
        
        // let querySnapshot = try await db.collection("photos")
        //     .whereField("albumId", isEqualTo: albumId)
        //     .whereField("isCompleted", isEqualTo: true)
        //     .getDocuments()
        
        // TODO: - [Backend] Document? 수 카운트 가져오기
        let documentsCount = 10
        diptychNumber += documentsCount
        
        guard let isCompleted = todayPhoto?.isCompleted else { return }
        if isCompleted { diptychNumber -= 1 }
    }
    
    // MARK: - Custom Methods
    
    func setTodayCalendar() -> (Date, Calendar, Int) {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 00:00:00"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        let todayDateString = formatter.string(from: Date())
        let todayDate = formatter.date(from: todayDateString)!
        
        let currentWeekday = calendar.component(.weekday, from: todayDate)
        let daysAfterMonday = (currentWeekday + 5) % 7
        
        return (todayDate, calendar, daysAfterMonday)
    }
    
    func setTodayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        let todayDateString = formatter.string(from: Date())
        
        return todayDateString
    }
    
    func calculateThisMondayDate() -> Date {
        let (todayDate, calendar, daysAfterMonday) = setTodayCalendar()
        guard let thisMonday = calendar.date(byAdding: .day, value: -daysAfterMonday, to: todayDate) else { return Date() }
        return thisMonday
    }
    
    func setWeeklyDates() -> [Int] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: calculateThisMondayDate())
        let daysToAdd = (2...8).map { $0 - weekday }
        let weeklyDates = daysToAdd.map { calendar.date(byAdding: .day,
                                                        value: $0,
                                                        to: calculateThisMondayDate())! }
            .map { calendar.component(.day, from: $0) }
        return weeklyDates
    }
}
