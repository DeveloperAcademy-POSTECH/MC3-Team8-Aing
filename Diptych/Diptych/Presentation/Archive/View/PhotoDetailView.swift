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
    
    @EnvironmentObject var VM : ArchiveViewModel
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
    
    @State var image1Image: UIImage?
    @State var image2Image: UIImage?
}

// MARK: - View

extension PhotoDetailView: View {
    var body: some View {
        ZStack {
            Color.offWhite.edgesIgnoringSafeArea(.top)

            VStack(spacing: 0) {
                
                //MARK: - [1] 해더
                VStack(spacing: 0){
                    HStack(spacing: 0) {
                        Text(dateFormatter.string(from: date))
                        Spacer()
                        
                        Text("\(currentIndex + 1)")
                            .italic()
                            .font(.custom(PretendardType.medium.rawValue, size: 16))
//                            .foregroundColor(.systemSalmon)
                        Text("번째 딥틱")
                    }//: HStack
                    .padding(.bottom,10)
                    
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 1)
                }//】 VStack
                .font(.custom(PretendardType.medium.rawValue, size: 16))
                .foregroundColor(Color.darkGray)
                .padding(.top,32)
                .padding(.horizontal,13)
                
                
                    //MARK: - [2] 질문
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
                            // .stroke(Color.lightGray, lineWidth: 1)
                            // .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(width: 393, height: 393)
                        
                        HStack(spacing: 0) {
                            if let image1Image, let image2Image {
                                HStack(spacing: 0) {
                                    Image(uiImage: image1Image)
                                        .resizable()
                                        .frame(width: 196.5, height: 393)
                                    Image(uiImage: image2Image)
                                        .resizable()
                                        .frame(width: 196.5, height: 393)
                                }
                                // .transition(isShouldShowPrevOrNext ? .slide : .identity)
                                // .transition(.opacity)
                                // .animation(.linear)
                            }
                            else {
                                ProgressView()
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
                        
//                        ImageCell(imageUrl1: imageUrl1, imageUrl2: imageUrl2)
//                            .environmentObject(VM)
//                            .frame(maxWidth: .infinity)
                        
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
                
                //MARK: - [4] 공유/ 좋아요 버튼
                HStack(spacing: 0){
                    ShareSheetView()
//                    Image("imgShareBox")
                        .foregroundColor(.offBlack)
                        .frame(width: 30, height: 30)
                        .padding(.leading, 70)
                    Image("imgWhiteHeart")
                        .foregroundColor(.offBlack)
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, 80)
                    Image("imgComment")
                        .foregroundColor(.offBlack)
                        .frame(width: 30, height: 30)
                        .padding(.trailing, 70)
                }//】 HStack
                .frame(height: 100)
                .padding(.bottom,100)
                
            } // VStack
            
        } // ZStack
        .onAppear {
            // Task {
            //     await downloadImage()
            // }
            downloadImageWithCache()
        }
    }//】 Body
}

// MARK: - 이미지 셀
//struct ImageCell: View {
//
//    @StateObject private var imageLoader: ImageLoader
//    @EnvironmentObject var VM : ArchiveViewModel
//    private let image1: String
//    private let image2: String
//
//
//    init(imageURL: String) {
//        self.image1 = imageURL
//        _imageLoader = StateObject(wrappedValue: ImageLoader(imageURL: imageURL))
//        self.image2 = imageURL
//        _imageLoader = StateObject(wrappedValue: ImageLoader(imageURL: imageURL))
//    }
//
//    var body: some View {
//
//        if let image = imageLoader.image {
//            Image(uiImage: image)
//                .resizable()
//                .scaledToFill()
//                .clipped()
//        } else {
//            ProgressView()
//        }
//
//        TabView(){
//            ForEach((0..<VM.truePhotos.count), id: \.self) { index in
//
//                let data = VM.truePhotos
//
//
//            }//】 Loop
//        }//TabView
//        .frame(maxWidth: .infinity)
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//        .animation(.easeInOut)
//    }//】 Body
//
//}


// MARK: - 버튼 디자인
struct IndexButton: View {
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
                // await downloadImage()
                downloadImageWithCache()
            }
        } label: {
            IndexButton(icon: "chevron.left")
        }//】 Button
        .onTapGesture { withAnimation(.easeInOut) {showPrevDetail()} }
    }// 이전 버튼
    
    /// 다음 버튼
    private var nextButton: some View {
        return Button {
            Task {
                showNextDetail()
                // await downloadImage()
                downloadImageWithCache()
            }
        } label: {
            IndexButton(icon: "chevron.right")
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
        }
    
    /// 이미지 불러오기
    func downloadImage() async {
        if let image1 = image1 {
            do {
                let url = try await Storage.storage().reference(forURL: image1).downloadURL()
                imageUrl1 = url
            } catch { print(error.localizedDescription)}
        }
        
        if let image2 = image2 {
            do {
                let url = try await Storage.storage().reference(forURL: image2).downloadURL()
                imageUrl2 = url
            } catch { print(error.localizedDescription)}
        }
    }
    
    /// 이미지 불러오기 (메모리 캐싱)
    func downloadImageWithCache() {
        guard let image1, let image2 else {
            return
        }
        
        image1Image = nil
        image2Image = nil
        
        Task {
            if let cachedImageFirst = ImageCacheManager.shared.loadImageFromCache(urlAbsoluteString: image1) {
                image1Image = cachedImageFirst
                print("[DEBUG] image1: loaded from cache")
                return
            }
            
            image1Image = UIImage(data: try await FirebaseManager.shared.downloadImageDataFromFirebaseImageURL(urlAbsoluteString: image1))
            
            if let image1Image {
                ImageCacheManager.shared.saveImageToCache(image: image1Image, urlAbsoluteString: image1)
                print("[DEBUG] image1 saved to cache.")
            }
        }
        
        Task {
            if let cachedImageSecond = ImageCacheManager.shared.loadImageFromCache(urlAbsoluteString: image2) {
                image2Image = cachedImageSecond
                print("i[DEBUG] mage2: loaded from cache")
                return
            }
            
            image2Image = UIImage(data: try await FirebaseManager.shared.downloadImageDataFromFirebaseImageURL(urlAbsoluteString: image2))
            
            if let image2Image {
                ImageCacheManager.shared.saveImageToCache(image: image2Image, urlAbsoluteString: image2)
                print("[DEBUG] image2 saved to cache.")
            }
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
