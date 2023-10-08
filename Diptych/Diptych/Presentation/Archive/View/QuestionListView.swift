//
//  QuestionListView.swift
//  Diptych
//
//  Created by Koo on 2023/07/18.
//

import SwiftUI

struct Question {
    let number: String
    let question: String
    var isLiked: Bool
}

struct QuestionListView: View {
    @State private var selection = LikeFilter.all
    @State private var question = ""

    var body: some View {
        VStack(spacing: 0) {
            LikeSegmentedControl(selection: $selection)
                .padding(.top, 15)
            questionSearchField
                .padding(.top, 21)
            questionSegmentedControlDetailView(for: selection)
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
    private func questionSegmentedControlDetailView(for filter: LikeFilter) -> some View {
        switch filter {
        case .all:
            Text("전체")
        case .like:
            Text("좋아요")
        }
    }
}

struct QuestionListView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionListView()
    }
}
