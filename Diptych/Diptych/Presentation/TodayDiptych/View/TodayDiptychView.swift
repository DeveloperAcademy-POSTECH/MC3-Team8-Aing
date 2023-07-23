//
//  TodayDiptychView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI
import FirebaseStorage

struct TodayDiptychView: View {

    @State var isShowCamera = false
    @StateObject private var viewModel = TodayDiptychViewModel()
    @State private var mondayDate = 0
    @State private var isAllTasksCompleted = false
    let days = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        ZStack {
            if isAllTasksCompleted {
                MainDiptychView()
            } else {
                ProgressView()
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            mondayDate = calculateThisWeekMondayDate()

            Task {
                await viewModel.fetchUser()
                await viewModel.setUserCameraLoactionState()
                await viewModel.fetchTodayImage()
                await viewModel.fetchWeeklyCalender()
                await viewModel.fetchContents()
                await viewModel.setTodayPhoto()
                
                DispatchQueue.main.async {
                    isAllTasksCompleted = true
                }
            }
        }
        .onDisappear {
            viewModel.weeklyData.removeAll()
        }
        .fullScreenCover(isPresented: $isShowCamera) {
            CameraRepresentableView()
                 .toolbar(.hidden, for: .tabBar)
        }
    }

    private func MainDiptychView() -> some View {
        ZStack {
            Color.offWhite
            VStack(spacing: 0) {
                HStack(spacing: 0) {
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
                .padding(.top, 35)

                HStack(spacing: 0) {
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
                    AsyncImage(url: URL(string: viewModel.photoFirstURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .overlay {
                                    if viewModel.isFirst && !viewModel.isCompleted {
                                        Image("imgRetry")
                                            .onTapGesture {
                                                isShowCamera = true
                                            }
                                    }
                                }
                        case .failure:
                            Rectangle()
                                .fill(Color.offWhite)
                        case .empty:
                            Rectangle()
                                .fill(Color.offBlack)
                                .overlay {
                                    if viewModel.isFirst {
                                        Image("imgDiptychCamera")
                                            .onTapGesture {
                                                isShowCamera = true
                                            }
                                    }
                                }
                        @unknown default:
                            ProgressView()
                        }
                    }
                    AsyncImage(url: URL(string: viewModel.photoSecondURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .overlay {
                                    if !viewModel.isFirst && !viewModel.isCompleted {
                                        Image("imgRetry")
                                            .onTapGesture {
                                                isShowCamera = true
                                            }
                                    }
                                }
                        case .failure:
                            Rectangle()
                                .fill(Color.offBlack)
                        case .empty:
                            Rectangle()
                                .fill(Color.lightGray)
                                .overlay {
                                    if !viewModel.isFirst {
                                        Image("imgDiptychCamera")
                                            .onTapGesture {
                                                isShowCamera = true
                                            }
                                    }
                                }
                        @unknown default:
                            ProgressView()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1.0, contentMode: .fit)
                .padding(.bottom, 23)

                HStack(spacing: 9) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        ForEach(0..<viewModel.weeklyData.count, id: \.self) { index in
                            WeeklyCalenderView(day: days[index],
                                               date: "\(mondayDate + index)",
                                               isToday: index == viewModel.weeklyData.count - 1 ? true : false,
                                               thumbnail: viewModel.weeklyData[index].thumbnail,
                                               diptychState: viewModel.weeklyData[index].diptychState)
                        }
                        ForEach(viewModel.weeklyData.count..<7, id: \.self) { index in
                            WeeklyCalenderView(day: days[index],
                                               date: "\(mondayDate + index)",
                                               isToday: false,
                                               diptychState: .incomplete)
                        }
                    }
                }
            }
        }
    }

    private func calculateThisWeekMondayDate() -> Int {
        let currentDate = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd 00:00:00"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")

        let todayDateString = formatter.string(from: currentDate)

        formatter.timeZone = TimeZone(identifier: "UTC") // 시간대 설정
        let todayDate = formatter.date(from: todayDateString)!

        let currentWeekday = calendar.component(.weekday, from: todayDate)
        let daysAfterMonday = (currentWeekday + 5) % 7

        guard let thisMonday = calendar.date(byAdding: .day, value: -daysAfterMonday, to: todayDate) else { return 0 }

        let day = calendar.component(.day, from: thisMonday)
        return day
    }
}

struct TodayDiptychView_Previews: PreviewProvider {
    static var previews: some View {
        TodayDiptychView()
    }
}
