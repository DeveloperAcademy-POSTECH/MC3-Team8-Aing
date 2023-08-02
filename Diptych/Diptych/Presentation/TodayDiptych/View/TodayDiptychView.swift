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
    @EnvironmentObject var diptychCompleteAlertObject: DiptychCompleteAlertObject
    let days = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        NavigationStack {
            MainDiptychView()
                .ignoresSafeArea(edges: .vertical)
                .onAppear {
                    diptychCompleteAlertObject.checkDateAndResetAlertIfNeeded()
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

                                    guard let isCompleted = viewModel.todayPhoto?.isCompleted else { return }
                                    diptychCompleteAlertObject.isDiptychCompleted = isCompleted
                                }
                            }
                    }
                }
        }
    }

    private func fetchData() {
        Task {
            await viewModel.fetchUser()
            await viewModel.setUserCameraLoactionState()
            await viewModel.setDiptychNumber()
            await viewModel.fetchContents()
            await viewModel.setTodayPhoto()
            await viewModel.fetchTodayImage()
            await viewModel.fetchWeeklyCalender()

            guard let isCompleted = viewModel.todayPhoto?.isCompleted else { return }
            diptychCompleteAlertObject.isDiptychCompleted = isCompleted
        }
    }
}

// MARK: - UI Components

extension TodayDiptychView {

    private func MainDiptychView() -> some View {
        ZStack(alignment: .top) {
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
                .padding(.top, 75)

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
                        .padding(.bottom, 42)
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
                .padding(.bottom, 28)
                .font(.pretendard(.light, size: 14))
                .foregroundColor(.offWhite)
                .multilineTextAlignment(.center)

                HStack(spacing: 9) {
                    let weeklyDates = viewModel.setWeeklyDates()
                    ForEach(0..<7) { index in
                        let date = weeklyDates[index]
                        let data = viewModel.weeklyData.filter { $0.date == date }
                        WeeklyCalenderView(day: days[index],
                                           diptychState: data.isEmpty ? .none : data[0].diptychState)
                    }
                }
                .padding(.bottom, 28)
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
            rectangleOverlayImage(color: Color.lightGray, url: url, isBlurred: false)
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
                rectangleOverlayImage(color: Color.offBlack, url: url, isBlurred: true)
                Color.black
                    .opacity(0.54)
                VStack(spacing: 17) {
                    Image("icnCheck")
                    Text("상대방이 오늘 딥틱을\n완성했어요")
                }
            }
        case .complete:
            rectangleOverlayImage(color: Color.offBlack, url: url, isBlurred: false)
        }
    }

    private func rectangleOverlayImage(color: Color, url: String, isBlurred: Bool) -> some View {
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
                        .blur(radius: isBlurred ? 7 : 0, opaque: true)
                        .clipped()
                } placeholder: {
                    ProgressView()
                }
            }
    }
}

struct TodayDiptychView_Previews: PreviewProvider {
    static var previews: some View {
        TodayDiptychView()
            .environmentObject(DiptychCompleteAlertObject())
    }
}
