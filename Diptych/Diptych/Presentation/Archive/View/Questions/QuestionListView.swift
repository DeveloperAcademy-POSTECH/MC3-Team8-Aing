//
//  QuestionListView.swift
//  Diptych
//
//  Created by Koo on 2023/07/18.
//

import SwiftUI

struct Question: Identifiable {
    var id = UUID()
    let number: Int
    let question: String
    var isLiked: Bool
}

struct QuestionListView: View {
    @State private var selection = LikeFilter.all
    @State private var question = ""
    private let dummyQuestions = [
        Question(number: 199,
                 question: "질문111111111111111111111",
                 isLiked: false),
        Question(number: 199,
                 question: "질문222222222222222222222222222222",
                 isLiked: true),
        Question(number: 199,
                 question: "질문333333333333333",
                 isLiked: false)
    ]

    var body: some View {
        VStack(spacing: 0) {
            LikeSegmentedControl(selection: $selection)
                .padding(.top, 15)
            questionSearchField
                .padding(.top, 21)
            questionList(for: selection)
                .padding(.top, 30)
            Spacer()
        }
        .padding(.horizontal, 15)
    }
}

extension QuestionListView {

    // MARK: - UI Components

    var questionSearchField: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("", text: $question)
                searchButton
            }
            .padding(.bottom, 9)
            Rectangle()
                .foregroundColor(.dtDarkGray)
                .frame(height: 1)
        }
    }

    var searchButton: some View {
        Button {
            question.removeAll()
        } label: {
            Image("icnSearch")
        }
    }

    @ViewBuilder
    private func questionList(for filter: LikeFilter) -> some View {
        switch filter {
        case .all:
            List(dummyQuestions) { question in
                QuestionCellView(question: question)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        case .like:
            List(dummyQuestions.filter { $0.isLiked == true }) { question in
                LikedQuestionCellView(question: question)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
    }
}

struct QuestionListView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionListView()
    }
}
