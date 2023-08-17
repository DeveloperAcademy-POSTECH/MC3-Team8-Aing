//
//  CalendarView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//


import SwiftUI
import Foundation

struct CalendarView: View {
    
    ///Property
    @EnvironmentObject var VM : ArchiveViewModel
    @State var date: Date
    let changeMonthInt : Int
    
    var body: some View {
        VStack(spacing: 0) {
            // let _ = print("MonthlyCalendarView called", changeMonthInt)
            MonthlyCalendarView(changeMonthInt: changeMonthInt, VM: VM, today: date)
            
            // MonthlyCalendarView(date: date, changeMonthInt: changeMonthInt, VM: VM)
            // Text("Disco")
        }//】 VStack
        .onAppear{
            
        }
        
    }//】 body
}// Struct

// MARK: - 내부 메서드
extension CalendarView {
    
    /// True 컬랙션 index 가져오기
    private func indexOfCompleted(_ index: Int) -> Int {
        guard let completedPhoto = VM.photos[index].thumbnail else { return 0 }
        return VM.truePhotos.firstIndex { $0.thumbnail == completedPhoto } ?? 0
    }
    
    /// 이번달 날짜 수
    func numberOfDays(in data: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: data)?.count ?? 0
    }
    
    /// 이번달 1일 몇번째 요일 -> Int (일요일 = 0)
    func firstWeekdayOfMonth(in data: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: data)
        let firstDayOfMonth = Calendar.current.date(from: components)!
        // print(#function, data, Calendar.current.component(.weekday, from: firstDayOfMonth))
        return Calendar.current.component(.weekday, from: firstDayOfMonth)
    }
    
    /// Month 변경 로직
    func changeMonth(by data: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: data, to: date) {
            self.date = newMonth
        }
    }
    
    /// 월 표기
    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"
        return formatter
    }()
    
    /// 연도 표기
    static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년"
        return formatter
    }()
    
    /// 요일 표기
    static let weekdaySymbols: [String] = ["월", "화", "수", "목", "금", "토", "일"]
}


// MARK: - Previews
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(date: Date(), changeMonthInt: 0)
    }
}
