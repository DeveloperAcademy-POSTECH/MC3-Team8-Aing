//
//  ProfileView.swift
//  Diptych
//
//  Created by 김민 on 2023/07/13.
//

import SwiftUI

var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

struct ProfileView: View {
    @State private var isShowingAlert: Bool = false
    @State private var password: String = ""
    @State private var isPasswordHidden: Bool = true
    @FocusState var isPasswordFocused: Bool
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var todayDiptychViewModel = TodayDiptychViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                LazyVGrid(columns: columns) {
                    ForEach(0 ..< 1) { _ in
                        if let isFirst = userViewModel.currentUser?.isFirst {
                            if isFirst {
                                userNameLabel(text: userViewModel.currentUser?.name ?? "...") // 로딩중일때 "..."로 표현
                                    .padding(.leading, 20)
                                Image("imgHeart")
                                // userNameLabel(text: userViewModel.lover?.name ?? "...")
                                //     .padding(.trailing, 20)
                                userNameLabel(text: "...")
                                    .padding(.trailing, 20)
                            } else {
                                userNameLabel(text: userViewModel.lover?.name ?? "...")
                                    .padding(.leading, 20)
                                Image("imgHeart")
                                userNameLabel(text: userViewModel.currentUser?.name ?? "...") // 로딩중일때 "..."로 표현
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                }
                .font(.pretendard(.light, size: 24))
                .padding(.top, 133)

                Divider()
                    .frame(height: 1)
                    .overlay(Color.darkGray)
                    .padding(.top, 93)
                    .padding(.horizontal, 15)

                HStack() {
                    Spacer()
                    VStack(spacing: 15) {
                        Text("우리 시작한지")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundColor(.darkGray)
                        Text("D+\(setDdayCount())")
                            .font(.pretendard(.light, size: 28))
                            .foregroundColor(.offBlack)
                    }
                    .frame(maxWidth: .infinity)

                    Spacer()
                    VStack(spacing: 15) {
                        Text("딥틱 중")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundColor(.darkGray)
                        Text("\(todayDiptychViewModel.diptychNumber)번째")
                            .font(.pretendard(.light, size: 28))
                            .foregroundColor(.offBlack)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                .padding(.top, 43)
                .padding(.bottom, 47)

                ZStack(alignment: .top) {
                    Color.lightGray
                    VStack(spacing: 0) {
                        Text("내 초대코드")
                            .font(.pretendard(.medium, size: 14))
                            .foregroundColor(.darkGray)
                            .padding(.top, 77)
                        Text(userViewModel.currentUser?.couplingCode ?? "00000000")
                            .font(.pretendard(.light, size: 24))
                            .foregroundColor(.offBlack)
                            .padding(.top, 11)
                        lightDarkGrayLabel(text: "버전 정보 \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0.0")")
                            .padding(.top, 89)
                            .padding(.bottom, 22)
                        HStack(spacing: 39) {
                            logoutButton()
                            deleteAccountButton()
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            Task {
                await todayDiptychViewModel.fetchUser()
                await todayDiptychViewModel.setDiptychNumber()
            }
        }
    }
}

// MARK: - Component

extension ProfileView {

    private func userNameLabel(text: String) -> some View {
        return Text(text)
            .font(.pretendard(.light, size: 24))
            .foregroundColor(.offBlack)
    }

    private func lightDarkGrayLabel(text: String) -> some View {
        Text(text)
            .font(.pretendard(.light, size: 18))
            .foregroundColor(.darkGray)
    }

    private func logoutButton() -> some View {
        Button{
            userViewModel.signOut()
        } label: {
            lightDarkGrayLabel(text: "로그아웃")
                .padding(.bottom, 32)
        }
    }

    private func deleteAccountButton() -> some View {
        Button{
            isShowingAlert = true
        } label: {
            lightDarkGrayLabel(text: "회원탈퇴")
                .padding(.bottom, 32)
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
}

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
