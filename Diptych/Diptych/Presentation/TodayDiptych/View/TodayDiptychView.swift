//
//  TodayDiptychView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI
import FirebaseStorage

struct TodayDiptychView: View {

    // TODO: - 섬네일 사이즈 ? (일단 200 * 200), 가로세로 여부도 고려..
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

            }
            .onDisappear {
                viewModel.weeklyData.removeAll()
            }
            .fullScreenCover(isPresented: $isShowCamera) {
                CameraRepresentableView(viewModel: viewModel, imageCacheViewModel: imageCacheViewModel)
                     .toolbar(.hidden, for: .tabBar)
                     .onAppear {
                         print("fullScreenCover")
                     }

            }
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
                        .frame(height: 78, alignment: .topLeading)
                        .lineSpacing(6)
                        .font(.pretendard(.light, size: 28))
                        .foregroundColor(.offBlack)
                        .padding(.top, 12)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 35)
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
                .padding(.bottom, 20)

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
                                NavigationLink {
                                    PhotoDetailView(date: "더미더미더미",
                                                    questionNum: 3,
                                                    question: "더미더미더미더미더미더미",
                                                    imageUrl1: "",
                                                    imageUrl2: "")
                                } label: {
                                        weeklyCalenderView
                                }
                            default:
                                weeklyCalenderView
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TodayDiptychView_Previews: PreviewProvider {
    static var previews: some View {
        TodayDiptychView()
    }
}
