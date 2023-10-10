//
//  AlbumListView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/13.
//

import SwiftUI

struct AlbumListView: View {

    @State var selection = LikeFilter.all
    var columns = Array(repeating: GridItem(spacing: 4), count: 3)

    var body: some View {
        ScrollView(.vertical) {
            LikeSegmentedControl(selection: $selection)
                .padding(.horizontal, 15)
                .padding(.top, 15)
            LazyVGrid(columns: columns, spacing: 4) {
                // TODO: - 개수 임의 지정
                ForEach((0..<20), id: \.self) { index in
                    NavigationLink {
                        PhotoDetailView(currentIndex: 0)
                    } label: {
                        albumList(for: selection)
                    }
                }
            }
        }
    }
}

extension AlbumListView {

    @ViewBuilder
    private func albumList(for filter: LikeFilter) -> some View {
        switch filter {
        case .all:
            AlbumImageView(imageURL: "")
        case .like:
            AlbumLikedImageView(imageURL: "")
        }
    }
}

struct AlbumImageView: View {
    
    @StateObject private var imageLoader: ImageLoader
    private let imageURL: String

    init(imageURL: String) {
        self.imageURL = imageURL
        _imageLoader = StateObject(wrappedValue: ImageLoader(imageURL: imageURL))
    }

    var body: some View {
        Rectangle()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.dtLightGray)
    }
}

struct AlbumLikedImageView: View {

    @StateObject private var imageLoader: ImageLoader
    private let imageURL: String

    init(imageURL: String) {
        self.imageURL = imageURL
        _imageLoader = StateObject(wrappedValue: ImageLoader(imageURL: imageURL))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.dtLightGray)

            // TODO: - 추후 모델이 완성되면 AlbumImageView - AlbumLikedImageView를 합쳐 isLiked로 구분하기
            Image("icnLikedHeart")
                .shadow(color: .black.opacity(0.25),
                        radius: 20)
                .padding(.trailing, 7)
                .padding(.bottom, 5)
        }
    }
}


struct AlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumListView()
    }
}
