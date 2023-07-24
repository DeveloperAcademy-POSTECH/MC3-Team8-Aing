//
//  CalendarView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//


import SwiftUI
  

struct CalendarView: View {
    
    ///Property
//    @StateObject var VM = AlbumViewModel()
    @State var date: Date
    let changeMonthInt : Int
    
    var body: some View {
        
        return VStack(spacing: 0) {
            oneMonthCalendarView
        }//】 VStack
        .onAppear{
            changeMonth(by: changeMonthInt)
        }
        
    }//】 body
    
  
    
  // MARK: - 월별 캘린더 뷰
    private var oneMonthCalendarView: some View {
        let daysInMonth: Int = numberOfDays(in: date)
        let firstWeekday: Int = firstWeekdayOfMonth(in: date) - 2

        return VStack(spacing: 0) {
        
            /// [1] Month
            HStack(spacing: 0) {
                Text(date, formatter: Self.monthFormatter)
                    .font(.system(size:36, weight: .light))
                    .padding(.leading,15)
                Spacer()
                Text(date, formatter: Self.yearFormatter)
                    .font(.title2)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                    .padding(.trailing,15)
            }//】 HStack
            .padding(.bottom,30)
        
            
            /// [2] Week
            HStack(spacing: 0) {
                ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size:14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.gray)
                }//: Loop
            }//】 HStack
            .padding(.bottom, 30)
            .padding(.horizontal,13)
        
            
            
            /// [3] Day
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7),spacing: 0) {
                ForEach(0 ..< daysInMonth + firstWeekday, id: \.self) { index in

                    /// 빈칸 표시
                    if index < firstWeekday {
                        Color.clear
                    }
                    /// 날짜 표시
                    else {
                        CellView(day: index - firstWeekday + 1,
                                 isToday: index - firstWeekday + 1
                                    == Calendar.current.component(.day, from: Date())
                                 && changeMonthInt == 0
                        )
                    }
                }//: Loop
            }//: LazyGrid
            .padding(.horizontal,15)
            .padding(.bottom, 51)
           
        }//】 VStack
        .padding(.top,10)
    }//: oneMonthCalendarView

}





// MARK: - 내부 메서드
extension CalendarView {
  
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
