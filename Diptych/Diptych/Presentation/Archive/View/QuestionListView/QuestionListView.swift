//
//  QuestionListView.swift
//  Diptych
//
//  Created by Koo on 2023/07/18.
//

import SwiftUI

struct QuestionListView: View {
    
    @EnvironmentObject var VM : ArchiveViewModel
    
    var body: some View {
        
        let data = VM.truePhotos
        let data2 = VM.trueQuestions
        
        ScrollView {
            VStack(spacing: 0){
                ForEach((0..<VM.trueQuestions.count).reversed(), id: \.self) { index in
                    
                    NavigationLink {
                        PhotoDetailView(
                            date: data[index].date,
                            image1: data[index].photoFirstURL,
                            image2: data[index].photoSecondURL,
                            question: data2[index].question,
                            currentIndex: index
                        )
                        .environmentObject(VM)
                    } label: {
                        QuestionCellView(questionIndex: String(format: "%02d", index + 1),
                                         questionText: VM.trueQuestions[index].question!)
                    }
                }//】 Loop
                Spacer()
                
            }//】 VStack
            .padding(.top, 20)
        }//】 Scroll
        .background(Color.offWhite)
    }//】 Body
}


struct QuestionCellView: View {
    
    let questionIndex: String
    let questionText: String
    
    var body: some View {
        HStack(spacing: 0){
//            Image(systemName: "highlighter")
//                .foregroundColor(.darkGray)
//                .font(.footnote)
//                .fontWeight(.medium)
//                .padding(.leading, 10)
            
            /// [1] n번째
            HStack(spacing: 0){
//                Text("#")
//                    .font(.system(size:11, weight: .medium))
//                    .foregroundColor(Color.systemSalmon)
                
                Text("\(questionIndex)번째")
                    .font(.system(size:16, weight: .medium))
                    .foregroundColor(Color.offBlack)
                    .italic()
            }
            .frame(width: 50,alignment: .trailing)
            .padding(.leading, 5)
            
            /// [2] 질문
            HStack(spacing: 0){
                Text(questionText)
                    .foregroundColor(.offBlack)
                    .lineLimit(1)
                Spacer()
            }
            .frame(alignment: .leading)
            .padding(.leading, 12)
            
            /// [3] 화살표
//            Image(systemName: "chevron.right")
//                .foregroundColor(.darkGray)
//                .font(.footnote)
//                .fontWeight(.light)
//                .padding(.trailing, 15)
            
        }//】 HStack
        .frame(height: 25)
        .font(.custom(PretendardType.light.rawValue, size: 16))
        .padding(.bottom, 30)
        
        
        
    }//】 Body
}

struct QuestionListView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionListView()
    }
}
