//
//  Test.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/14.
//

//import SwiftUI
//
//struct Test: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//struct Test_Previews: PreviewProvider {
//    static var previews: some View {
//        Test()
//    }
//}

import SwiftUI

struct ContentView: View {
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(getCalendarDays(), id: \.self) { day in
                    Text(dateFormatter.string(from: day))
                        .frame(width: 40, height: 40)
                        .background(Color.gray)
                        .cornerRadius(20)
                }
            }
            .padding()
        }
    }
    
    private func getCalendarDays() -> [Date] {
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
        
        var dates: [Date] = []
        
        calendar.enumerateDates(startingAfter: startDate, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date < endDate {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
    
//    private func getMonthlyCalendar() -> View {
//
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
