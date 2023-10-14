//
//  PhotoDetailView.swift
//  Diptych
//
//  Created by Nyla on 2023/07/20.
//

import SwiftUI

enum PhotoIndexDirection {
    case previous, next

    var imageName: String {
        switch self {
        case .previous:
            return "chevron.left"
        case .next:
            return "chevron.right"
        }
    }
}

struct PhotoDetailView: View {

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

    var body: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea()
            VStack(spacing: 0) {
                diptychHeader
                    .padding(.horizontal, 15)
                Spacer()
                diptychQuestion
                    .padding(.leading, 15)
                Spacer()
                diptychPhoto
                Spacer()
                HStack(spacing: 80) {
                    shareBoxButton
                    likeButton
                    commentButton
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBackButton()
            }
        }
    }
}

// MARK: - UI Components

extension PhotoDetailView {

    private var diptychHeader: some View {
        VStack(spacing: 10) {
            HStack {
                Text("2023년 9월 9일")
                Spacer()
                Text("#999번째 딥틱")
            }
            Divider()
                .frame(height: 1)
                .overlay(Color.dtDarkGray)
        }
        .font(.pretendard(size: 16))
        .foregroundColor(.dtDarkGray)
    }

    private var diptychQuestion: some View {
        HStack {
            Text("“상대방의 표정 중 당신이\n가장 좋아하는 표정은?“")
                .font(.pretendard(.light, size: 24))
                .foregroundColor(.offBlack)
                .lineSpacing(6)
            Spacer()
        }
    }

    private var diptychPhoto: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.dtLightGray)
                .aspectRatio(contentMode: .fit)
            HStack {
                photoIndexButton(for: .previous)
                Spacer()
                photoIndexButton(for: .next)
            }
            .padding(.horizontal, 11)
        }
    }

    private var shareBoxButton: some View {
        Image("icnShareBox")
    }

    private var likeButton: some View {
        Image("imgWhiteHeart")
    }

    private var commentButton: some View {
        Image("icnComment")
    }

    private func photoIndexButton(for direction: PhotoIndexDirection) -> some View {
        ZStack{
            Circle()
                .frame(width: 28, height: 28)
                .foregroundColor(.offBlack.opacity(0.5))
            Image(systemName: direction.imageName)
                .foregroundColor(.white)
                .font(.headline)
                .fontWeight(.bold)
        }
        .onTapGesture {
            switch direction {
            case .previous:
                showPreviousDetail()
            case .next:
                showNextDetail()
            }
        }
    }

    // MARK: - Custom Methods

    func showPreviousDetail() {
        print("이전 photoDetail 불러오기")
        if currentIndex > 0 {
            self.currentIndex -= 1
        }
    }

    func showNextDetail() {
        print("다음 photoDetail 불러오기")
        if currentIndex < 19 {
            self.currentIndex += 1
        }
    }

    private func updateViewWithCurrentIndex() {
//        self.date = archiveViewModel.truePhotos[currentIndex].date
//        self.image1 = archiveViewModel.truePhotos[currentIndex].photoFirstURL
//        self.image2 = archiveViewModel.truePhotos[currentIndex].photoSecondURL
//        self.question = archiveViewModel.trueQuestions[currentIndex].question
    }
}

// MARK: - Component

extension PhotoDetailView {
    
    /// 이미지 불러오기
    func downloadImage() async {
        if let image1 {
            // TODO: - [Backend] 이미지 1
            imageUrl1 = URL(string: image1)
        }
        
        if let image2 {
            // TODO: - [Backend] 이미지 2
            imageUrl2 = URL(string: image2)
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
            
            // TODO: - [Mockup] 이미지
            image1Image = UIImage(named: "diptych_sample1")
            
            if let image1Image {
                ImageCacheManager.shared.saveImageToCache(image: image1Image, urlAbsoluteString: image1)
                print("[DEBUG] image1 saved to cache.")
            }
        }
        
        Task {
            if let cachedImageSecond = ImageCacheManager.shared.loadImageFromCache(urlAbsoluteString: image2) {
                image2Image = cachedImageSecond
                print("[DEBUG] mage2: loaded from cache")
                return
            }
            
            // TODO: - [Mockup] 이미지
            image2Image = UIImage(named: "diptych_sample1")
            
            if let image2Image {
                ImageCacheManager.shared.saveImageToCache(image: image2Image, urlAbsoluteString: image2)
                print("[DEBUG] image2 saved to cache.")
            }
        }
    }
}

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DiptychTabView()
    }
}
