//
//  TodayDiptychView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI

struct TodayDiptychView: View {
    let days = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        ZStack {
            Color.offWhite

            VStack(spacing: 0) {
                HStack {
                    Text("오늘의 주제")
                        .font(.pretendard(.medium, size: 16))
                        .foregroundColor(.offBlack)
                        .padding(.vertical, 7)
                        .padding(.leading, 9)
                        .padding(.trailing, 10)
                        .background(Color.lightGray)
                    Spacer()
                    Image("imgNotification")
                }
                .padding(.horizontal, 15)
                .padding(.top, 79)

                HStack {
                    Text("\"상대방의 표정 중 당신이\n가장 좋아하는 표정은?\"")
                        .font(.pretendard(.light, size: 28))
                        .foregroundColor(.offBlack)
                        .padding(.top, 12)
                        .padding(.leading, 15)
                        .padding(.bottom, 34)
                    Spacer()
                }

                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.lightGray)
                    Rectangle()
                        .fill(Color.offBlack)
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1.0, contentMode: .fit)
                .padding(.bottom, 23)

                HStack(spacing: 9) {
//                    ForEach(0..<7) { index in
//                        WeeklyCalenderView(day: days[index])
//                    }
                    WeeklyCalenderView(day: days[0], isToday: false)
                    WeeklyCalenderView(day: days[1], isToday: false)
                    WeeklyCalenderView(day: days[2], isToday: true)
                    WeeklyCalenderView(day: days[3], isToday: false)
                    WeeklyCalenderView(day: days[4], isToday: false)
                    WeeklyCalenderView(day: days[5], isToday: false)
                    WeeklyCalenderView(day: days[6], isToday: false)
                }
            }
            .padding(.bottom, 23)
        }
        .ignoresSafeArea(edges: .top)
    }
}

struct TodayDiptychView_Previews: PreviewProvider {
    static var previews: some View {
        TodayDiptychView()
    }
}
