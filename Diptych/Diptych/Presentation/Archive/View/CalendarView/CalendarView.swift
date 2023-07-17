//
//  CalendarView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//


import SwiftUI
  

struct CalendarView: View {
    
    //property
    @State var month: Date
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
        let daysInMonth: Int = numberOfDays(in: month)
        let firstWeekday: Int = firstWeekdayOfMonth(in: month) - 1

        return VStack(spacing: 0) {
        
            /// [1]월
            HStack(spacing: 0) {
                Text(month, formatter: Self.dateFormatter)
                    .font(.system(size:36, weight: .light))
                    .padding(.leading,15)
                Spacer()
                Text(month, formatter: Self.dateFormatter2)
                    .font(.title2)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }//】 HStack
            .padding(.bottom,30)
        
            /// [2]요일
            HStack(spacing: 0) {
                ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size:14, weight: .medium))
                        .frame(maxWidth: .infinity)
                }//: Loop
            }//】 HStack
            .padding(.bottom, 10)
            .padding(.horizontal,9)
        
            /// [3]날짜
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7),
                      spacing: 0) {
                ForEach(0 ..< daysInMonth + firstWeekday, id: \.self) { index in
                    let day = index - firstWeekday + 1
                    //1일 이전
                    if index < firstWeekday {
                        Color.clear
                    }
                    //1일 이후 부터 날짜 표시
                    else {
                        CellView(day: day, cellColor: .gray.opacity(0.3))
                    }
//                  else {
//                      CellView(day: day,
//                              cellColor: index - firstWeekday == Data().day ? Color.gray : Color.orange
//                      )
//                  }
                }//: Loop
            }//: LazyGrid
            .padding(.horizontal,10)
           
        
        }//】 VStack
        
        .padding(.top,51)
        
    }//: oneMonthCalendarView

}




// MARK: - 날짜 CellView
private struct CellView: View {
    
    //property
    var day: Int
    var cellColor : Color
  
//    init(day: Int) {
//        self.day = day
//    }
  
    var body: some View {
        
            NavigationLink {
               //DetailView()
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 18)
                        .frame(width: 44, height: 50)
                        .foregroundColor(cellColor)
                    
                    Text(String(day))
                        .font(.system(size:16, weight: .bold))
                        .foregroundColor(.black)
                        .offset(y:-13)
                }//】 ZStack
                .padding(.bottom, 19)
            }//】 NavigationLink
        
        
    }//】 Body
}// CellView


// MARK: - 내부 메서드
private extension CalendarView {
    
    /// 특정 해당 날짜
//    private func getDate(for data: Int) -> Date {
//        return Calendar.current.date(byAdding: .day, value: data, to: startOfMonth())!
//    }
  
    /// 이번달 시작일
//    func startOfMonth() -> Date {
//        let components = Calendar.current.dateComponents([.year, .month], from: month)
//        return Calendar.current.date(from: components)!
//    }
  
    /// 이번달 날짜 수
    func numberOfDays(in data: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: data)?.count ?? 0
    }
  
    /// 이번달 1일 몇번째 요일 -> Int
    func firstWeekdayOfMonth(in data: Date) -> Int {
        let components = Calendar.current.dateComponents([.year, .month], from: data)
        let firstDayOfMonth = Calendar.current.date(from: components)!
    
        return Calendar.current.component(.weekday, from: firstDayOfMonth)
    }
  
    /// 월 변경
    func changeMonth(by data: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: data, to: month) {
            self.month = newMonth
        }
    }
    
}


// MARK: - Static Property
extension CalendarView {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"
        return formatter
    }()
    
    static let dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년"
        return formatter
    }()
  
    static let weekdaySymbols: [String] = ["일", "월", "화", "수", "목", "금", "토"]
}

// MARK: - Previews
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(month: Date(), changeMonthInt: 0)
    }
}
