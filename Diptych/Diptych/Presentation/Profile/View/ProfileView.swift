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

            // 유저 닉네임 표시 부분
            VStack {
                LazyVGrid(columns: columns) {
                    ForEach(0 ..< 1) { _ in
                        userNameLabel(text: userViewModel.currentUser?.name ?? "...") // 로딩중일때 "..."로 표현
                            .padding(.leading, 20)
                        Image("imgHeart")
                        userNameLabel(text: userViewModel.lover?.name ?? "...")
                            .padding(.trailing, 20)
                    }
                }
                .padding(.top, 60)

                Divider()
                    .frame(height: 1)
                    .overlay(Color.darkGray)
                    .padding(.horizontal, 15)
                    .padding(.top, 80) // 임의로 조정했음
                    .padding(.bottom, 43)

                // 디데이, 몇번째 딥틱인지 정보 표시 부분
                HStack {
                    VStack {
                        Text("우리 시작한지")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundColor(.darkGray)
                            .padding(.bottom, 15)
                        Text("D+\(setDdayCount())")
                            .font(.pretendard(.light, size: 28))
                            .foregroundColor(.offBlack)
                            .padding(.bottom, 47)
                    }
                    .padding(.leading, 50)
                    Spacer()
                    VStack {
                        Text("딥틱 중")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundColor(.darkGray)
                            .padding(.bottom, 15)
                        Text("222번째")
                            .font(.pretendard(.light, size: 28))
                            .foregroundColor(.offBlack)
                            .padding(.bottom, 47)
                    }
                    .padding(.trailing, 50)
                }

                ZStack {
                    Color.lightGray.edgesIgnoringSafeArea(.top)
                    VStack {
                        Text("내 초대코드")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundColor(.darkGray)
//                            .padding(.top, 20)
                            .padding(.bottom, 11)
                        Text(userViewModel.currentUser?.couplingCode ?? "")
                            .font(.pretendard(.light, size: 24))
                            .foregroundColor(.offBlack)
                            .padding(.bottom, 89)

                        Text("버전 정보 1.0.0.0")
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                            .padding(.bottom, 10)



                        // == 충돌 부분 시작 ==
                        HStack {
                            Button{
                                userViewModel.signOut()
                            } label: {
                                Text("로그아웃")
                                    .font(.pretendard(.light, size: 18))
                                    .padding(.bottom, 32)
                                    .foregroundColor(.darkGray)
                            }
                            Button{
                                isShowingAlert = true
                            } label: {
                                Text("회원탈퇴")
                                    .font(.pretendard(.light, size: 18))
                                    .padding(.bottom, 32)
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
                        } // HStack
                    } // VStack
                } // darkGray ZStack

                // == 충돌 부분 끝 ==
            }
        } // offWhite ZStack
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
