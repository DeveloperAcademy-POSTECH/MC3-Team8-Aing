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
    @State private var isDiptychCompleted = false
    @State private var isDiptychCompleteAlertShown = false
    @StateObject private var imageCacheViewModel = ImageCacheViewModel(firstImage: nil, secondImage: nil)
    @StateObject private var viewModel = TodayDiptychViewModel()
    let days = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        NavigationStack {
            ZStack {
                MainDiptychView()
                if isDiptychCompleted && !isDiptychCompleteAlertShown {
                    Color.black.opacity(0.54)
                    DiptychCompleteAlertView(isDiptychCompleteAlertShown: $isDiptychCompleteAlertShown)
                        .frame(width: 300, height: 360)
                }
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                fetchData()
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

    // MARK: - Custom Methods

    private func fetchData() {
        Task {
            await viewModel.fetchUser()
            await viewModel.setTodayPhoto()
            await viewModel.setUserCameraLoactionState()
            await viewModel.fetchTodayImage()
            await viewModel.setDiptychNumber()
            await viewModel.fetchWeeklyCalender()
            await viewModel.fetchContents()

            guard let isCompleted = viewModel.todayPhoto?.isCompleted else { return }
            isDiptychCompleted = isCompleted
        }
    }
}

// MARK: - UI Components

extension TodayDiptychView {

    private func MainDiptychView() -> some View {
        ZStack {
            Color.offWhite
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("\(viewModel.setTodayDate())")
                    Spacer()
                    Text("#\(viewModel.diptychNumber)번째 딥틱")
                }
                .font(.pretendard(.medium, size: 16))
                .foregroundColor(.darkGray)
                .padding(.horizontal, 15)
                .padding(.top, 31)

                Divider()
                    .frame(height: 1)
                    .overlay(Color.darkGray)
                    .padding(.top, 10)
                    .padding(.horizontal, 15)

                HStack(spacing: 0) {
                    Text("\(viewModel.question)")
                        .frame(height: 78, alignment: .topLeading)
                        .lineSpacing(6)
                        .font(.pretendard(.light, size: 28))
                        .foregroundColor(.offBlack)
                        .padding(.top, 29)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 15)
                    Spacer()
                }

                HStack(spacing: 0) {
                    switch viewModel.isFirst {
                    case true:
                        myDiptychImageView(viewModel.photoFirstState, viewModel.photoFirstURL)
                        loverDiptychImageView(viewModel.photoSecondState, viewModel.photoSecondURL)
                    case false:
                        loverDiptychImageView(viewModel.photoFirstState, viewModel.photoFirstURL)
                        myDiptychImageView(viewModel.photoSecondState, viewModel.photoSecondURL)
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1.0, contentMode: .fit)
                .padding(.bottom, 20)
                .font(.pretendard(.light, size: 14))
                .foregroundColor(.offWhite)
                .multilineTextAlignment(.center)

                HStack(spacing: 9) {
                    ForEach(0..<7) { index in
                        WeeklyCalenderView(day: days[index],
                                           diptychState: index <= viewModel.weeklyData.count - 1
                                           ? viewModel.weeklyData[index] : .none)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }

    @ViewBuilder
    private func myDiptychImageView(_ todayDiptychState: TodayDiptychState, _ url: String) -> some View {
        switch todayDiptychState {
        case .incomplete:
            Rectangle()
                .fill(Color.lightGray)
                .overlay {
                    Image("imgDiptychCamera")
                        .onTapGesture {
                            isShowCamera = true
                        }
                }
        default:
            rectangleOverlayImage(Color.lightGray, url)
        }
    }

    @ViewBuilder
    private func loverDiptychImageView(_ todayDiptychState: TodayDiptychState, _ url: String) -> some View {
        switch todayDiptychState {
        case .incomplete:
            Rectangle()
                .fill(Color.offBlack)
                .overlay {
                    VStack(spacing: 13) {
                        Image("icnCross")
                        Text("상대방이 오늘 딥틱을\n아직 완성하지 않았어요")
                    }
                }
        case .upload:
            ZStack {
                rectangleOverlayImage(Color.offBlack, url)
                Color.black
                    .opacity(0.54)
                    .background(VisualEffectView(effect: UIBlurEffect(style: .regular)))
                VStack(spacing: 17) {
                    Image("icnCheck")
                    Text("상대방이 오늘 딥틱을\n완성했어요")
                }
            }
        case .complete:
            rectangleOverlayImage(Color.offBlack, url)
        }
    }

    private func rectangleOverlayImage(_ color: Color, _ url: String) -> some View {
        Rectangle()
            .fill(color)
            .overlay {
                AsyncImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .onAppear {
                            if url == viewModel.photoFirstURL {
                                imageCacheViewModel.firstImage = image.getUIImage(newSize: thumbSize)
                            } else {
                                imageCacheViewModel.secondImage = image.getUIImage(newSize: thumbSize)
                            }
                        }
                } placeholder: {
                    ProgressView()
                }
            }
    }
}

struct TodayDiptychView_Previews: PreviewProvider {
    static var previews: some View {
        TodayDiptychView()
    }
}
