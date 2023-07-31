//
//  PhotoDetailView.swift
//  Diptych
//
//  Created by Nyla on 2023/07/20.
//

import SwiftUI
import FirebaseStorage

// MARK: - Property

struct PhotoDetailView {
    
    @ObservedObject var VM : ArchiveViewModel
    @State var date: Date = Date()
    @State var image1: String?
    @State var image2: String?
    @State var imageUrl1: URL?
    @State var imageUrl2: URL?
    @State var question: String?
    @State var currentIndex: Int
    @State private var isImageLoaded = false
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }()
    
    
    private let transaction: Transaction = .init(animation: .linear)
    @State var isFirstLoaded: Bool = false
    @State var isSecondLoaded: Bool = false
}

// MARK: - View

extension PhotoDetailView: View {
    var body: some View {
        ZStack {
            Color.offWhite.edgesIgnoringSafeArea(.top)

            VStack(spacing: 0) {
                
                /// [1] 해더
                VStack(spacing: 0){
                    HStack(spacing: 8) {
                        Text(dateFormatter.string(from: date))
                        Spacer()
                        Text("#\(currentIndex + 1)번째 딥틱")
                    }//: HStack
                    .font(.custom(PretendardType.medium.rawValue, size: 16))
                    .padding(.bottom,10)
                    
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 1)
                }
                .foregroundColor(Color.darkGray)
                .padding(.top,32)
                .padding(.horizontal,13)
                
                
                    /// [2] 질문
                VStack(spacing: 0){
                    HStack(spacing: 0){
                        Text("\(question ?? "")")
                            .font(.custom(PretendardType.light.rawValue, size: 24))
                            .foregroundColor(.offBlack)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 17)
                        Spacer()
                    }//】 HStack
                    .padding(.top,23)
                    Spacer()
                }//】 VStack
                    .frame(height: 120)
                    
                
                    
                    /// [3] 사진 프레임
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 0)
                            .foregroundColor(Color.darkGray)
                        //                        .stroke(Color.lightGray, lineWidth: 1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        HStack(spacing: 0) {
                            
                            AsyncImage(url: imageUrl1) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 196.5, height: 393)
                                        .onAppear {
                                            print("image1 appeared:", Date().timeIntervalSince1970)
                                            isFirstLoaded = true
                                            print("all loaded?", isFirstLoaded && isSecondLoaded)
                                        }
                                        .opacity(isFirstLoaded && isSecondLoaded ? 1 : 0)
                                    // Text("loaded")
                                    
                                case .failure(_):
                                    Text("error")
                                case .empty:
                                    // placeholder
                                    ProgressView()
                                @unknown default:
                                    Text("unknown")
                                }
                            }.onAppear {
                                print("onAppear: \(Date().timeIntervalSince1970)")
                            }.onChange(of: isFirstLoaded) { newValue in
                                print("isFirstLoaded changed:", isFirstLoaded)
                            }
                            
                            AsyncImage(url: imageUrl2) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 196.5, height: 393)
                                        .onAppear {
                                            print("image2 appeared:", Date().timeIntervalSince1970)
                                            isSecondLoaded = true
                                            print("all loaded?", isFirstLoaded && isSecondLoaded)
                                        }
                                        .opacity(isFirstLoaded && isSecondLoaded ? 1 : 0)
                                    // Text("loaded")
                                    
                                case .failure(_):
                                    Text("error")
                                case .empty:
                                    // placeholder
                                    ProgressView()
                                @unknown default:
                                    Text("unknown")
                                }
                            }.onAppear {
                                print("onAppear: \(Date().timeIntervalSince1970)")
                            }
                            ///왼쪽 사진
                            // AsyncImage(url: imageUrl1) { image in
                            //
                            //     image
                            //         .resizable()
                            //         .frame(width: 196.5, height: 393)
                            // } placeholder: {
                            //     ProgressView()
                            // }
                            // .frame(width: 196.5)
                            
                            
                            /// 오른쪽 사진
                            // AsyncImage(url: imageUrl2) { image in
                            //     image
                            //         .resizable()
                            //         .frame(width: 196.5, height: 393)
                            // } placeholder: {
                            //     ProgressView()
                            // }
                            // .frame(width: 196.5)
                        }//】 HStack
                        
                        HStack(spacing: 0){
                            if currentIndex > 0 {previousButton} else {EmptyView()} /// 이전 버튼
                            Spacer()
                            if currentIndex < VM.truePhotos.count - 1{nextButton} else {EmptyView()} /// 다음 버튼
                            
                        }
                        .padding(.horizontal,18)
                        
                    
                        
                }//】 ZStack
                    .frame(height: 393, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .transition(.move(edge: .leading)) // 슬라이드 애니메이션을 적용합니다.
                    // .opacity(isFirstLoaded && isSecondLoaded ? 1 : 0)
                
                /// [4]버튼
                HStack(spacing: 0){
                    ShareSheetView()
                        .foregroundColor(.offBlack)
                        .frame(width: 30, height: 30)
                        .padding(.leading, 70)
                    Image("whiteHeart")
                        .foregroundColor(.offBlack)
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, 80)
                    Image("comment")
                        .foregroundColor(.offBlack)
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 70)
                }//】 HStack
                .frame(height: 100)
                .padding(.bottom,100)
            } // VStack
            
        } // ZStack
        .onAppear {
            Task {
                await downloadImage()
            }
        }
    }//】 Body
    
    
}

// MARK: - 버튼 디자인
struct indexButton: View {
    let icon : String
    var body: some View {
        ZStack{
            Circle()
                .frame(width: 28, height: 28)
                .foregroundColor(.offBlack.opacity(0.5))
            
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.headline)
                .fontWeight(.bold)
        }
    }
}

// MARK: - Component
extension PhotoDetailView {
    /// 이전 버튼
    private var previousButton: some View {
        return Button {
            Task {
                showPrevDetail()
                await downloadImage()
            }
        } label: {
            indexButton(icon: "chevron.left")
        }//】 Button
        .onTapGesture { withAnimation(.easeInOut) {showPrevDetail()} }
    }// 이전 버튼
    
    /// 다음 버튼
    private var nextButton: some View {
        return Button {
            Task {
                showNextDetail()
                await downloadImage()
            }
        } label: {
            indexButton(icon: "chevron.right")
        }//】 Button
        .onTapGesture { withAnimation(.easeInOut) {showNextDetail()} }
    }// 다음 버튼
    
    
    /// 이전 버튼 로직
    func showPrevDetail() {
            if currentIndex > 0{
                self.currentIndex -= 1
                updateViewWithCurrentIndex()
            }
    }
    
    /// 다음 버튼 로직
    func showNextDetail() {
            if currentIndex < VM.truePhotos.count - 1{
                self.currentIndex += 1
                updateViewWithCurrentIndex()
            }
    }
    
    /// 사진 상세뷰 업데이트
        private func updateViewWithCurrentIndex() {
            self.date = VM.truePhotos[currentIndex].date
            self.image1 = VM.truePhotos[currentIndex].photoFirstURL
            self.image2 = VM.truePhotos[currentIndex].photoSecondURL
            self.question = VM.trueQuestions[currentIndex].question
            
            // isFirstLoaded = false
            // isSecondLoaded = false
        }
    
    /// 이미지 불러오기
    func downloadImage() async {
        if let image1 = image1 {
            do {
                let url = try await Storage.storage().reference(forURL: image1).downloadURL()
                imageUrl1 = url
            } catch { print(error.localizedDescription)}
        }
        
        if let image2 = image2, !image2.isEmpty {
            do {
                let url = try await Storage.storage().reference(forURL: image2).downloadURL()
                imageUrl2 = url
            } catch { print(error.localizedDescription)}
        }
    }
    
    
    func textLabel(text: String) -> some View {
        return Text(text)
            .font(.custom(PretendardType.medium.rawValue, size: 16))
            .foregroundColor(.offBlack)
            .padding(.vertical, 7)
            .padding(.horizontal, 8)
            .background(Rectangle()
                        .fill(Color.lightGray)
            )
    }
}

