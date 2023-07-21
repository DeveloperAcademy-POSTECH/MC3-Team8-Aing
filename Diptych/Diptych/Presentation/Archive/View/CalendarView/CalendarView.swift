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
                }//: Loop
            }//】 HStack
            .padding(.bottom, 10)
            .padding(.horizontal,13)
        
            
            
            /// [3] Day
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7),
                      spacing: 0) {
                ForEach(0 ..< daysInMonth + firstWeekday, id: \.self) { index in
                    
//                    /// 로딩중
//                    if VM.isLoading {
//                        Text("로딩 중..")
//                    }
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
//                                 diptychState: VM.diptychData[index - firstWeekday + 1].diptychState
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




// MARK: - 날짜 CellView
private struct CellView: View {
    
    //property
    @State var day: Int
    @State var isToday: Bool
//    @State var thumbnail: String?
    var diptychState = DiptychState.complete
    
    var body: some View {
        

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
                        .stroke(Color.systemSalmon, lineWidth: isToday ? 2 : 0)
                        .frame(width: 44, height: 50)
                        .overlay {
                            
                            /// [1] 오늘 일 때
                            if isToday {
                                switch diptychState {
                                    case .incomplete: //미완성
                                        EmptyView()
                                    case .half: // 반만 완성
                                        RoundedRectangle(cornerRadius: 18)
                                            .trim(from: 0.25, to: 0.75)
                                            .fill(Color.systemSalmon)
                                    case .complete: // 완성
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.systemSalmon)
                                }
                            /// [2] 오늘이 아닐 때
                            } else {
                                switch diptychState {
                                    case .complete: //완성
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.lightGray)
                                    default: // 미완성
                                        EmptyView()
                                }
                            }
                        }
                    Text("\(day)")
                        .font(.pretendard(.bold, size: 16))
                        .foregroundColor(.offBlack)
                }//】 ZStack
                .padding(.bottom, 19)
            }//】 NavigationLink
        
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
