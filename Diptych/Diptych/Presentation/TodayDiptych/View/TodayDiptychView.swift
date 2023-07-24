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
            mondayDate = viewModel.calculateThisWeekMondayDate()

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
            CameraRepresentableView(viewModel: viewModel)
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
                        ForEach(0..<7) { index in
                            let date = setCalendarDate(mondayDate, index: index)
                            let data = viewModel.weeklyData.filter { $0.date == date }
                            let formattedDate = String(format: "%02d", date)
                            let isToday = date == viewModel.setTodayDate()
                            WeeklyCalenderView(day: days[index],
                                               date: formattedDate,
                                               isToday: isToday,
                                               thumbnail: data.isEmpty ? "" : data[0].thumbnail,
                                               diptychState: data.isEmpty ? .incomplete : data[0].diptychState)
                        }
                    }
                }
            }
        }
    }
}

extension TodayDiptychView {

    func setCalendarDate(_ mondayDate: Int, index: Int) -> Int {
        var date: Int
        switch mondayDate {
        case 30:
            date = index > 0 ? mondayDate + index - 30 : mondayDate + index
        case 31:
            date = index > 0 ? mondayDate + index - 31 : mondayDate + index
        default:
            date = mondayDate + index
        }
        return date
    }
}

struct TodayDiptychView_Previews: PreviewProvider {
    static var previews: some View {
        TodayDiptychView()
    }
}
