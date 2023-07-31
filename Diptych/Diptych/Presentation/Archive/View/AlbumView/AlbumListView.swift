//
//  AlbumListView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/13.
//

import SwiftUI

struct AlbumListView: View {
    
    ///Property
    @StateObject var VM : ArchiveViewModel = ArchiveViewModel()
  
    var body: some View {
        ScrollView {
            
            let data = VM.truePhotos
            let data2 = VM.trueQuestions
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()),count: 3),spacing: 7) {
                ForEach(0..<VM.truePhotos.count, id: \.self) { index in
                    
                        /// 사진 디테일 뷰
                        NavigationLink {
                            PhotoDetailView(
                                VM: VM,
                                date: data[index].date,
                                image1: data[index].photoFirstURL,
                                image2: data[index].photoSecondURL,
                                question: data2[index].question,
                                currentIndex: index
                            )
                        } label: {
                            AlbumImageView(imageURL: data[index].thumbnail!)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                        .navigationTitle("")
                }//】 Loop
            }//】 Grid
            
        }//】 Scroll
        .background(Color.gray.opacity(0.1))
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
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 126, height: 126)
                    .clipped()
            } else {
                ProgressView()
            }
        }//】 VStack
        .frame(width: 126, height: 126)
    }//】 Body
}


//MARK: - Preview
struct AlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumListView()
    }
}
