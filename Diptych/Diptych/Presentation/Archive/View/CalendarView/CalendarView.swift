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
        
        return VStack(spacing: 0) {
            MonthlyCalendarView
        }//】 VStack
        .onAppear{
            changeMonth(by: changeMonthInt)
        }

    }//】 body
    
    
    // MARK: - 월별 캘린더 뷰
    private var MonthlyCalendarView: some View {
        
    let daysInMonth: Int = numberOfDays(in: date)
    let firstWeekday: Int = firstWeekdayOfMonth(in: date) - 2
        
    let today = Date()
    let calendar = Calendar.current

    return VStack(spacing: 0) {
            
    /// [1] Month
        VStack(spacing:0){
            HStack(alignment: .bottom, spacing:0) {
                Text(date, formatter: Self.monthFormatter)
                    .font(.system(size:36, weight: .light))
                Spacer()
                Text(date, formatter: Self.yearFormatter)
                    .font(.system(size:20, weight: .light))
                    .foregroundColor(.gray)
            }//】 HStack
            .padding(.bottom,13)
//            .frame(alignment: .bottom)
            
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(Color.darkGray)
                .frame(height: 1)
        }//】 VStack
        .padding(.horizontal,13)
        .padding(.bottom,15)
                
                    
    /// [2] Week
        HStack(spacing: 0) {
            ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size:14, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.gray)
            }//: Loop
        }//】 HStack
        .padding(.bottom, 20)
        .padding(.horizontal,13)
                
                    
    /// [3] Day
        if VM.isLoading {
            ProgressView()
        } else {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7),spacing: 0) {
                ForEach(0 ..< daysInMonth + firstWeekday, id: \.self) { index in
                        
                    if index < firstWeekday {
                        Color.clear /// 빈칸 표시
                    } else {
                            
                        let day = index - firstWeekday + 1
                        let data = VM.photos
                        let data2 = VM.questions
                        let start = VM.startDay // 18(일)
                        let safeIndex = day - start
                        let isToday: Bool = calendar.component(.day, from: today) == day && changeMonthInt == 0
                        let isSafe: Bool = safeIndex >= 0 && safeIndex < data.count && !data.isEmpty && !data2.isEmpty
                        let indexIsCompleted: Bool = isSafe ? data[safeIndex].isCompleted : false
                        let isThisMonth: Bool = isSafe ? data[safeIndex].month - calendar.component(.month, from: today) == changeMonthInt : false
                        let isMatched: Bool = isThisMonth && indexIsCompleted
                        
                        let currentIndex = isSafe ? indexOfCompleted(safeIndex) : 0
                        
                        let CVTrue = CellView(
                                        day: day,
                                        isToday: isToday,
                                        isThisMonth: true,
                                        isCompleted: true,
                                        thumbnail: isSafe ? data[safeIndex].thumbnail : "")
                        
                        let CVFalse = CellView(
                                        day: day,
                                        isToday: isToday,
                                        isThisMonth: false,
                                        isCompleted: false,
                                        thumbnail: "")
                            
                        
                       
                        /// 날짜 표기 시작
                        if isMatched {
                            NavigationLink {
                                    PhotoDetailView(
                                        date: isSafe ? data[safeIndex].date : today,
                                        image1: isSafe ? data[safeIndex].photoFirstURL : "",
                                        image2: isSafe ? data[safeIndex].photoSecondURL : "",
                                        question: isSafe ? data2[safeIndex].question : "",
                                        currentIndex: isSafe ? currentIndex : 0
                                    )
                                    .environmentObject(VM)
                            } label: {
                                CVTrue
                            }
                            .navigationTitle("")
                        } else {
                            CVFalse
                        }
                          
                    }//:if
                }//】 Loop
            }//】 Grid
            .padding(.horizontal,15)
            .padding(.bottom, 20)
        }
            
    }//】 VStack
    .padding(.top,20)
        
}//: oneMonthCalendarView

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
