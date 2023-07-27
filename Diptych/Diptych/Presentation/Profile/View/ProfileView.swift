//
//  ProfileView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI
import Firebase

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
    @State private var isShowingAlert: Bool = false
    @State private var password: String = ""
    @State private var isPasswordHidden: Bool = true
    @FocusState var isPasswordFocused: Bool
    
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
                
                Text("D+\(setDdayCount())")
                    .font(.pretendard(.light, size: 28))
                    .foregroundColor(.offBlack)
                    .padding(.bottom, 30)
                
                Text("5번째 딥틱 중")
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
                        isShowingAlert = true
                    } label: {
                        Text("회원탈퇴")
                            .font(.pretendard(.light, size: 18))
                            .padding()
//                            .background(Color.offBlack)
                            .foregroundColor(.darkGray)
                    }
                    .alert("회원 탈퇴", isPresented: $isShowingAlert, actions: {
                        SecureField("", text: $password)
                        Button(role: .destructive){
                            print("DEBUG: 탈퇴 버튼 눌림")
                            Task{
                                try await userViewModel.deleteAccount(password: password)
                            }
                        } label: {
                            Text("탈퇴")
                        }
                        Button(role: .cancel) {
                            print("DEBUG: 취소 버튼 눌림")
                        } label: {
                            Text("취소")
                        }
                    }, message: {
                        Text("비밀번호를 입력해주세요.")
                    })
                }
                // == 충돌 부분 끝 ==
            } // VStack
        } // ZStack
    }
}

// MARK: - Component

// 유저 닉네임
extension ProfileView {
    func userNameLabel(text: String) -> some View {
        return Text(text)
            .font(.pretendard(.light, size: 24))
            .foregroundColor(.offBlack)
    }
}

// startDate로부터 디데이 계산
extension ProfileView {
    func setDdayCount() -> Int {
        guard let startDate = userViewModel.currentUser?.startDate else { return 0 }
        let currentDate = Date()
        let daysCount = (Calendar.current.dateComponents([.day], from: startDate, to: currentDate).day ?? 0) + 1
        return daysCount
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserViewModel())
    }
}
