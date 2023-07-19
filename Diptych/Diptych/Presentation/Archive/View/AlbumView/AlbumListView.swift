//
//  AlbumListView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/13.
//

import SwiftUI

struct AlbumListView: View {
    
    // 화면을 그리드형식으로 꽉채워줌
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
    ]
    
    // TODO: - 뷰모델
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(1..<100) { element in
                    // TODO: - 실제 데이터 및 상세 보기 뷰로 교체
                    NavigationLink {
                        Text("Temp Detail Page: \(element)")
                    } label: {
                        Image("DummyThumbnail_\(element % 9 == 0 ? 9 : element % 9)")
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }
}

struct AlbumListView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumListView()
    }
}
