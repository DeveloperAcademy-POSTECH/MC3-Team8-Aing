//
//  AlbumListView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/13.
//

import SwiftUI

struct AlbumListView: View {
    
    ///Property
    @EnvironmentObject var VM : ArchiveViewModel
    var scrollToID : Int = 18 // 스크롤뷰 시작 위치 지정
  
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                
                let data = VM.photos
                let data2 = VM.questions
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()),count: 3),spacing: 4) {
                    ForEach((0..<VM.photos.count), id: \.self) { index in
                        
                        /// 사진 디테일 뷰
                        NavigationLink {
                            PhotoDetailView(
                                date: data[index].date,
                                image1: data[index].photoFirstURL,
                                image2: data[index].photoSecondURL,
                                question: (data2[index].question),
                                currentIndex: index
                            )
                            .environmentObject(VM)
                        } label: {
                            AlbumImageView(imageURL: data[index].thumbnail!)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                        .navigationTitle("")
                    }//】 Loop
                }//】 Grid
                
            }//】 Scroll
            .background(Color.offWhite)
            .onChange(of: scrollToID) { newValue in
                scrollViewProxy.scrollTo(newValue, anchor: .bottom)
            }
        }//】 ScrollViewReader
    }//】 Body
    private func indexOfCompleted(_ index: Int) -> Int {
        guard let completedPhoto = VM.photos[index].thumbnail else { return 0 }
        return VM.truePhotos.firstIndex { $0.thumbnail == completedPhoto } ?? 0
    }
}

//MARK: - 사진 뷰
struct AlbumImageView: View {
    @StateObject private var imageLoader: ImageLoader
    private let imageURL: String

    init(imageURL: String) {
        self.imageURL = imageURL
        _imageLoader = StateObject(wrappedValue: ImageLoader(imageURL: imageURL))
    }

    var body: some View {
        VStack{
            // TODO: - [Mockup] 섬네일
            Image(uiImage: .init(named: "diptych_sample1")!)
                .resizable()
                .scaledToFill()
                .frame(width: 128, height: 128)
                .clipped()
            
            // if let image = imageLoader.image {
            //     Image(uiImage: image)
            //         .resizable()
            //         .scaledToFill()
            //         .frame(width: 128, height: 128)
            //         .clipped()
            // } else {
            //     ProgressView()
            // }
        }//】 VStack
        .frame(width: 128, height: 128)
//        .frame(maxWidth: .infinity)
    }//】 Body
}


//MARK: - Preview
struct AlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumListView()
    }
}
