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
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: nil),
    ]
    
    // TODO: - 뷰모델
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(1..<100) { element in
                    // TODO: - 실제 데이터 및 상세 보기 뷰로 교체
                    NavigationLink {
//                        Text("Temp Detail Page: \(element)")
                        PhotoDetailView(
                            date: "2023년 7월 30일",
                            questionNum: 20,
                            question: "\"상대방의 표정 중 당신이\n 가장 좋아하는 표정은?\"",
                            imageUrl1: "https://file.notion.so/f/s/1ed8775d-60cc-4907-b8f2-edf0acfb484f/%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9_3_copy_5_%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB_2.jpg?id=8dc957fa-bf1e-4daf-a72a-6be8e69213d6&table=block&spaceId=794074b4-a62e-40a9-9a73-2dc5a7035226&expirationTimestamp=1689933600000&signature=-ZApnHNSBN05IfP5KQJWDd_MUXwXBrAUPvTwjjdI-40&downloadName=%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9+3+copy+5+%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB+2.jpg",
                            imageUrl2: "https://file.notion.so/f/s/19b32819-43e4-446d-bcb8-917b17cfe2cd/%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9_3_copy_5_%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB.jpg?id=7fddf6e5-976e-4ed6-af14-be1ff9662108&table=block&spaceId=794074b4-a62e-40a9-9a73-2dc5a7035226&expirationTimestamp=1689933600000&signature=QECxg7nvN5ew0ajmMq5oCJmCV0SqyR7e7n8SwOAI804&downloadName=%E1%84%89%E1%85%A6%E1%84%85%E1%85%A9+3+copy+5+%E1%84%87%E1%85%A9%E1%86%A8%E1%84%89%E1%85%A1%E1%84%87%E1%85%A9%E1%86%AB.jpg"
                            )
                        
                    } label: {
                        
                        Image("DummyThumbnail_5")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                        
//                        Image("DummyThumbnail_\(element % 9 == 0 ? 9 : element % 9)")
//                            .aspectRatio(1, contentMode: .fit)
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
