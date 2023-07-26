//
//  CalendarView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//


import SwiftUI
  

struct CalendarView: View {
    
    ///Property
    @StateObject private var VM = AlbumViewModel()
    @State var date: Date
    let changeMonthInt : Int
    
    var body: some View {
        
        return VStack(spacing: 0) {
            MonthlyCalendarView
        }//】 VStack
        .onAppear{
            changeMonth(by: changeMonthInt)
            
            Task {
                await VM.fetchStartDate()
            }
        }
        
    }//】 body
    
    
    // MARK: - 월별 캘린더 뷰
    private var MonthlyCalendarView: some View {
        
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
            if VM.isLoading {
                ProgressView()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7),spacing: 0) {
                    ForEach(0 ..< (daysInMonth + firstWeekday), id: \.self) { index in

                        let day = index - firstWeekday + 1
                        let data = VM.photos
                        let start = VM.startDay // 18(일)
                        let isToday = day == Calendar.current.component(.day, from: Date()) && changeMonthInt == 0
                        let safeIndex = day - start
                        let isSafeIndex : Bool = safeIndex >= 0 && safeIndex < data.count
                        let indexIsCompleted: Bool = isSafeIndex ? !data.isEmpty && data[safeIndex].isCompleted : false
                        
                        let cellViewFalse = CellView(day: day,
                                                     isToday: isToday,
                                                     isCompleted: false,
                                                     thumbnail: "")
                        
                        let cellViewTrue = CellView(day: day,
                                                    isToday: isToday,
                                                    isCompleted: true,
                                                    thumbnail: isSafeIndex && !data.isEmpty ? data[safeIndex].thumbnail : "")
                        
                        
                        
                        let photoDetailView = PhotoDetailView(date: "더미더미더미",
                                                              questionNum: 3,
                                                              question: "더미더미더미더미더미더미",
                                                              imageUrl1: "",
                                                              imageUrl2: "")
                        
                   
                        if index < firstWeekday {
                            EmptyView() /// 빈칸 표시
                        }else {
                            if indexIsCompleted {
                                // isSafeIndex && !data.isEmpty && data[dataIndex].isCompleted -> 위에서 선언
                                    NavigationLink {
                                        photoDetailView
                                    } label: {
                                        cellViewTrue
                                    }
                            } else {
                                cellViewFalse
                            }
                            
                        }

                    }//: Loop
                }//: LazyGrid
                .padding(.horizontal,15)
                .padding(.bottom, 51)
            }//if
               
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
