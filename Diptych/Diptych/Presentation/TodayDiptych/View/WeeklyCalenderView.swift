//
//  WeeklyCalenderView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI

enum DiptychState {
    case incomplete
    case half
    case complete
}

struct WeeklyCalenderView: View {
    @State var day: String
    @State var date: String
    @State var isToday: Bool
    @State var thumbnail: String?
    var diptychState = DiptychState.incomplete

    var body: some View {
        VStack(spacing: 9) {
            Text(day)
                .font(.pretendard(.medium, size: 14))

            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.systemSalmon, lineWidth: isToday ? 2 : 0)
                    .frame(width: 44, height: 50)
                    .overlay {
                        /// [1] 오늘 일 때
                        if isToday {
                            switch diptychState {
                            case .incomplete:
                                EmptyView()
                            case .half:
                                RoundedRectangle(cornerRadius: 18)
                                    .trim(from: 0.25, to: 0.75)
                                    .fill(Color.systemSalmon)
                            case .complete:
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.systemSalmon)
                            }
                        /// [2] 오늘이 아닐 때
                        } else {
                            switch diptychState {
                            case .complete:
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.lightGray)
                            default:
                                EmptyView()
                            }
                        }
                    }
                Text(date)
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
            WeeklyCalenderView(day: "월", date: "07", isToday: true)
            WeeklyCalenderView(day: "월", date: "08", isToday: false)
        }
        .previewLayout(.sizeThatFits)
    }
}
