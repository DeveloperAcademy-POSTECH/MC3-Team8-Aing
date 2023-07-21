//
//  SignUpView.swift
//  Diptych
//
//  Created by HAN GIBAEK on 2023/07/13.
//

import SwiftUI
import Firebase
import FirebaseAuth

//struct SignUpView: View {
//    @State var isSignInfoViewShown: Bool = true
//
//    @EnvironmentObject var userViewModel: UserViewModel
//
//    var body: some View {
//        if isSignInfoViewShown {
//            SignInfoView(isSignInfoViewShown: $isSignInfoViewShown)
//        } else {
//            LoadingVerificationView()
//        }
//    }
//}

struct SignUpView: View {
    
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var passwordConfirm: String = ""
    @State var emailWarning: String = ""
    @State var passwordWarning: String = ""
    @State var passwordConfirmWarning: String = ""
    
//    @Binding var isSignInfoViewShown: Bool
    
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
                        TextField("이름", text: $name)
                            .font(.pretendard(.light, size: 18))
                            .foregroundColor(.darkGray)
                            .disableAutocorrection(true)
//                        Divider()
//                        Text(emailWarning)
//                            .font(.pretendard(.light, size: 12))
//                            .foregroundColor(.offBlack)
                    
                    }
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
//                        isSignInfoViewShown.toggle()
                        Task {
//                            await authViewModel.checkEmailVerification2()
                            try await userViewModel.signUpWithEmailPassword(email: email, password: password, name: name)
                            try await userViewModel.sendEmailVerification()
//                            try await userViewModel.checkEmailVerification3()
                        }
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
                    Text("로그인")
                        .frame(width: UIScreen.main.bounds.width-30, height:  60)
                        .background(Color.offBlack)
                        .foregroundColor(.offWhite)
                }
                Spacer()
                    .frame(height: 55)
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

//struct LoadingVerificationView : View {
//    @EnvironmentObject var userViewModel: UserViewModel
//
//    var body: some View {
//        VStack {
//            Text("입력하신 이메일로 인증 링크를 보냈습니다.")
//                .font(.pretendard(.light, size: 18))
//                .foregroundColor(.offBlack)
//            Text("인증 완료 후 아래 버튼을 눌러주세요.")
//                .font(.pretendard(.light, size: 18))
//                .foregroundColor(.offBlack)
//            Button {
//                Task {
//                    await userViewModel.checkEmailVerification3()
//                }
//            } label: {
//                Text("인증 완료")
//            }
//        }
//    }
//}

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