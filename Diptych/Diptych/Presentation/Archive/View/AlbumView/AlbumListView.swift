//
//  AlbumListView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/13.
//

import SwiftUI

struct AlbumListView: View {
    
    ///Property
    @StateObject private var VM = ArchiveViewModel()
  
    var body: some View {
        ScrollView {
            
            let data = VM.photos
            let content = VM.questions
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()),count: 3),spacing: 7) {
                ForEach(0..<data.count, id: \.self) { index in
                    
                    let isSafe2 = !data.isEmpty && !content.isEmpty
                    
                    if !data.isEmpty && data[index].isCompleted {
                        /// 사진 디테일 뷰
                        NavigationLink {
                            PhotoDetailView(
                                date: !data.isEmpty ? data[index].date : Date(),
                                questionNum: isSafe2 ? content[index].order : 0,
                                question: isSafe2 ? content[index].question! : "",
                                isLoading: VM.isLoading ,
                                index: index ,
                                image1: !data.isEmpty ? data[index].photoFirstURL : "",
                                image2: !data.isEmpty ? data[index].photoSecondURL : "" )
                        } label: {
                            AlbumImageView(imageURL: data[index].thumbnail!)
                                .aspectRatio(1.0, contentMode: .fit)
                        }
                    }else {
                        EmptyView()
                    }
                }//】 Loop
            }//】 Grid
            
        }//】 Scroll
    }//】 Body
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
