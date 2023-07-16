//
//  WeeklyCalenderView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI

enum TodayDiptych {
    case complete
    case half
    case incomplete
}

enum WeeklytDiptych {
    case complete
    case incomplete
    case future
}

struct WeeklyCalenderView: View {
    @State var day: String
    @State var isToday: Bool
    var todayDiptych = TodayDiptych.incomplete
    var weeklyDiptych = WeeklytDiptych.future

    var body: some View {
        VStack(spacing: 9) {
            Text(day)
                .font(.pretendard(.medium, size: 14))

            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.salmon, lineWidth: isToday ? 2 : 0)
                    .frame(width: 44, height: 50)
                    .overlay(
                        Group {
                            if isToday {
                                switch todayDiptych {
                                case .complete:
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.salmon)
                                case .half:
                                    RoundedRectangle(cornerRadius: 18)
                                        .trim(from: 0.25, to: 0.75)
                                        .fill(Color.salmon)
                                case .incomplete:
                                    EmptyView()
                                }
                            } else {
                                switch weeklyDiptych {
                                case .complete:
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.salmon)
                                case .incomplete:
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color.lightGray)
                                case .future:
                                    EmptyView()
                                }
                            }
                        }
                    )
                Text("07")
                    .font(.pretendard(.bold, size: 16))
                    .foregroundColor(.offBlack)
                    .padding(.top, 7)
            }
        }
    }
}

struct WeeklyCalenderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeeklyCalenderView(day: "월", isToday: true)
            WeeklyCalenderView(day: "월", isToday: false)
        }
        .previewLayout(.sizeThatFits)
    }
}
