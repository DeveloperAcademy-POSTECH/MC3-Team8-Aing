//
//  ProfileView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI

// MARK: - Property

//struct ProfileView {
//    let username1: String = ""
//    let username2: String = ""
//    let dDay: Int
//    var questionNum: Int
//    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
//}

// MARK: - View

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color.offWhite.edgesIgnoringSafeArea(.top)
            
            VStack {
                
                HStack(spacing: 0) {
                    userNameLabel(text: "쏜야")
                    Image("heart")
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 60)
                    userNameLabel(text: "밍니")
                } // HStack
                
                Divider()
                    .padding(.top, 80) // 임의로 조정했음
                    .padding(.bottom, 103)
                
                Text("D+233")
                    .font(.pretendard(.light, size: 28))
                    .foregroundColor(.offBlack)
                    .padding(.bottom, 30)
                
                Text("20번째 딥틱 중")
                    .font(.pretendard(.light, size: 28))
                    .foregroundColor(.offBlack)
                    .padding(.bottom, 179)
                
                Text("버전 정보 1.0.0.0")
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.darkGray)
                    .padding(.bottom, 22)
                
                Text("개인정보처리방침")
                    .font(.pretendard(.light, size: 18))
                    .foregroundColor(.darkGray)
                
            } // VStack
            
        } // ZStack
    }
}

// MARK: - Component

extension ProfileView {
    func userNameLabel(text: String) -> some View {
        return Text(text)
            .font(.pretendard(.light, size: 24))
            .foregroundColor(.offBlack)
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
