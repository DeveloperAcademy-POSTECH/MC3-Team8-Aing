//
//  CommentView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/10/12.
//

import SwiftUI

struct CommentView: View {
    @State var comments: [DiptychPhotoComment] = [
        .init(id: "1", authorID: "쏜야", comment: "이번 사진 진짜 너무 웃기다하항\n정말 웃기지 않니 하하ㅏ", createdDate: Date(), modifiedDate: Date()),
        .init(id: "2", authorID: "밍니", comment: "그러게 말이야 정말 웃기다 너 표정이 왜그러니", createdDate: Date(), modifiedDate: Date()),
    ]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.offWhite.ignoresSafeArea()
            VStack {
                ForEach(comments, id: \.id) { comment in
                    CommentCell(nickname: comment.authorID, comment: comment.comment, date: comment.createdDate)
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 58)
        }
    }
}

// #Preview {
//     CommentView()
// }

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView()
    }
}
