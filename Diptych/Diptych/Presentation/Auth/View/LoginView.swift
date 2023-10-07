//
//  LogInView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/13.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordWarning: String = ""
    @State private var isAlertShown: Bool = false
    @State private var alertMessage: String = ""
    @State private var isPasswordHidden: Bool = true
    
    @FocusState var isPasswordFocused: Bool
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea()
            VStack(spacing: 0) {
                loginLabel
                    .padding(.top, 22)
                Spacer()
                VStack(spacing: 0) {
                    emailTextField
                        .padding(.bottom, 37)
                    passwordTextField
                        .padding(.bottom, 24)
                    authMenu
                }
                Spacer()
                loginButton
                    .padding(.bottom, 26)
            }
            .padding(.horizontal, 15)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationBackButton()
            }
        }
    }
}

// MARK: - UI Components

extension LoginView {

    var loginLabel: some View {
        Text("로그인")
            .font(.pretendard(.light, size: 28))
    }

    var emailTextField: some View {
        VStack(alignment: .leading) {
            TextField("",
                      text: $email,
                      prompt: Text("이메일")
                                .font(.pretendard(.light, size: 18))
                                .foregroundColor(.dtDarkGray))
            .font(.pretendard(.light, size: 18))
            .foregroundColor(.dtDarkGray)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            Divider()
                .overlay(Color.dtDarkGray)
        }
    }

    var passwordTextField: some View {
        VStack(alignment: .leading) {
            HStack {
                SecureInputTextField(isHidden: $isPasswordHidden,
                                password: $password,
                                isFocused: $isPasswordFocused,
                                prompt: "비밀번호")
                .onTapGesture {
                    isPasswordFocused = true
                }
                Button {
                    isPasswordHidden.toggle()
                } label: {
                    Image(systemName: isPasswordHidden ? "eye" : "eye.slash")
                        .foregroundColor(.dtDarkGray)
                }
            }
            Divider()
                .overlay(passwordWarning == "" ? Color.dtDarkGray : Color.dtRed)
        }
    }

    var authMenu: some View {
        HStack(spacing: 18) {
            authMenuButton("아이디 찾기") {
                print("아이디 찾기")
            }
            Text("|")
                .font(.pretendard(.light, size: 14))
                .foregroundColor(.dtDarkGray)
            authMenuButton("비밀번호 찾기") {
                print("비밀번호 찾기")
            }
            Text("|")
                .font(.pretendard(.light, size: 14))
                .foregroundColor(.dtDarkGray)
            authMenuButton("회원가입") {
                print("회원가입")
            }
        }
    }

    var loginButton: some View {
        NavigationLink(destination: DiptychTabView()) {
            SquareButton(buttonTitle: "로그인하기",
                         buttonBackgroundColor: .offBlack,
                         titleColor: .offWhite)
        }
    }

    private func authMenuButton(_ title: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.pretendard(.light, size: 14))
                .foregroundColor(.dtDarkGray)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
        }
    }
}
