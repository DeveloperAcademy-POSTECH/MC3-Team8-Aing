//
//  CommentView.swift
//  Diptych
//
//  Created by 윤범태 on 2023/10/12.
//

import SwiftUI

struct CommentView: View {
    private enum Field: Int, CaseIterable {
        case comment
    }
    
    @State var currentCommentText = ""
    @State var showEmptyTextAlert = false
    @FocusState private var focusedField: Field?
    @StateObject var viewModel = CommentViewModel()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.offWhite.ignoresSafeArea()
            VStack {
                CommentListScrollView(viewModel: viewModel)
                Spacer()
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        TextField("댓글을 입력해주세요", text: $currentCommentText)
                            .font(.pretendard(.medium, size: 16))
                            .background(Color.offWhite)
                            .padding(.bottom, 10)
                            .focused($focusedField, equals: .comment)
                            .onSubmit {
                                submitCurrentComment()
                            }
                        Button {
                            submitCurrentComment()
                        } label: {
                            Image("imgCommentUpload")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    Rectangle()
                        .foregroundColor(.dtDarkGray)
                        // 피그마에서는 높이 1이지만 1로 지정하면 뭔가 얇아보임
                        .frame(height: 1.5)
                        .padding(.bottom, 10)
                }
                
            }
            .padding(.horizontal, 10)
            .padding(.top, 36)
        }
        .alert("댓글을 입력해주세요", isPresented: $showEmptyTextAlert) {
            Button("OK") {}
        }
    }
}

extension CommentView {
    private func submitCurrentComment() {
        guard !currentCommentText.isEmpty else {
            showEmptyTextAlert = true
            return
        }
        
        viewModel.addComment(currentCommentText)
        currentCommentText = ""
        focusedField = nil
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
