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

    var body: some View {
        ScrollView {
            LikeSegmentedControl(selection: $selection)
                .padding(.top, 15)
                .padding(.horizontal, 15)
            Text("검색")
            questionSegmentedControlDetailView(for: selection)
        }
        .ignoresSafeArea()
    }
}

extension QuestionListView {

    // MARK: - UI Components

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
