//
//  CommentViewModel.swift
//  Diptych
//
//  Created by 윤범태 on 2023/10/12.
//

import Foundation

final class CommentViewModel: ObservableObject {
    @Published var comments: [DiptychPhotoComment] = []
    
    init() {
        let text1 = "이번 사진 진짜 너무 웃기다하항\n정말 웃기지 않니 하하ㅏ"
        let text2 = "그러게 말이야 정말 웃기다 너 표정이 왜그러니"
        
        comments = (0..<20).map { index in
                .init(
                    id: "\(index + 1)",
                    authorID: index % 2 == 0 ? "쏜야" : "밍니",
                    comment: index % 2 == 0 ? text1 : text2,
                    createdDate: Date(),
                    modifiedDate: Date()
                )
        }
    }
    
    func addComment(_ text: String) {
        comments.append(.init(id: "\(comments.count + 1)",
                              authorID: "루후",
                              comment: text,
                              createdDate: Date(),
                              modifiedDate: Date())
        )
    }
}
