//
//  CommentCell.swift
//  Diptych
//
//  Created by 윤범태 on 2023/10/12.
//

import SwiftUI

struct CommentCell: View {
    // TODO: @State 변수들을 모델(밸류 오브젝트)로 옮기기
    @State var nickname: String = "쏜야"
    @State var comment: String = "이번 사진 진짜 너무 웃기다하항\n정말 웃기지 않니 하하ㅏ"
    @State var date: Date = Date(timeIntervalSince1970: 1694264400)
    
    /// 날짜 형식 지정
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY년 MM월 dd일 hh:mm a"
        return formatter
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Image("diptych_sample1")
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .clipShape(
                    RoundedRectangle(
                        cornerSize: CGSize(width: 12, height: 12),
                        style: .continuous
                    )
                )
            VStack(alignment: .leading, spacing: 6) {
                Text(nickname)
                    .font(Font.pretendard(.medium, size: 14))
                    .tint(.offBlack)
                Text(comment)
                    .font(Font.pretendard(.light, size: 16))
                    .tint(.offBlack)
                Text(dateFormatter.string(from: date))
                    .font(Font.pretendard(.light, size: 12))
                    .tint(.dtDarkGray)
            }
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               alignment: .leading)
        .padding(.bottom, 20)
        
        
    }
}

struct CommentCell_Previews: PreviewProvider {
    static var previews: some View {
        CommentCell()
    }
}
