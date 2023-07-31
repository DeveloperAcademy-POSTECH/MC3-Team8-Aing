//
//  TodayDiptychView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI
import FirebaseStorage



struct TodayDiptychView: View {

    let thumbSize: CGSize = .init(width: THUMB_SIZE / 2.0, height: THUMB_SIZE)
    @State var isShowCamera = false
    @State private var firstUIImage: UIImage?
    @State private var secondUIImage: UIImage?
    @StateObject private var imageCacheViewModel = ImageCacheViewModel(firstImage: nil, secondImage: nil)
    @StateObject private var viewModel = TodayDiptychViewModel()
    @State private var isAllTasksCompleted = false
    let days = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        NavigationStack {
            MainDiptychView()
            .ignoresSafeArea(edges: .top)
            .onAppear {
                fetchData()
            }
            .onDisappear {
                viewModel.weeklyData.removeAll()
            }
            .fullScreenCover(isPresented: $isShowCamera) {
                ZStack {
                    Color.offWhite.ignoresSafeArea()
                    CameraRepresentableView(viewModel: viewModel, imageCacheViewModel: imageCacheViewModel)
                         .toolbar(.hidden, for: .tabBar)
                         .onDisappear {
                             viewModel.weeklyData.removeAll()
                             Task {
                                 await viewModel.fetchTodayImage()
                                 await viewModel.fetchWeeklyCalender()
                             }
                         }
                }
            }
        }
    }

    // MARK: - UI Components

    private func MainDiptychView() -> some View {
        ZStack {
            Color.offWhite
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("\(viewModel.setTodayDate()) 오늘의 주제")
                    Spacer()
                    Text("#999번째 딥틱") // TODO: - 완료 딥틱 개수 세기
                }
                .font(.pretendard(.medium, size: 16))
                .foregroundColor(.darkGray)
                .padding(.horizontal, 15)
                .padding(.top, 31)

                Rectangle()
                    .frame(height: 1)
                    .background(Color.darkGray)
                    .padding(.top, 10)
                    .padding(.horizontal, 15)

                HStack(spacing: 0) {
                    Text("오늘 발견한 동그라미는?")
//                    Text("\"\(viewModel.question)\"")
                        .frame(height: 75, alignment: .topLeading)
                        .lineSpacing(6)
                        .font(.pretendard(.light, size: 28))
                        .foregroundColor(.offBlack)
                        .padding(.top, 29)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 15)
                    Spacer()
                }

                //MARK: - 사진
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
                                }.onAppear {
                                    imageCacheViewModel.firstImage = image.getUIImage(newSize: thumbSize)
                                }
                        case .failure:
                            Rectangle()
                                .fill(Color.offWhite)
                        case .empty:
                            Rectangle()
                                .fill(viewModel.isFirst ? Color.lightGray : Color.offBlack)
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
                                .onAppear {
                                    imageCacheViewModel.secondImage = image.getUIImage(newSize: thumbSize)
                                }
                        case .failure:
                            Rectangle()
                                .fill(Color.offBlack)
                        case .empty:
                            Rectangle()
                                .fill(viewModel.isFirst ? Color.offBlack : Color.lightGray)
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
                .padding(.bottom, 15)

                //MARK: - Weekly 캘린더
                HStack(spacing: 9) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        let weeklyDates = viewModel.setWeeklyDates()
                        
                        ForEach(0..<7) { index in
                            let date = weeklyDates[index]
                            let data = viewModel.weeklyData.filter { $0.date == date }
                            let formattedDate = String(format: "%02d", date)
                            let isToday = date == viewModel.setTodayDate()
                            let diptychState = data.isEmpty ? .incomplete : data[0].diptychState
                            let weeklyCalenderView = WeeklyCalenderView(day: days[index],
                                                                        date: formattedDate,
                                                                        isToday: isToday,
                                                                        thumbnail: data.isEmpty ? "" : data[0].thumbnail,
                                                                        diptychState: data.isEmpty ? .incomplete : data[0].diptychState)

                            switch diptychState {
                            case .complete:
                                        weeklyCalenderView
                            default:
                                weeklyCalenderView
                            }
                        }
                    }
                }//】 HStack
                .padding(.bottom,30)
                
                
            }//】 VStack
        }
    }

    // MARK: - Custom Methods

    private func fetchData() {
        Task {
            await viewModel.fetchUser()
            await viewModel.setTodayPhoto()
            await viewModel.setUserCameraLoactionState()
            await viewModel.fetchTodayImage()
            await viewModel.fetchWeeklyCalender()
            await viewModel.fetchContents()
        }
    }
}

struct TodayDiptychView_Previews: PreviewProvider {
    static var previews: some View {
        TodayDiptychView()
    }
}
