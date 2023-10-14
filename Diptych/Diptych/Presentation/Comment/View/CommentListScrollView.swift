//
//  CommentListScrollView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/10/12.
//

import SwiftUI

struct CommentListScrollView: View {
    @StateObject var viewModel: CommentViewModel
    @State private var scrollViewProxy: ScrollViewProxy?
    
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                ForEach(viewModel.comments, id: \.id) { comment in
                    CommentCell(
                        nickname: comment.authorID,
                        comment: comment.comment,
                        date: comment.createdDate
                    )
                }
                .onAppear {
                    scrollViewProxy = proxy
                    proxy.scrollTo("\(viewModel.comments.count)", anchor: .bottom)
                }
                .onChange(of: viewModel.comments.count) { comments in
                    print("[DEBUG] viewModel.comments.count onchanged:", viewModel.comments.count)
                    scrollViewProxy?.scrollTo("\(viewModel.comments.count)")
                }
            }
            
        }
    }
}
