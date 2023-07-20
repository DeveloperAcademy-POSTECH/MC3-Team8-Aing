//
//  CalendarView.swift
//  Diptych
//
//  Created by Koo on 2023/07/17.
//


import SwiftUI
  

struct CalendarView: View {
    
    //property
    @StateObject var VM: AlbumViewModel = AlbumViewModel()
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
        let firstWeekday: Int = firstWeekdayOfMonth(in: date) - 1

        return VStack(spacing: 0) {
        
            /// [1]월
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
        
            /// [2]요일
            HStack(spacing: 0) {
                ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size:14, weight: .medium))
                        .frame(maxWidth: .infinity)
                }//: Loop
            }//】 HStack
            .padding(.bottom, 10)
            .padding(.horizontal,13)
        
            /// [3]날짜
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7),
                      spacing: 0) {
                ForEach(0 ..< daysInMonth + firstWeekday, id: \.self) { dayNum in
                    /// 빈칸 표시
                    if dayNum < firstWeekday {
                        Color.clear
                    }
                    /// 날짜 표시
                    else {
                        let day = dayNum - firstWeekday + 1
                        let currentDate = Calendar.current.component(.day, from: Date())
                        
                        /// 오늘 날짜 표시 
                        if dayNum - firstWeekday + 1 == currentDate && changeMonthInt == 0 {
                            CellView(day: day, cellColor: Color.systemSalmon)
                        }
                        /// 평소 날짜 표시
                        else {
                            CellView(day: day, cellColor:Color.gray.opacity(0.2))
                        }
                    }

                    
                }//: Loop
            }//: LazyGrid
            .padding(.horizontal,15)
            .padding(.bottom, 51)
           
        }//】 VStack
        .padding(.top,10)
        
        
        
    }//: oneMonthCalendarView

}




// MARK: - 날짜 CellView
private struct CellView: View {
    
    //property
    var day: Int
    var cellColor : Color
    
    var body: some View {
        
//        if {
            NavigationLink {
                PhotoDetailView(
                    date: "2023년 7월 30일",
                    questionNum: 20,
                    question: "\"상대방의 표정 중 당신이\n 가장 좋아하는 표정은?\"",
                    imageUrl1: "https://file.notion.so/f/s/1ed8775d-60cc-4907-b8f2-edf0acfb484f/%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9_3_copy_5_%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB_2.jpg?id=8dc957fa-bf1e-4daf-a72a-6be8e69213d6&table=block&spaceId=794074b4-a62e-40a9-9a73-2dc5a7035226&expirationTimestamp=1689933600000&signature=-ZApnHNSBN05IfP5KQJWDd_MUXwXBrAUPvTwjjdI-40&downloadName=%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9+3+copy+5+%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB+2.jpg",
                    imageUrl2: "https://file.notion.so/f/s/19b32819-43e4-446d-bcb8-917b17cfe2cd/%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9_3_copy_5_%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB.jpg?id=7fddf6e5-976e-4ed6-af14-be1ff9662108&table=block&spaceId=794074b4-a62e-40a9-9a73-2dc5a7035226&expirationTimestamp=1689933600000&signature=QECxg7nvN5ew0ajmMq5oCJmCV0SqyR7e7n8SwOAI804&downloadName=%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9+3+copy+5+%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB.jpg"
                    )
            } label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 18)
                        .frame(width: 44, height: 50)
                        .foregroundColor(cellColor)
                    
                    //                Image("DummyThumbnail_5")
                    //                    .resizable()
                    //                    .scaledToFill()
                    //                    .frame(width: 44, height: 50)
                    //                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    Text(String(day))
                        .font(.system(size:16, weight: .bold))
                        .foregroundColor(.black)
                        .offset(y:-13)
                }//】 ZStack
                .padding(.bottom, 19)
            }//】 NavigationLink
//        } else {
//            ZStack{
//                RoundedRectangle(cornerRadius: 18)
//                    .frame(width: 44, height: 50)
//                    .foregroundColor(Color.clear)
//
//                Text(String(day))
//                    .font(.system(size:16, weight: .bold))
//                    .foregroundColor(.black)
//                    .offset(y:-13)
//        }
        
    }//】 Body
}// CellView


// MARK: - 내부 메서드
private extension CalendarView {
  
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
        if let newMonth = Calendar.current.date(byAdding: .month, value: data, to: date) {
            self.date = newMonth
        }
    }
    
}


// MARK: - Static Property
extension CalendarView {
    
    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"
        return formatter
    }()
    
    static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년"
        return formatter
    }()
  
    static let weekdaySymbols: [String] = ["일", "월", "화", "수", "목", "금", "토"]
}

// MARK: - Previews
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(date: Date(), changeMonthInt: 0)
    }
}
