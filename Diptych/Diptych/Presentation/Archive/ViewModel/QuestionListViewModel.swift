//
//  QuestionListViewModel.swift
//  Diptych
//
//  Created by 김민 on 2023/10/08.
//

import SwiftUI

class QuestionListViewModel: ObservableObject {

    @Published var searchedQuestions: [Question] = []
    @Published var selection = LikeFilter.all
    @Published var searchWord = ""

    var dummyQuestions = [
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

    init() {
        searchedQuestions = dummyQuestions
    }

    func setQuestionList() {
        guard !searchWord.isEmpty else {
            searchedQuestions = dummyQuestions
            return
        }
        searchedQuestions = dummyQuestions.filter { $0.question.contains(searchWord)}
    }
}
