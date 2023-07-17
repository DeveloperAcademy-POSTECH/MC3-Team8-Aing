//
//  SignUpView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/13.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignUpView: View {
    @State var emailWarning: String = ""
    @State var passwordWarning: String = ""
    @State var passwordConfirmWarning: String = ""
//    @State var isShowingAlert: Bool = false
//    @State var isShowingSheet: Bool = false
    @State var isNavigationLinkActive: Bool = false
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    var body: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 124)
                Text("회원가입")
                    .font(.pretendard(.light, size: 28))
                Spacer()
                VStack(spacing: 37) {
                    VStack(alignment: .leading) {
                        TextField("이메일", text: $authViewModel.email)
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        Divider()
                        Text(emailWarning)
                            .font(.pretendard(.light, size: 12))
                            .foregroundColor(.offBlack)
                    
                    }
                    VStack(alignment: .leading) {
                        SecureField("비밀번호", text: $authViewModel.password)
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                        Divider()
                        Text(passwordWarning)
                            .font(.pretendard(.light, size: 12))
                            .foregroundColor(.offBlack)
                    }
                    VStack(alignment: .leading) {
                        SecureField("비밀번호 확인", text: $authViewModel.confirmPassword)
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                        Divider()
                        Text(passwordConfirmWarning)
                            .font(.pretendard(.light, size: 12))
                            .foregroundColor(.offBlack)
                    }
                }
                .padding([.leading, .trailing], 15)
                Spacer()
                Button {
                    if checkEmail(input: authViewModel.email) && checkPassword(input: authViewModel.password) && confirmPassword(password: authViewModel.password, passwordConfirm: authViewModel.confirmPassword){
//                        print("isShowingSheet: \(isShowingSheet)")
                        print(authViewModel.authenticationState)
                        isNavigationLinkActive.toggle()
                        Task {
                            if await authViewModel.signUpWithEmailPassword() {
                                await authViewModel.sendVerificationEmail()
                                await authViewModel.checkVerificationByReloading()
                            }
                        }
                    } else {
                        if checkEmail(input: authViewModel.email) {
                            emailWarning = ""
                        } else if authViewModel.email.isEmpty {
                            emailWarning = "이메일 주소를 입력해주세요."
                        } else {
                            emailWarning = "이메일 주소가 유효하지 않습니다."
                        }
                        if checkPassword(input: authViewModel.password) {
                            passwordWarning = ""
                        } else if authViewModel.password.isEmpty {
                            passwordWarning = "비밀번호를 입력해주세요."
                        } else {
                            passwordWarning = "영문 대소문자, 숫자, 특수문자를 포함한 8개 이상이어야 합니다."
                        }
                        if confirmPassword(password: authViewModel.password, passwordConfirm: authViewModel.confirmPassword) {
                            passwordConfirmWarning = ""
                        } else if authViewModel.confirmPassword.isEmpty {
                            passwordConfirmWarning = "비밀번호를 한번 더 입력해주세요."
                        } else {
                            passwordConfirmWarning = "비밀번호가 일치하지 않습니다."
                        }
                    }
                } label: {
                    Text("회원가입")
                        .frame(width: UIScreen.main.bounds.width-30, height:  60)
                        .background(Color.offBlack)
                        .foregroundColor(.offWhite)
                }
                NavigationLink(destination: EmailVerificationView(), isActive: $isNavigationLinkActive) {
                    EmptyView()
                }
                Spacer()
                    .frame(height: 55)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            print("user: \(authViewModel.user)")
            print("user: \(authViewModel.user?.isEmailVerified)")
            print("state: \(authViewModel.authenticationState)")
        }
    }
    
    func checkEmail(input: String) -> Bool {
        let emailRegEx: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: input)
    }
    //
    func checkPassword(input: String) -> Bool {
        let passwordRegEx: String = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\\$%\\^&\\*\\(\\)\\-\\_\\+=\\{\\}\\[\\]\\?\\/\\<\\>\\,\\.\\₩\\\\|]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegEx).evaluate(with: input)
    }
    
    func confirmPassword(password: String, passwordConfirm: String) -> Bool {
        return !password.isEmpty && password == passwordConfirm
    }
}

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthenticationViewModel())
    }
}
