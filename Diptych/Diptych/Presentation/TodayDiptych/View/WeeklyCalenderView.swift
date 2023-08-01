//
//  WeeklyCalenderView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI
import FirebaseStorage

struct WeeklyCalenderView: View {

    @State var day: String
    var diptychState = DiptychState.todaySecond

    var body: some View {
        ZStack {
            calenderWithDiptychState()
            Text(day)
                .font(.pretendard(.bold, size: 16))
                .foregroundColor(.offBlack)
        }
    }
}

// MARK: - UI Components

extension WeeklyCalenderView {

    private func calendarItem(trimFrom: CGFloat, trimTo: CGFloat, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 18)
            .trim(from: trimFrom, to: trimTo)
            .fill(color)
            .frame(width: 44, height: 44)
    }

    private func strokeCalenderItem(_ lineWidth: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 18)
            .stroke(Color.systemSalmon, lineWidth: lineWidth)
    }

    @ViewBuilder
    private func calenderWithDiptychState() -> some View {
        switch diptychState {
        case .none:
            calendarItem(trimFrom: 0, trimTo: 0, color: .clear)
        case .incomplete:
            calendarItem(trimFrom: 0, trimTo: 1, color: .lightGray)
        case .todayIncomplete:
            calendarItem(trimFrom: 0, trimTo: 1, color: .offWhite)
                .overlay {
                    strokeCalenderItem(2)
                }
        case .todayfirst:
            calendarItem(trimFrom: 0.25, trimTo: 0.75, color: .systemSalmon)
                .overlay(
                    strokeCalenderItem(2)
                )
        case .todaySecond:
            calendarItem(trimFrom: 0, trimTo: 1, color: .systemSalmon)
                .overlay(
                    calendarItem(trimFrom: 0.25, trimTo: 0.75, color: .offWhite)
                )
                .overlay {
                    strokeCalenderItem(2)
                }
        case .complete:
            calendarItem(trimFrom: 0, trimTo: 1, color: .systemSalmon)
        }
    }
}

struct WeeklyCalenderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeeklyCalenderView(day: "월")
            WeeklyCalenderView(day: "월")
        }
        .previewLayout(.sizeThatFits)
    }
}
