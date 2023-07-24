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
var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
//}

// MARK: - View

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        ZStack {
            Color.offWhite.edgesIgnoringSafeArea(.top)
            
            VStack {
                LazyVGrid(columns: columns) {
                    ForEach(0 ..< 1) { _ in
                        userNameLabel(text: userViewModel.currentUser?.name ?? "...") // 로딩중일때 "..."로 표현
                            .padding(.leading, 20)
                        Image("heart")
                        userNameLabel(text: userViewModel.lover?.name ?? "...")
                            .padding(.trailing, 20)
                    }
                }
                // 하트 아이콘은 중앙에 고정되었으나,
                // 여전히.. 유저의 닉네임 글자수가 서로 다르면 하트 아이콘과의 간격이 일정해지지 않는 문제점이 있음
                
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
                
                // == 충돌 부분 시작 ==
                HStack {
                    Button{
                        userViewModel.signOut()
                    } label: {
                        Text("로그아웃")
                            .font(.pretendard(.light, size: 18))
                            .padding()
//                            .background(Color.offBlack)
                            .foregroundColor(.darkGray)
                    }
                    Button{
                        userViewModel.deleteAccount()
                    } label: {
                        Text("회원탈퇴")
                            .font(.pretendard(.light, size: 18))
                            .padding()
//                            .background(Color.offBlack)
                            .foregroundColor(.darkGray)
                    }
                }
                // == 충돌 부분 끝 ==
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
            .environmentObject(UserViewModel())
    }
}
