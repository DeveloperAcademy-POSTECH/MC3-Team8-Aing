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

enum QuestionFilter: String, CaseIterable {
    case all = "전체"
    case like = "좋아요"
}

struct QuestionListView: View {
    @State private var selection = QuestionFilter.all

    var body: some View {
        ScrollView {
            questionSegmentedControlView
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

    var questionSegmentedControlView: some View {
        HStack(spacing: 0) {
            ForEach(QuestionFilter.allCases, id: \.self) { filter in
                ZStack {
                    Rectangle()
                        .foregroundColor(selection == filter ? Color.offBlack : Color.offWhite)
                    Text(filter.rawValue)
                        .font(.pretendard(.medium, size: 16))
                        .foregroundColor(selection == filter ? .offWhite : .dtDarkGray)
                }
                .onTapGesture {
                    withAnimation {
                        selection = filter
                    }
                }
            }
        }
        .frame(height: 33)
        .border(Color.dtDarkGray)
    }

    @ViewBuilder
    private func questionSegmentedControlDetailView(for filter: QuestionFilter) -> some View {
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
