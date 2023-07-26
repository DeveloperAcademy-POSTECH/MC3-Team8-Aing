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
    
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var passwordConfirm: String = ""
    @State var emailWarning: String = ""
    @State var passwordWarning: String = ""
    @State var passwordConfirmWarning: String = ""
    @State var isAlertShown: Bool = false
    @State var alertMessage: String = ""
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        ZStack {
            Color.offWhite
            VStack {
                Spacer()
                    .frame(height: 124)
                Text("회원가입")
                    .font(.pretendard(.light, size: 28))
                Spacer()
                VStack(spacing: 37) {
                    VStack(alignment: .leading) {
                        TextField("이메일", text: $email)
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        Divider()
                        Text(emailWarning)
                            .font(.pretendard(.light, size: 12))
                            .foregroundColor(.systemRed)
                    
                    }
                    VStack(alignment: .leading) {
                        SecureField("비밀번호", text: $password)
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                        Divider()
                        Text(passwordWarning)
                            .font(.pretendard(.light, size: 12))
                            .foregroundColor(.systemRed)
                    }
                    VStack(alignment: .leading) {
                        SecureField("비밀번호 확인", text: $passwordConfirm)
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                        Divider()
                        Text(passwordConfirmWarning)
                            .font(.pretendard(.light, size: 12))
                            .foregroundColor(.systemRed)
                    }
                }
                .padding([.leading, .trailing], 15)
                Spacer()
                Button {
                    emailWarning = ""
                    passwordWarning = ""
                    passwordConfirmWarning = ""
                    if checkEmail(input: email) && checkPassword(input: password) && confirmPassword(password: password, passwordConfirm: passwordConfirm){
                        Task {
                            let result = try await userViewModel.signUpWithEmailPassword(email: email, password: password, name: name)
                            if result == "" {
                                try await userViewModel.sendEmailVerification()
                            } else {
                                alertMessage = result
                                isAlertShown = true
                            }
                        }
                    } else {
                        if email.isEmpty {
                            emailWarning = "이메일 주소를 입력해주세요."
                        } else if !checkEmail(input: email) {
                            emailWarning = "이메일 주소가 유효하지 않습니다."
                        }
                        if password.isEmpty {
                            passwordWarning = "비밀번호를 입력해주세요."
                        } else if checkPassword(input: password) {
                            passwordWarning = "영문 대소문자, 숫자, 특수문자를 포함한 8개 이상이어야 합니다."
                        }
                        if passwordConfirm.isEmpty {
                            passwordConfirmWarning = "비밀번호를 한번 더 입력해주세요."
                        } else if confirmPassword(password: password, passwordConfirm: passwordConfirm) {
                            passwordConfirmWarning = "비밀번호가 일치하지 않습니다."
                        }
                    }
                } label: {
                    Text("회원가입")
                        .frame(width: UIScreen.main.bounds.width-30, height:  60)
                        .background(Color.offBlack)
                        .foregroundColor(.offWhite)
                }
                .alert(isPresented: $isAlertShown) {
                    Alert(title: Text("회원가입 에러"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                }
                Spacer()
                    .frame(height: 47)
            }
        }
        .ignoresSafeArea()
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
            .environmentObject(UserViewModel())
    }
}
