//
//  TodayDiptychView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI

struct TodayDiptychView: View {

    @StateObject private var viewModel = TodayDiptychViewModel()
    let days = ["월", "화", "수", "목", "금", "토", "일"]
    let dates = ["17", "18", "19", "20", "21", "22", "23"] // 일단 날짜 박아두기

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
                    // TODO: - 유저가 가입한 날짜와 연관하여 작업하기
                    Text("\"\(viewModel.question)\"")
                        .lineSpacing(6)
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
                        .overlay {
                            Image("imgDiptychCamera")
                                .onTapGesture {
                                    print("카메라뷰")
                                }
                        }
                    Rectangle()
                        .fill(Color.offBlack)
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1.0, contentMode: .fit)
                .padding(.bottom, 23)

                HStack(spacing: 9) {
                    if viewModel.isLoading {
                        Text("로딩 중..")
                    } else {
                        ForEach(0..<viewModel.weeklyData.count, id: \.self) { index in
                            if index == viewModel.weeklyData.count - 1 {
                                WeeklyCalenderView(day: days[index], date: dates[index], isToday: true, diptychState: viewModel.weeklyData[index])
                            } else {
                                WeeklyCalenderView(day: days[index], date: dates[index], isToday: false, diptychState: viewModel.weeklyData[index])
                            }
                         }
                        ForEach(viewModel.weeklyData.count..<7, id: \.self) { index in
                            WeeklyCalenderView(day: days[index], date: dates[index], isToday: false, diptychState: .incomplete)
                        }
                    }
                }
            }
            .padding(.bottom, 23)
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            Task {
                await viewModel.fetchWeeklyCalender()
            }
        }
    }
}

struct TodayDiptychView_Previews: PreviewProvider {
    static var previews: some View {
        TodayDiptychView()
    }
}
