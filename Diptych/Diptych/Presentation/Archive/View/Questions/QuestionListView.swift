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
    @StateObject private var questionListViewModel = QuestionListViewModel()

    var body: some View {
        VStack(spacing: 0) {
            LikeSegmentedControl(selection: $questionListViewModel.selection)
                .padding(.top, 15)
            questionSearchField
                .padding(.top, 21)
            questionList(for: questionListViewModel.selection)
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
                TextField("", text: $questionListViewModel.searchWord)
                    .onChange(of: questionListViewModel.searchWord) { newValue in
                        if newValue.isEmpty {
                            questionListViewModel.searchedQuestions = questionListViewModel.dummyQuestions
                        }
                    }
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
            questionListViewModel.setQuestionList()
        } label: {
            Image("icnSearch")
        }
    }

    @ViewBuilder
    private func questionList(for filter: LikeFilter) -> some View {
        switch filter {
        case .all:
            List(questionListViewModel.searchedQuestions) { question in
                QuestionCellView(question: question)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        case .like:
            List(questionListViewModel.searchedQuestions.filter { $0.isLiked == true }) { question in
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
