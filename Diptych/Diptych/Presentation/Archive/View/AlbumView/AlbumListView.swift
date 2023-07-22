//
//  AlbumListView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/13.
//

import SwiftUI

struct AlbumListView: View {
    let MARGIN: CGFloat = 10
    @State private var columnCount = 3.0
    
    // 화면을 그리드형식으로 꽉채워줌
    var columns: [GridItem] {
        return (1...Int(columnCount)).map { _ in
            GridItem(.flexible(), spacing: MARGIN)
        }
    }
    
    // TODO: - 뷰모델
    
    var body: some View {
        ScrollView {
            Stepper("Column Count", value: $columnCount)
            LazyVGrid(columns: columns, spacing: MARGIN) {
                ForEach(1..<100) { element in
                    // TODO: - 실제 데이터 및 상세 보기 뷰로 교체
                    NavigationLink {
                        Text("Temp Detail Page: \(element)")
                    } label: {
                        VStack {
                            // Image("DummyThumbnail_\(element % 9 == 0 ? 9 : element % 9)")
                            Image("diptych_sample1")
                                .resizable() // 중요: 지정하지 않으면 이미지 사이즈 요지부동
                                .aspectRatio(1, contentMode: .fill)
                        }
                        // Rectangle()
                        //     .fill(.gray)
                        //     .aspectRatio(1, contentMode: .fit)
                        // Color.gray
                        //     .aspectRatio(1, contentMode: .fit)
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
