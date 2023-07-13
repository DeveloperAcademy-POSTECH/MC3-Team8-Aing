//
//  SignUpView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/13.
//

import SwiftUI

struct SignUpView: View {
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var passwordConfirm: String = ""
    @State var emailWarning: String = ""
    @State var passwordWarning: String = ""
    @State var passwordConfirmWarning: String = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        NavigationView {
            ZStack {
                Color.offWhite
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Text("회원가입")
                        .font(.pretendard(.light, size: 28))
                    Spacer()
                    VStack(spacing: 37) {
                        VStack(alignment: .leading) {
                            TextField("이메일", text: $email)
                                .font(.pretendard(.light, size: 18))
                                .foregroundColor(.darkGray)
                                .textInputAutocapitalization(.never)
                            Divider()
                            Text(emailWarning)
                                .font(.pretendard(.light, size: 12))
                                .foregroundColor(.offBlack)
                        }
                        VStack(alignment: .leading) {
                            SecureField("비밀번호", text: $password)
                                .font(.pretendard(.light, size: 18))
                                .foregroundColor(.darkGray)
                            Divider()
                            Text(passwordWarning)
                                .font(.pretendard(.light, size: 12))
                                .foregroundColor(.offBlack)
                        }
                        VStack(alignment: .leading) {
                            SecureField("비밀번호 확인", text: $passwordConfirm)
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
                        if checkEmail(input: email) && checkPassword(input: password) && confirmPassword(password: password, passwordConfirm: passwordConfirm){
                            authViewModel.emailAuthSignUp(email: email, password: password)
                        } else {
                            if checkEmail(input: email) {
                                emailWarning = ""
                            } else if email.isEmpty {
                                emailWarning = "이메일 주소를 입력해주세요."
                            } else {
                                emailWarning = "이메일 주소가 유효하지 않습니다."
                            }
                            if checkPassword(input: password) {
                                passwordWarning = ""
                            } else if password.isEmpty {
                                passwordWarning = "비밀번호를 입력해주세요."
                            } else {
                                passwordWarning = "영문 대소문자, 숫자, 특수문자를 포함한 8개 이상이어야 합니다."
                            }
                            if confirmPassword(password: password, passwordConfirm: passwordConfirm) {
                                passwordConfirmWarning = ""
                            } else if passwordConfirm.isEmpty {
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
                    Spacer()
                }
                
            }
        }
    }

    func checkEmail(input: String) -> Bool {
        let emailRegEx: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: input)
    }
//
    func checkPassword(input: String) -> Bool {
        let passwordRegEx: String = "[A-Za-z0-9!@#\\$%\\^&\\*\\(\\)\\-\\_\\+=\\{\\}\\[\\]\\?\\/\\<\\>\\,\\.\\₩\\\\|]{8,}"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegEx).evaluate(with: input)
    }
    
    func confirmPassword(password: String, passwordConfirm: String) -> Bool {
        return !password.isEmpty && password == passwordConfirm
    }
}
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
