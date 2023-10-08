//
//  LikedQuestionCellView.swift
//  Diptych
//
//  Created by 김민 on 2023/10/08.
//

import SwiftUI

struct LikedQuestionCellView: View {
    @State var question: Question

    var body: some View {
        HStack(spacing: 0) {
            Text("\(question.number)번째")
                .font(.pretendard(.medium, size: 16))
                .padding(.trailing, 23)
            Text(question.question)
                .font(.pretendard(.light, size: 16))
                .lineLimit(1)
            Spacer()
            Image("icnHeart")
        }
        .foregroundColor(.offBlack)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

struct LikedQuestionCellView_Previews: PreviewProvider {
    static var previews: some View {
        LikedQuestionCellView(question: Question(number: 199,
                                                 question: "오늘의 손하트를 보여주세요!",
                                                 isLiked: true))
    }
}
