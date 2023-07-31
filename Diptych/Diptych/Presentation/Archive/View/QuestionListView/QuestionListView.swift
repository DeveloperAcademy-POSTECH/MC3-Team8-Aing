//
//  QuestionListView.swift
//  Diptych
//
//  Created by Koo on 2023/07/18.
//

import SwiftUI

struct QuestionListView: View {
    
    @StateObject var VM : ArchiveViewModel = ArchiveViewModel()
    
    var body: some View {
        
        let data = VM.truePhotos
        let data2 = VM.trueQuestions
        
        ScrollView {
            VStack(spacing: 0){
                ForEach(0..<VM.trueQuestions.count, id: \.self) { index in
                    
                    NavigationLink {
                        PhotoDetailView(
                            VM: VM,
                            date: data[index].date,
                            image1: data[index].photoFirstURL,
                            image2: data[index].photoSecondURL,
                            question: data2[index].question,
                            currentIndex: index
                        )
                    } label: {
                        QuestionCellView(questionIndex: index,
                                         questionText: VM.trueQuestions[index].question!)
                    }
                }//】 Loop
                Spacer()
                
            }//】 VStack
            .padding(.top, 20)
        }//】 Scroll
        .background(Color.gray.opacity(0.1))
    }//】 Body
}


struct QuestionCellView: View {
    
    let questionIndex: Int
    let questionText: String
    
    var body: some View {
        HStack(spacing: 0){
            /// [1] n번째
            ZStack{
                Rectangle()
                    .fill(Color.lightGray)
                    .frame(width: 60, height: 27)
                Text("\(questionIndex + 1)번째")
            }
            .padding(.leading, 15)
            
            /// [2] 질문
            HStack(spacing: 0){
                Text(questionText)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.leading, 10)
            
            /// [3] 화살표
            Image(systemName: "chevron.right")
                .foregroundColor(.offBlack)
                .padding(.trailing, 15)
            
        }//】 HStack
        .font(.custom(PretendardType.light.rawValue, size: 16))
        .foregroundColor(.offBlack)
        .padding(.bottom, 25)
        
        
        
    }//】 Body
}

struct QuestionListView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionListView()
    }
}
